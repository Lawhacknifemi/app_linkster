
import 'package:app_linkster/application/deep_link_creator.dart';
import 'package:app_linkster/model/app_type.dart';

abstract class LinkBuilder {
  AppType get appType;
  Future<String?> buildLink(String url);
}

class FacebookLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  FacebookLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String? parsedUrl = await deeplinkCreator.getDeepLink(
      url: url.replaceFirst('www.', ''),
      idExtractionRegex:
      r'<meta property="al:android:url" content="fb://profile/(\d+)"',
      androidDeepLinkTemplate: 'fb://profile/{id}',
      iosDeepLinkTemplate: 'fb://profile/{id}',
    );

    return parsedUrl ;
  }

  @override
  AppType get appType => AppType.facebook;
}

class TwitterLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  TwitterLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String parsedUrl =
        "x://user/?screen_name=${Uri.parse(url).pathSegments.lastWhere((item) => item.isNotEmpty)}";
    return parsedUrl;
  }

  @override
  AppType get appType => AppType.twitter;
}

class InstagramLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  InstagramLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String parsedUrl =
        "instagram://user?username=${Uri.parse(url).pathSegments.lastWhere((item) => item.isNotEmpty)}";
    return parsedUrl;
  }

  @override
  AppType get appType => AppType.instagram;
}

class TikTokLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  TikTokLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String? parsedUrl = await deeplinkCreator.getDeepLink(
        url: url,
        idExtractionRegex: r',"authorId":"(\d+)"',
        androidDeepLinkTemplate: 'snssdk1233://user/profile/{id}',
        iosDeepLinkTemplate: 'snssdk1233://user/profile/{id}');

    return parsedUrl ;
  }

  @override
  AppType get appType => AppType.tiktok;
}

class YoutubeLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  YoutubeLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String parsedUrl =
        "youtube:/${"${Uri.parse(url).path}?${Uri.parse(url).query}"}";
    return parsedUrl;
  }

  @override
  AppType get appType => AppType.youtube;
}

class LinkedInLinkBuilder implements LinkBuilder {
  final DeeplinkCreator deeplinkCreator;

  LinkedInLinkBuilder(this.deeplinkCreator);

  @override
  Future<String?> buildLink(String url) async {
    String parsedUrl = "linkedin:/${Uri.parse(url).path}";
    return parsedUrl;
  }

  @override
  AppType get appType => AppType.linkedin;
}

