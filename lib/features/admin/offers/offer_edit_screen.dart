import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/offer.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';

class OfferEditScreen extends ConsumerStatefulWidget {
  final Offer? offer;
  const OfferEditScreen({super.key, this.offer});

  @override
  ConsumerState<OfferEditScreen> createState() => _OfferEditScreenState();
}

class _OfferEditScreenState extends ConsumerState<OfferEditScreen> {
  late final _title = TextEditingController(text: widget.offer?.title ?? '');
  late final _description = TextEditingController(text: widget.offer?.description ?? '');
  late final _terms = TextEditingController(text: widget.offer?.terms ?? '');

  late DateTime? _validFrom = widget.offer?.validFrom;
  late DateTime? _validUntil = widget.offer?.validUntil;
  late bool _isFeatured = widget.offer?.isFeatured ?? false;
  late bool _isActive = widget.offer?.isActive ?? true;

  String? _existingBanner;
  File? _pickedBanner;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _existingBanner = widget.offer?.bannerUrl;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _terms.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    setState(() => _pickedBanner = File(file.path));
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _validFrom : _validUntil;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _validFrom = picked;
      } else {
        _validUntil = picked;
      }
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      _snack('Offer title is required');
      return;
    }
    if (_validFrom != null && _validUntil != null && _validUntil!.isBefore(_validFrom!)) {
      _snack('End date must be after the start date');
      return;
    }
    setState(() => _saving = true);
    try {
      String? banner = _existingBanner;
      if (_pickedBanner != null) {
        setState(() => _uploading = true);
        banner = await ref.read(storageRepositoryProvider).uploadImage(
              bucket: AppConfig.bucketOfferBanners,
              file: _pickedBanner!,
              prefix: 'banners',
            );
      }
      await ref.read(offerRepositoryProvider).upsert(Offer(
            id: widget.offer?.id ?? '',
            title: title,
            description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            bannerUrl: banner,
            validFrom: _validFrom,
            validUntil: _validUntil,
            terms: _terms.text.trim().isEmpty ? null : _terms.text.trim(),
            isFeatured: _isFeatured,
            isActive: _isActive,
          ));
      refreshAllContent(ref);
      if (mounted) {
        _snack(widget.offer == null ? 'Offer created' : 'Offer updated');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) _snack('Could not save the offer');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.offer == null ? 'New Offer' : 'Edit Offer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _uploading ? null : _pickBanner,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _pickedBanner != null
                        ? Image.file(
                            _pickedBanner!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : AppNetworkImage(
                            url: _existingBanner,
                            width: double.infinity,
                            height: 160,
                            borderRadius: 18,
                            fallbackLabel: 'Add banner',
                          ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.brandGreen,
                        shape: BoxShape.circle,
                      ),
                      child: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Text('Tap to upload a banner image', style: AppText.bodySmall)),
          const SizedBox(height: 20),

          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Offer title'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _terms,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Terms & conditions (one per line)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),

          Text('Validity', style: AppText.headline.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Valid from',
                  value: _validFrom == null ? 'Not set' : formatDate(_validFrom!),
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Valid until',
                  value: _validUntil == null ? 'Not set' : formatDate(_validUntil!),
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          if (_validFrom != null || _validUntil != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => setState(() {
                  _validFrom = null;
                  _validUntil = null;
                }),
                child: const Text('Clear dates (ongoing offer)'),
              ),
            ),
          const SizedBox(height: 16),

          SwitchListTile(
            value: _isFeatured,
            onChanged: (v) => setState(() => _isFeatured = v),
            title: const Text('Featured offer'),
            subtitle: const Text('Shown prominently to customers'),
            activeThumbColor: AppColors.accentGold,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            title: const Text('Active'),
            subtitle: const Text('Inactive offers are hidden from customers'),
            activeThumbColor: AppColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save offer'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_rounded, size: 20),
        ),
        child: Text(value, style: AppText.title.copyWith(fontSize: 14)),
      ),
    );
  }
}
