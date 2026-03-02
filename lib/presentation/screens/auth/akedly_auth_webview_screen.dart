import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_constants.dart';

class AkedlyAuthCallbackResult {
  final String status;
  final String? attemptId;
  final String? transactionId;

  const AkedlyAuthCallbackResult({
    required this.status,
    this.attemptId,
    this.transactionId,
  });

  static const cancelled = AkedlyAuthCallbackResult(status: 'cancelled');
}

class AkedlyAuthWebViewScreen extends StatefulWidget {
  const AkedlyAuthWebViewScreen({
    super.key,
    required this.iframeUrl,
  });

  final String iframeUrl;

  @override
  State<AkedlyAuthWebViewScreen> createState() => _AkedlyAuthWebViewScreenState();
}

class _AkedlyAuthWebViewScreenState extends State<AkedlyAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (request) {
            final result = _parseCallbackResult(request.url);
            if (result != null) {
              Navigator.of(context).pop(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.iframeUrl));
  }

  AkedlyAuthCallbackResult? _parseCallbackResult(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    final normalized = value.toLowerCase();
    final callbackPrefix = AppConstants.akedlyMobileCallbackUrl.toLowerCase();
    final isMobileCallback = normalized.startsWith(callbackPrefix);
    final isWebCallback = normalized.contains('/auth/callback');

    if (!isMobileCallback && !isWebCallback) {
      return null;
    }

    final status = (uri.queryParameters['status']
            ?? uri.queryParameters['eventStatus']
            ?? uri.queryParameters['event_status']
            ?? '')
        .toLowerCase();

    final attemptId = uri.queryParameters['attemptId']
        ?? uri.queryParameters['attempt_id'];
    final transactionId = uri.queryParameters['transactionId']
        ?? uri.queryParameters['transaction_id'];

    return AkedlyAuthCallbackResult(
      status: status.isEmpty ? 'failed' : status,
      attemptId: attemptId,
      transactionId: transactionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(AkedlyAuthCallbackResult.cancelled),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}
