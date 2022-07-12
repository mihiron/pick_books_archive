import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/extensions/exception_extension.dart';
import 'package:pick_books/model/use_cases/auth/email/sign_in_with_email_and_password.dart';
import 'package:pick_books/presentation/pages/main/main_page.dart';
import 'package:pick_books/utils/logger.dart';

class EmailCheckPage extends HookConsumerWidget {
  const EmailCheckPage({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  static Future<void> show(
    BuildContext context,
    String email,
    String password,
  ) async {
    await Navigator.of(context, rootNavigator: true)
        .pushReplacement<MaterialPageRoute<dynamic>, void>(
      PageTransition(
        type: PageTransitionType.fade,
        child: EmailCheckPage(
          email: email,
          password: password,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Center(
                child: Text(email),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: const Center(
                child: Text('に確認メールを送信しました。'),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(signInWithEmailAndPasswordProvider)(
                    email,
                    password,
                  );
                  unawaited(MainPage.show(context));
                } on Exception catch (e) {
                  logger.shout(e);
                  context.showSnackBar(
                    e.errorMessage,
                    backgroundColor: Colors.grey,
                  );
                }
              },
              child: const Text('メール確認完了'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
