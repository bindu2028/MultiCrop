import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Molecular3DViewer extends StatefulWidget {
  final int cid;

  const Molecular3DViewer({Key? key, required this.cid}) : super(key: key);

  @override
  State<Molecular3DViewer> createState() => _Molecular3DViewerState();
}

class _Molecular3DViewerState extends State<Molecular3DViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>
  <script src="https://3Dmol.org/build/3Dmol-min.js"></script>
  <style>
    body { margin: 0; padding: 0; background-color: #ffffff; overflow: hidden; }
    #container { width: 100vw; height: 100vh; position: relative; }
    .loading { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); font-family: sans-serif; color: #888; }
  </style>
</head>
<body>
  <div id="loading" class="loading">Loading 3D Model...</div>
  <div id="container"></div>
  <script>
    let element = document.getElementById('container');
    let config = { backgroundColor: 'white' };
    let viewer = \$3Dmol.createViewer( element, config );
    \$3Dmol.download("cid:${widget.cid}", viewer, {}, function() {
        document.getElementById('loading').style.display = 'none';
        viewer.setStyle({}, {stick:{radius:0.15}, sphere:{scale:0.3}});
        viewer.zoomTo();
        viewer.render();
        // Notify flutter it is done
        if (window.flutter_inappwebview) {
           window.flutter_inappwebview.callHandler('modelLoaded');
        }
    });
  </script>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: WebViewWidget(
              controller: _controller,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.threed_rotation, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Interactive 3D',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
