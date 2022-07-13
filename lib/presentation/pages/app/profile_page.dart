import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/model/use_cases/app/profile/fetch_profile.dart';
import 'package:pick_books/presentation/pages/app/show_edit_profile_dialog.dart';
import 'package:pick_books/presentation/pages/image_viewer/image_viewer.dart';
import 'package:pick_books/presentation/widgets/thumbnail.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(fetchProfileProvider).value;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleThumbnail(
              size: 96,
              url: profile?.image?.url,
              onTap: () {
                final url = profile?.image?.url;
                if (url != null) {
                  ImageViewer.show(context, urls: [url]);
                }
              },
            ),
            const SizedBox(height: 30),
            Text(
              profile?.name ?? '-',
              style: context.bodyStyle,
            ),
            TextButton(
              onPressed: () {
                showEditProfileDialog(context: context);
              },
              child: const Text('編集'),
            ),
            const SizedBox(height: 20),
            Text('登録した本の数：${profile?.bookCount ?? '0'}'),
          ],
        ),
      ),
    );
  }
}
