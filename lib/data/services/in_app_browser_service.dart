import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppBrowserService {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  Future<void> openBrowser(String url) async {
    final webUri = WebUri(url);

    await browser.open(
      url: webUri,
      settings: ChromeSafariBrowserSettings(
        shareState: ChromeSafariBrowserShareState.DEFAULT,
      ),
    );
  }
}


