import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:canopy/shared/utils/pick_photo.dart';
import 'package:canopy/features/saplings/domain/usecases/create_sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';

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

class CreateSaplingScreen extends ConsumerStatefulWidget {
  const CreateSaplingScreen({super.key, required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  ConsumerState<CreateSaplingScreen> createState() =>
      _CreateSaplingScreenState();
}

class _CreateSaplingScreenState extends ConsumerState<CreateSaplingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _speciesCtrl;
  late final TextEditingController _latinCtrl;
  late final TextEditingController _personalityCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final String _colorHex;

  String? _pickedPhotoName;
  Uint8List? _pickedPhotoBytes;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController();
    _speciesCtrl = TextEditingController();
    _latinCtrl = TextEditingController();
    _personalityCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _neighborhoodCtrl = TextEditingController();
    _colorHex = _randomColor();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _speciesCtrl.dispose();
    _latinCtrl.dispose();
    _personalityCtrl.dispose();
    _streetCtrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await pickPhoto();
    if (result.bytes == null) return;
    setState(() {
      _pickedPhotoBytes = result.bytes;
      _pickedPhotoName = result.name;
    });
  }

  void _clearPhoto() => setState(() {
    _pickedPhotoBytes = null;
    _pickedPhotoName = null;
  });

  Future<String?> _uploadPhoto() async {
    if (_pickedPhotoBytes == null) return null;
    final ext = (_pickedPhotoName ?? 'photo.jpg').split('.').last.toLowerCase();
    final ref = FirebaseStorage.instance.ref(
      'saplings/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    // putString+base64 works on all platforms: avoids the dart2js Int64 issue
    // that breaks putData on web, and avoids putBlob which is native-only.
    await ref.putString(
      base64Encode(_pickedPhotoBytes!),
      format: PutStringFormat.base64,
      metadata: SettableMetadata(contentType: 'image/$ext'),
    );
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final photoUrl = await _uploadPhoto();
      final repo = ref.read(saplingRepositoryProvider);
      final id = await CreateSapling(repo)(
        nickname: _nicknameCtrl.text.trim(),
        species: _speciesCtrl.text.trim(),
        latin: _latinCtrl.text.trim(),
        personality: _personalityCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
        lat: widget.lat,
        lng: widget.lng,
        colorHex: _colorHex,
        photoUrl: photoUrl,
      );
      if (mounted) context.go('/sapling/$id');
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
          appBar: AppBar(title: const Text('New sapling')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _label('Nickname', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Jamu'),
                  validator: _required,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _label('Species', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _speciesCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Rain Tree'),
                  validator: _required,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _label('Latin name', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _latinCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Samanea saman',
                  ),
                  validator: _required,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _label('Personality', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _personalityCtrl,
                  decoration: const InputDecoration(
                    hintText: 'A short bio for this tree…',
                  ),
                  validator: _required,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _label('Street address', tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _streetCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Silom Rd, near BTS Sala Daeng',
                  ),
                  validator: _required,
                  textCapitalization: TextCapitalization.sentences,
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
                  child: const Text('Add sapling'),
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
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.memory(_pickedPhotoBytes!, fit: BoxFit.cover),
            ),
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _pickPhoto,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Choose photo'),
      ),
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
