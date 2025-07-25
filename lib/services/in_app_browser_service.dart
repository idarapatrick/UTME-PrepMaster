import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppBrowserService {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  Future<void> openBrowser(String url) async {
    final WebUri webUri = WebUri(url);

    await browser.open(
      url: webUri,
      settings: ChromeSafariBrowserSettings(
      ),
    );
  }
}
