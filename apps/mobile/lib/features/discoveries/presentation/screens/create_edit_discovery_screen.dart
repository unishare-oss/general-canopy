import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:canopy/shared/utils/pick_photo.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/create_discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/update_discovery.dart';
import 'package:canopy/features/discoveries/presentation/providers/discovery_repository_provider.dart';

const _palette = [
  '2F7D4F',
  '5A9B6F',
  'E05B3C',
  'F2C94C',
  'E8A0C8',
  'F6A623',
  '4A7C59',
  'C0392B',
  'D4A043',
  '7BAE6E',
  'A0724A',
  '8FBC8F',
  'C4A87A',
  '4A90D9',
  'E67E22',
];

String _randomColor() => _palette[Random().nextInt(_palette.length)];

class CreateEditDiscoveryScreen extends ConsumerStatefulWidget {
  const CreateEditDiscoveryScreen({
    super.key,
    this.discovery,
    this.initialLat,
    this.initialLng,
  });

  final Discovery? discovery;
  final double? initialLat;
  final double? initialLng;

  @override
  ConsumerState<CreateEditDiscoveryScreen> createState() =>
      _CreateEditDiscoveryScreenState();
}

class _CreateEditDiscoveryScreenState
    extends ConsumerState<CreateEditDiscoveryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final String _colorHex;

  String? _existingPhotoUrl;
  String? _pickedPhotoName;
  Uint8List? _pickedPhotoBytes;
  bool _submitting = false;

  bool get _isEditing => widget.discovery != null;

  @override
  void initState() {
    super.initState();
    final d = widget.discovery;
    _titleCtrl = TextEditingController(text: d?.title ?? '');
    _descriptionCtrl = TextEditingController(text: d?.description ?? '');
    _categoryCtrl = TextEditingController(text: d?.category ?? '');
    _neighborhoodCtrl = TextEditingController(text: d?.neighborhood ?? '');
    _colorHex = d != null ? d.colorHex.replaceFirst('#', '') : _randomColor();
    _existingPhotoUrl = d?.photoUrl;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryCtrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await pickPhoto();
    if (result.bytes == null) return;
    setState(() {
      _pickedPhotoBytes = result.bytes;
      _pickedPhotoName = result.name;
      _existingPhotoUrl = null;
    });
  }

  void _clearPhoto() => setState(() {
    _pickedPhotoBytes = null;
    _pickedPhotoName = null;
    _existingPhotoUrl = null;
  });

  Future<String?> _uploadPhoto() async {
    if (_pickedPhotoBytes == null) return _existingPhotoUrl;
    final ext = (_pickedPhotoName ?? 'photo.jpg').split('.').last.toLowerCase();
    final ref = FirebaseStorage.instance.ref(
      'discoveries/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await ref.putData(
      _pickedPhotoBytes!,
      SettableMetadata(contentType: 'image/$ext'),
    );
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final photoUrl = await _uploadPhoto();
      final repo = ref.read(discoveryRepositoryProvider);
      final lat = widget.initialLat ?? widget.discovery?.lat ?? 0.0;
      final lng = widget.initialLng ?? widget.discovery?.lng ?? 0.0;

      if (_isEditing) {
        await UpdateDiscovery(repo)(
          Discovery(
            id: widget.discovery!.id,
            title: _titleCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            category: _categoryCtrl.text.trim(),
            lat: lat,
            lng: lng,
            neighborhood: _neighborhoodCtrl.text.trim(),
            colorHex: _colorHex,
            createdAt: widget.discovery!.createdAt,
            createdBy: widget.discovery!.createdBy,
            photoUrl: photoUrl,
          ),
        );
        if (mounted) context.pop();
      } else {
        final uid = ref.read(authStateProvider).value?.id ?? '';
        final newId = await CreateDiscovery(repo)(
          Discovery(
            id: '',
            title: _titleCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            category: _categoryCtrl.text.trim(),
            lat: lat,
            lng: lng,
            neighborhood: _neighborhoodCtrl.text.trim(),
            colorHex: _colorHex,
            createdAt: DateTime.now(),
            createdBy: uid,
            photoUrl: photoUrl,
          ),
        );
        if (mounted) context.go('/discovery/$newId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit discovery' : 'New discovery'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _label('Title', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ancient Banyan Grove',
                  ),
                  validator: _required,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _label('Description', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Describe what makes this place special…',
                  ),
                  validator: _required,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _label('Category', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flora, Habitat, Landmark',
                  ),
                  validator: _required,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _label('Neighborhood', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _neighborhoodCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Silom'),
                  validator: _required,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _label('Photo', tt),
                const SizedBox(height: 8),
                _buildPhotoPicker(cs),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_isEditing ? 'Save changes' : 'Create discovery'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (_submitting) ...[
          const ModalBarrier(dismissible: false, color: Colors.black26),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _buildPhotoPicker(ColorScheme cs) {
    if (_pickedPhotoBytes != null) {
      return _photoPreview(
        Image.memory(_pickedPhotoBytes!, fit: BoxFit.cover),
        cs,
      );
    }
    if (_existingPhotoUrl != null) {
      return _photoPreview(
        Image.network(_existingPhotoUrl!, fit: BoxFit.cover),
        cs,
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _pickPhoto,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Choose photo'),
      ),
    );
  }

  Widget _photoPreview(Widget image, ColorScheme cs) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 180, width: double.infinity, child: image),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _overlayBtn(Icons.edit, cs.primary, _pickPhoto),
              const SizedBox(width: 6),
              _overlayBtn(Icons.close, cs.error, _clearPhoto),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overlayBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _label(String text, TextTheme tt) => Text(text, style: tt.labelLarge);

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
