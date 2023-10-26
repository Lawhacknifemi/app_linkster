import 'dart:io';
import 'package:app_linkster/model/app_type.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DeeplinkCreator {
  const DeeplinkCreator(this.logger);

  final Logger logger;
  Future<String> getDeepLink({
    required String url,
    required AppType type,
    required String idExtractionRegex,
    required String androidDeepLinkTemplate,
    required String iosDeepLinkTemplate,
  }) async {
    String filledUrl(String id) {
      return Platform.isAndroid
          ? androidDeepLinkTemplate.replaceAll('{id}', id)
          : iosDeepLinkTemplate.replaceAll('{id}', id);
    }

    final newEntityId = await _getSocialMediaId(url, idExtractionRegex);
    if (newEntityId != null) {
      return filledUrl(newEntityId);
    }
    return '';
  }

  Future<String?> _getSocialMediaId(String url, String regexString) async {
    final body = await _makeABrowserLikeRequest(url);
    if (body == null) return null;

    final match = RegExp(regexString).firstMatch(body);
    return match?.group(1);
  }

  Future<String?> _makeABrowserLikeRequest(String url) async {
    final dio = Dio();
    final headers = _getBrowserLikeHeaders();
    try {
      final response = await dio.get(url, options: Options(headers: headers));
      if (response.statusCode == 200) return response.data.toString();
      logger.e('Failed to load profile: ${response.statusCode}');
    } catch (e) {
      logger.e('Request error: $e');
    }
    return null;
  }

  static Map<String, String> _getBrowserLikeHeaders() => {
        'dpr': '2',
        'viewport-width': '1920',
        'sec-ch-ua':
            '"Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'sec-ch-ua-platform-version': '"13.6.0"',
        'sec-ch-ua-model': '""',
        'sec-ch-ua-full-version-list':
            '"Chromium";v="118.0.5993.88", "Google Chrome";v="118.0.5993.88", "Not=A?Brand";v="99.0.0.0"',
        'sec-ch-prefers-color-scheme': 'dark',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      };
}
