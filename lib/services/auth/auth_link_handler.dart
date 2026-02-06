import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

typedef AuthLinkEmailProvider = String? Function();
typedef AuthLinkCallback = Future<void> Function(
  Uri link,
  String email,
  BuildContext context,
);

enum AuthLinkDecision {
  ignored,
  needsEmail,
  handled,
}

class AuthLinkHandler {
  AuthLinkHandler({
    required FirebaseAuth auth,
    required AuthLinkEmailProvider emailProvider,
    required AuthLinkCallback onValidLink,
  })  : _auth = auth,
        _emailProvider = emailProvider,
        _onValidLink = onValidLink;

  final FirebaseAuth _auth;
  final AuthLinkEmailProvider _emailProvider;
  final AuthLinkCallback _onValidLink;
  String? _lastHandledLink;

  Future<AuthLinkDecision> tryHandle(
    Uri uri, {
    required BuildContext context,
  }) async {
    final emailLink = _extractEmailLink(uri);
    if (emailLink == null || emailLink.isEmpty) {
      return AuthLinkDecision.ignored;
    }

    if (!_auth.isSignInWithEmailLink(emailLink)) {
      return AuthLinkDecision.ignored;
    }

    if (_lastHandledLink == emailLink) {
      return AuthLinkDecision.ignored;
    }

    final email = _emailProvider();
    if (email == null || email.isEmpty) {
      return AuthLinkDecision.needsEmail;
    }

    _lastHandledLink = emailLink;
    await _onValidLink(Uri.parse(emailLink), email, context);
    return AuthLinkDecision.handled;
  }

  Future<AuthLinkDecision> handleWithEmail(
    Uri uri, {
    required String email,
    required BuildContext context,
  }) async {
    final emailLink = _extractEmailLink(uri);
    if (emailLink == null || emailLink.isEmpty) {
      return AuthLinkDecision.ignored;
    }

    if (!_auth.isSignInWithEmailLink(emailLink)) {
      return AuthLinkDecision.ignored;
    }

    if (_lastHandledLink == emailLink) {
      return AuthLinkDecision.ignored;
    }

    _lastHandledLink = emailLink;
    await _onValidLink(Uri.parse(emailLink), email, context);
    return AuthLinkDecision.handled;
  }

  String? _extractEmailLink(Uri uri) {
    final linkParam = uri.queryParameters['link'];
    if (linkParam != null && linkParam.isNotEmpty) {
      return linkParam;
    }
    return uri.toString();
  }
}
