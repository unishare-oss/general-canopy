import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/create_discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/update_discovery.dart';
import 'package:canopy/features/discoveries/presentation/providers/discovery_repository_provider.dart';

class CreateEditDiscoveryScreen extends ConsumerStatefulWidget {
  const CreateEditDiscoveryScreen({super.key, this.discovery});

  /// Non-null when editing an existing discovery.
  final Discovery? discovery;

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
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _colorHexCtrl;
  late final TextEditingController _photoUrlCtrl;

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
    _latCtrl = TextEditingController(text: d != null ? '${d.lat}' : '');
    _lngCtrl = TextEditingController(text: d != null ? '${d.lng}' : '');
    _colorHexCtrl = TextEditingController(
      text: d != null ? d.colorHex.replaceFirst('#', '') : '',
    );
    _photoUrlCtrl = TextEditingController(text: d?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _colorHexCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    try {
      final repo = ref.read(discoveryRepositoryProvider);
      final photoUrl = _photoUrlCtrl.text.trim().isEmpty
          ? null
          : _photoUrlCtrl.text.trim();

      if (_isEditing) {
        final updated = Discovery(
          id: widget.discovery!.id,
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          lat: double.parse(_latCtrl.text.trim()),
          lng: double.parse(_lngCtrl.text.trim()),
          neighborhood: _neighborhoodCtrl.text.trim(),
          colorHex: _colorHexCtrl.text.trim(),
          createdAt: widget.discovery!.createdAt,
          createdBy: widget.discovery!.createdBy,
          photoUrl: photoUrl,
        );
        await UpdateDiscovery(repo)(updated);
        if (mounted) context.pop();
      } else {
        final uid = ref.read(authStateProvider).value?.id ?? '';
        final created = Discovery(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          lat: double.parse(_latCtrl.text.trim()),
          lng: double.parse(_lngCtrl.text.trim()),
          neighborhood: _neighborhoodCtrl.text.trim(),
          colorHex: _colorHexCtrl.text.trim(),
          createdAt: DateTime.now(),
          createdBy: uid,
          photoUrl: photoUrl,
        );
        final newId = await CreateDiscovery(repo)(created);
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
                _SectionLabel(label: 'Title', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ancient Banyan Grove',
                  ),
                  validator: _requiredValidator,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Description', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Describe what makes this place special…',
                  ),
                  validator: _requiredValidator,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Category', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flora, Habitat, Landmark',
                  ),
                  validator: _requiredValidator,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Neighborhood', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _neighborhoodCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Silom'),
                  validator: _requiredValidator,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(label: 'Latitude', textTheme: tt),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _latCtrl,
                            decoration: const InputDecoration(
                              hintText: '13.7563',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _doubleValidator,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(label: 'Longitude', textTheme: tt),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lngCtrl,
                            decoration: const InputDecoration(
                              hintText: '100.5018',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: _doubleValidator,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Color hex (6 characters)', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _colorHexCtrl,
                  decoration: const InputDecoration(hintText: '2F7D4F'),
                  validator: _colorHexValidator,
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Photo URL (optional)', textTheme: tt),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _photoUrlCtrl,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/photo.jpg',
                  ),
                  keyboardType: TextInputType.url,
                ),
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
        if (_submitting)
          const ModalBarrier(dismissible: false, color: Colors.black26),
        if (_submitting) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _doubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  String? _colorHexValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final hex = value.trim().replaceFirst('#', '');
    if (hex.length != 6) return 'Must be exactly 6 hex characters';
    final valid = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex);
    if (!valid) return 'Enter a valid hex color (e.g. 2F7D4F)';
    return null;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textTheme});

  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: textTheme.labelLarge);
  }
}
