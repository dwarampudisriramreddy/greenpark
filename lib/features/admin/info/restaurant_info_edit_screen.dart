import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/restaurant_info.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/error_view.dart';

class RestaurantInfoEditScreen extends ConsumerStatefulWidget {
  const RestaurantInfoEditScreen({super.key});

  @override
  ConsumerState<RestaurantInfoEditScreen> createState() => _RestaurantInfoEditScreenState();
}

class _RestaurantInfoEditScreenState extends ConsumerState<RestaurantInfoEditScreen> {
  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _about = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _mapsUrl = TextEditingController();
  final _instagramUrl = TextEditingController();
  final _facebookUrl = TextEditingController();

  Map<String, Map<String, String>> _hours = {};
  String? _logoUrl;
  String? _heroUrl;
  File? _pickedLogo;
  File? _pickedHero;
  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _about.dispose();
    _address.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _email.dispose();
    _mapsUrl.dispose();
    _instagramUrl.dispose();
    _facebookUrl.dispose();
    super.dispose();
  }

  void _populate(RestaurantInfo info) {
    _name.text = info.name;
    _tagline.text = info.tagline ?? '';
    _about.text = info.about ?? '';
    _address.text = info.address ?? '';
    _phone.text = info.phone ?? '';
    _whatsapp.text = info.whatsapp ?? '';
    _email.text = info.email ?? '';
    _mapsUrl.text = info.mapsUrl ?? '';
    _instagramUrl.text = info.instagramUrl ?? '';
    _facebookUrl.text = info.facebookUrl ?? '';
    _hours = info.openingHours;
    _logoUrl = info.logoUrl;
    _heroUrl = info.heroImageUrl;
    _loaded = true;
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    setState(() => _pickedLogo = File(file.path));
  }

  Future<void> _pickHero() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    setState(() => _pickedHero = File(file.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final storage = ref.read(storageRepositoryProvider);
      final repo = ref.read(restaurantRepositoryProvider);

      String? logoUrl = _logoUrl;
      String? heroUrl = _heroUrl;
      if (_pickedLogo != null) {
        logoUrl = await storage.uploadImage(
          bucket: AppConfig.bucketRestaurantImages,
          file: _pickedLogo!,
          prefix: 'logo',
        );
      }
      if (_pickedHero != null) {
        heroUrl = await storage.uploadImage(
          bucket: AppConfig.bucketRestaurantImages,
          file: _pickedHero!,
          prefix: 'hero',
        );
      }

      await repo.update(RestaurantInfo(
        name: _name.text.trim().isEmpty ? 'Green Park Family Restaurant' : _name.text.trim(),
        tagline: _tagline.text.trim().isEmpty ? null : _tagline.text.trim(),
        about: _about.text.trim().isEmpty ? null : _about.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        whatsapp: _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        openingHours: _hours,
        mapsUrl: _mapsUrl.text.trim().isEmpty ? null : _mapsUrl.text.trim(),
        instagramUrl: _instagramUrl.text.trim().isEmpty ? null : _instagramUrl.text.trim(),
        facebookUrl: _facebookUrl.text.trim().isEmpty ? null : _facebookUrl.text.trim(),
        logoUrl: logoUrl,
        heroImageUrl: heroUrl,
      ));

      refreshAllContent(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant information updated')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save changes')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(restaurantInfoProvider);

    return info.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: ErrorView(message: 'Could not load restaurant information.'),
      ),
      data: (data) {
        if (!_loaded) _populate(data);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Restaurant Info'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Logo', style: AppText.headline.copyWith(fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _pickedLogo != null
                          ? Image.file(_pickedLogo!, width: 96, height: 96, fit: BoxFit.cover)
                          : AppNetworkImage(url: _logoUrl, width: 96, height: 96, borderRadius: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Tap the logo to upload a new one. Recommended: square PNG.',
                      style: AppText.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('Home banner', style: AppText.headline.copyWith(fontSize: 15)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickHero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _pickedHero != null
                      ? Image.file(_pickedHero!, width: double.infinity, height: 130, fit: BoxFit.cover)
                      : AppNetworkImage(
                          url: _heroUrl,
                          width: double.infinity,
                          height: 130,
                          borderRadius: 16,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text('Tap to change the large image on the home screen.', style: AppText.bodySmall),
              const SizedBox(height: 24),

              _label('Restaurant name'),
              TextField(controller: _name, decoration: const InputDecoration(hintText: 'Green Park Family Restaurant')),
              const SizedBox(height: 14),
              _label('Tagline'),
              TextField(controller: _tagline, decoration: const InputDecoration(hintText: 'The Taste of Andhra...')),
              const SizedBox(height: 14),
              _label('About / story'),
              TextField(controller: _about, maxLines: 5, decoration: const InputDecoration(alignLabelWithHint: true, hintText: 'Our story...')),
              const SizedBox(height: 14),
              _label('Address'),
              TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(hintText: 'Main Road, Rajanagaram...')),
              const SizedBox(height: 14),
              _label('Phone'),
              TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 ...')),
              const SizedBox(height: 14),
              _label('WhatsApp'),
              TextField(controller: _whatsapp, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 ...')),
              const SizedBox(height: 14),
              _label('Email'),
              TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'hello@...')),
              const SizedBox(height: 14),
              _label('Google Maps URL'),
              TextField(controller: _mapsUrl, decoration: const InputDecoration(hintText: 'https://maps.google.com/...')),
              const SizedBox(height: 14),
              _label('Instagram URL'),
              TextField(controller: _instagramUrl, decoration: const InputDecoration(hintText: 'https://instagram.com/...')),
              const SizedBox(height: 14),
              _label('Facebook URL'),
              TextField(controller: _facebookUrl, decoration: const InputDecoration(hintText: 'https://facebook.com/...')),
              const SizedBox(height: 24),

              Text('Opening hours', style: AppText.headline.copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              if (_hours.isEmpty)
                TextButton(
                  onPressed: () => setState(() {
                    _hours = {
                      for (final d in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])
                        d: {'open': '11:00', 'close': '23:00'},
                    };
                  }),
                  child: const Text('Use daily 11 AM - 11 PM'),
                ),
              for (final entry in _hours.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          entry.key[0].toUpperCase() + entry.key.substring(1),
                          style: AppText.title.copyWith(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value['open'] ?? '',
                                decoration: const InputDecoration(isDense: true, hintText: '11:00'),
                                onChanged: (v) =>
                                    _hours[entry.key] = {..._hours[entry.key]!, 'open': v},
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('-'),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value['close'] ?? '',
                                decoration: const InputDecoration(isDense: true, hintText: '23:00'),
                                onChanged: (v) =>
                                    _hours[entry.key] = {..._hours[entry.key]!, 'close': v},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save information'),
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
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppText.title.copyWith(fontSize: 13)),
    );
  }
}
