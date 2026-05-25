/// Normalizes image src to an absolute, HTTPS URL.
class ImageUrlHelper {
  static String normalize(String src) {
    var s = src.trim();
    if (s.isEmpty) return s;

    if (s.startsWith('//')) {
      s = 'https:$s';
    }

    if (s.startsWith('/')) {
      s = 'https://pic.wenku8.com$s';
    }

    Uri uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {
      return s;
    }

    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'https');
      return uri.toString();
    }

    return s;
  }
}
