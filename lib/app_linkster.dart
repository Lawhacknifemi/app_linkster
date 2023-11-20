library app_linkster;

export 'model/model.dart';
export 'application/application.dart';
import 'dart:io';

import 'package:app_linkster/application/deep_link_creator.dart';
import 'package:app_linkster/application/kv_store.dart';
import 'package:app_linkster/model/app_type.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppLinksterLauncher {
  AppLinksterLauncher({
    DeeplinkCreator? deeplinkCreator,
    KeyValueStore? keyValueStore,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        keyValueStore = keyValueStore ?? KeyValueStore() {
    this.deeplinkCreator = deeplinkCreator ?? DeeplinkCreator(this.logger);
  }

  //this is a singleton
  static final AppLinksterLauncher _singleton = AppLinksterLauncher();

  static AppLinksterLauncher get instance => _singleton;

  late final DeeplinkCreator deeplinkCreator;
  final Logger logger;
  final KeyValueStore keyValueStore;

  Future<void> launchThisGuy(String url) async {
    final type = _identifyAppType(url);

    switch (type) {
      case AppType.facebook:
        await _launchFacebook(url);
        break;
      case AppType.twitter:
        await _launchTwitter(url);
        break;
      case AppType.instagram:
        await _launchInstagram(url);
        break;
      case AppType.tiktok:
        await _launchTikTok(url);
        break;
      case AppType.youtube:
        await _launchYoutube(url);
        break;
      case AppType.linkedin:
        await _launchLinkedIn(url);
        break;
      default:
        logger.e("Unknown link type for url: $url");
        throw Exception("Unknown link type");
    }
  }

  Future _launchFacebook(String url) async {
    String parsedUrl = keyValueStore.get(AppType.facebook.name) ??
        await deeplinkCreator.getDeepLink(
          url: url.replaceFirst('www.', ''),
          type: AppType.facebook,
          idExtractionRegex:
              r'<meta property="al:android:url" content="fb://profile/(\d+)"',
          androidDeepLinkTemplate: 'fb://profile/{id}',
          iosDeepLinkTemplate: 'fb://profile/{id}',
        );
    keyValueStore.put(AppType.facebook.name, parsedUrl);

    logger.d("Parsed Facebook URL: $parsedUrl");
    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _launchTikTok(String url) async {
    String parsedUrl = keyValueStore.get(AppType.tiktok.name) ??
        await deeplinkCreator.getDeepLink(
            url: url,
            type: AppType.tiktok,
            idExtractionRegex: r',"authorId":"(\d+)"',
            androidDeepLinkTemplate: 'snssdk1233://user/profile/{id}',
            iosDeepLinkTemplate: 'snssdk1233://user/profile/{id}');

    keyValueStore.put(AppType.tiktok.name, parsedUrl);
    logger.d("Parsed TikTok URL: $parsedUrl");

    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _launchTwitter(String url) async {
    String parsedUrl =
        "twitter://user/?screen_name=${Uri.parse(url).pathSegments.lastWhere((item) => item.isNotEmpty)}";
    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _launchInstagram(String url) async {
    String parsedUrl =
        "instagram://user?username=${Uri.parse(url).pathSegments.lastWhere((item) => item.isNotEmpty)}";
    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _launchLinkedIn(String url) async {
    String parsedUrl = "linkedin:/${Uri.parse(url).path}";

    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _launchYoutube(String url) async {
    String parsedUrl =
        "youtube:/${"${Uri.parse(url).path}?${Uri.parse(url).query}"}";
    await _determineOSAndLaunchUrl(url: url, parsedUrl: parsedUrl);
  }

  Future _determineOSAndLaunchUrl(
      {required String url, required String parsedUrl}) async {
    final canLaunch = await canLaunchUrlString(parsedUrl);
    logger.d("Can launch: $canLaunch");

    String urlToLaunch = canLaunch ? parsedUrl : url;
    logger.d("Determined URL: $urlToLaunch");

    launchUrlString(urlToLaunch,
        mode: Platform.isAndroid
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault);
  }

  AppType _identifyAppType(String url) {
    const Map<String, AppType> domainToType = {
      "facebook": AppType.facebook,
      "twitter.com": AppType.twitter,
      "instagram.com": AppType.instagram,
      "tiktok.com": AppType.tiktok,
      "youtube.com": AppType.youtube,
      "linkedin.com": AppType.linkedin,
    };

    return domainToType.entries
        .firstWhere((entry) => url.contains(entry.key))
        .value;
  }
}
