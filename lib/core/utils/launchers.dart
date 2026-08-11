import 'package:url_launcher/url_launcher.dart';

/// Opens a phone dialer for [phone].
Future<void> launchCall(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
  await _launch(uri);
}

/// Opens WhatsApp chat with [phone] (digits only, incl. country code).
Future<void> launchWhatsApp(String phone, {String? message}) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  final text = message == null ? '' : '?text=${Uri.encodeComponent(message)}';
  await _launch(Uri.parse('https://wa.me/$digits$text'));
}

/// Opens Google Maps at [mapsUrl] (falls back to a query search).
Future<void> launchDirections(String? mapsUrl) async {
  if (mapsUrl != null && mapsUrl.isNotEmpty) {
    await _launch(Uri.parse(mapsUrl));
    return;
  }
  await _launch(Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=Green+Park+Family+Restaurant+Rajanagaram+Rajahmundry',
  ));
}

Future<void> launchUrlExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await _launch(uri);
}

Future<void> launchEmail(String email) async {
  await _launch(Uri(scheme: 'mailto', path: email));
}

Future<void> _launch(Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
