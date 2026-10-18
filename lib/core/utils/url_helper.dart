import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<bool> launchArticleUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return false;
    final uri = Uri.tryParse(urlString);
    if (uri == null) return false;

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
