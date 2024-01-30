library app_linkster;

export 'model/model.dart';
export 'application/application.dart';
import 'dart:io';
import 'package:app_linkster/application/deep_link_creator.dart';
import 'package:app_linkster/application/kv_store.dart';
import 'package:app_linkster/application/link_builder/link_builder_factory.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The `AppLinksterLauncher` class is responsible for launching URLs.
///
/// It uses a singleton pattern to ensure that only one instance of the class is created.
/// The class uses a `DeeplinkCreator`, `KeyValueStore`, and `Logger` to perform its operations.
/// If these dependencies are not provided during instantiation, default instances are created.
///
/// The class provides a `launchThisGuy` method to launch a URL.
/// This method first retrieves a link builder for the given URL and uses it to build a parsed URL.
/// If a cached version of the URL exists in the key-value store, it is used instead of building a new one.
/// The parsed URL is then stored in the key-value store for future use.
///
/// The method then determines the appropriate method to launch the URL based on the operating system and whether the parsed URL can be launched.
/// If the parsed URL cannot be launched, the original URL is used instead.
///
/// The class also provides a private `_determineOSAndLaunchUrl` method to determine the appropriate method to launch the URL and launch it.
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

  /// Launches a URL using the appropriate method based on the operating system and whether the URL can be launched.
  ///
  /// This function first retrieves a link builder for the given URL and uses it to build a parsed URL.
  /// If a cached version of the URL exists in the key-value store, it is used instead of building a new one.
  /// The parsed URL is then stored in the key-value store for future use.
  ///
  /// The function then determines the appropriate method to launch the URL based on the operating system and whether the parsed URL can be launched.
  /// If the parsed URL cannot be launched, the original URL is used instead.
  ///
  /// @param url The URL to be launched.
  /// @param fallbackLaunchMode The launch mode to be used if the parsed URL cannot be launched. Defaults to LaunchMode.externalApplication.
  /// @return A Future that completes when the URL has been launched.

  Future<void> launchThisGuy(
    String url, {
    LaunchMode fallbackLaunchMode = LaunchMode.externalApplication,
  }) async {
    final builder =
        LinkBuilderFactory.getLinkBuilder(url, logger, deeplinkCreator);
    final cachedUrl = await keyValueStore.get(url);
    logger.d("Cached URL: $cachedUrl");
    final parserUrl = cachedUrl ?? await builder.buildLink(url);
    logger.d("Parsed URL: $parserUrl");
    keyValueStore.put(url, parserUrl);
    await _determineOSAndLaunchUrl(
      url: url,
      parsedUrl: parserUrl,
      fallbackLaunchMode: fallbackLaunchMode,
    );
  }

  Future _determineOSAndLaunchUrl({
    required String url,
    String? parsedUrl,
    required LaunchMode fallbackLaunchMode,
  }) async {
    final canLaunch =
        parsedUrl != null ? await canLaunchUrlString(parsedUrl) : false;
    logger.d("Can launch: $canLaunch");
    String urlToLaunch = canLaunch ? parsedUrl : url;
    logger.d("Determined URL: $urlToLaunch");
    final appLaunchMode = Platform.isAndroid
        ? LaunchMode.externalApplication
        : LaunchMode.platformDefault;
    final launchMode = canLaunch ? appLaunchMode : fallbackLaunchMode;

    launchUrlString(urlToLaunch, mode: launchMode);
  }
}
