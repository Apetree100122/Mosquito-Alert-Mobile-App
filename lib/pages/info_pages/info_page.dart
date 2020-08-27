import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPage extends StatelessWidget {
  final String url;
  final bool localHtml;

  InfoPage(this.url, {this.localHtml = false});

  WebViewController _controller;

  StreamController<bool> loadingStream = StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Image.asset(
              'assets/img/ic_logo.png',
              height: 45,
            ),
          ),
          body: Builder(builder: (BuildContext context) {
            return WebView(
              initialUrl: localHtml ? 'about:blank' : url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                localHtml ? _loadHtmlFromAssets() : null;
              },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              onPageFinished: (String url) {
                loadingStream.add(false);
              },
              gestureNavigationEnabled: true,
            );
          }),
        ),
        StreamBuilder<bool>(
            stream: loadingStream.stream,
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot<bool> snapLoading) {
              if (snapLoading.data == true)
                return Container(
                  child: Center(
                    child: Utils.loading(true),
                  ),
                );
              return Container();
            }),
      ],
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString(url);
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
