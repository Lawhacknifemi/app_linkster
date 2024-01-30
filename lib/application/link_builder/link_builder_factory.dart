import 'package:app_linkster/app_linkster.dart';
import 'package:app_linkster/application/link_builder/link_builder.dart';
import 'package:logger/logger.dart';

/// The `LinkBuilderFactory` class is responsible for creating link builders based on the type of the app.
///
/// It provides a `getLinkBuilder` method to create a link builder for a given URL.
/// This method first identifies the type of the app based on the URL.
/// It then returns a link builder for the identified app type.
///
/// The class also provides a private `_identifyAppType` method to identify the type of the app based on the URL.
/// This method uses a map of domain names to app types to identify the app type.
/// If the URL contains a domain name that matches an entry in the map, the corresponding app type is returned.
/// If the URL does not contain a matching domain name, an exception is thrown.
class LinkBuilderFactory {
  /// Returns a link builder for the given URL.
  ///
  /// This method first identifies the type of the app based on the URL.
  /// It then returns a link builder for the identified app type.
  ///
  /// @param url The URL for which to create a link builder.
  /// @param logger The logger to use for logging.
  /// @param deeplinkCreator The deeplink creator to use for creating deeplinks.
  /// @return A link builder for the given URL.
  /// @throws Exception If no link builder can be found for the given URL.
  static LinkBuilder getLinkBuilder(
      String url, Logger logger, DeeplinkCreator deeplinkCreator) {

    final type = _identifyAppType(url);
    switch (type) {
      case AppType.facebook:
        return FacebookLinkBuilder(deeplinkCreator);
      case AppType.twitter:
        return TwitterLinkBuilder(deeplinkCreator);
      case AppType.instagram:
        return InstagramLinkBuilder(deeplinkCreator);
      case AppType.tiktok:
        return TikTokLinkBuilder(deeplinkCreator);
      case AppType.youtube:
        return YoutubeLinkBuilder(deeplinkCreator);
      case AppType.linkedin:
        return LinkedInLinkBuilder(deeplinkCreator);
      default:
        logger.e("Unknown link type for url: $url");
    }
    // Conditions for other platforms
    throw Exception("No link builder found for the given URL");
  }

  /// Identifies the type of the app based on the URL.
  ///
  /// This method uses a map of domain names to app types to identify the app type.
  /// If the URL contains a domain name that matches an entry in the map, the corresponding app type is returned.
  ///
  /// @param url The URL for which to identify the app type.
  /// @return The identified app type.
  /// @throws Exception If the app type cannot be identified.
  static AppType _identifyAppType(String url) {
    const Map<String, AppType> domainToType = {
      "facebook": AppType.facebook,
      "twitter.com": AppType.twitter,
      "instagram.com": AppType.instagram,
      "tiktok.com": AppType.tiktok,
      "youtube.com": AppType.youtube,
      "linkedin.com": AppType.linkedin,
    };

    final result =domainToType.entries
        .where((entry) => url.contains(entry.key));
    if (result.isEmpty) {
      throw Exception("Unknown link type for url: $url");
    }
    return result.first.value;
  }
}



