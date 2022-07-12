import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/extensions/exception_extension.dart';
import 'package:pick_books/model/use_cases/auth/email/sign_in_with_email_and_password.dart';
import 'package:pick_books/presentation/pages/auth/sign_up_page.dart';
import 'package:pick_books/presentation/pages/main/main_page.dart';
import 'package:pick_books/utils/logger.dart';

class SignInPage extends HookConsumerWidget {
  SignInPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static Future<void> show(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true)
        .pushReplacement<MaterialPageRoute<dynamic>, void>(
      PageTransition(
        type: PageTransitionType.fade,
        child: SignInPage(),
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
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'メールアドレス'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'パスワード',
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(signInWithEmailAndPasswordProvider)(
                    _emailController.text,
                    _passwordController.text,
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
              child: const Text('ログイン'),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                SignUpPage.show(context);
              },
              child: const Text('アカウントを作成'),
            ),
          ],
        ),
      ),
    );
  }
}
