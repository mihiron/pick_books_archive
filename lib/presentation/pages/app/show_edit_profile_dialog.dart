import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/gen/colors.gen.dart';
import 'package:pick_books/model/use_cases/app/profile/fetch_profile.dart';
import 'package:pick_books/model/use_cases/app/profile/save_profile.dart';
import 'package:pick_books/model/use_cases/app/profile/save_profile_image.dart';
import 'package:pick_books/model/use_cases/image_compress.dart';
import 'package:pick_books/presentation/custom_hooks/use_effect_once.dart';
import 'package:pick_books/presentation/custom_hooks/use_form_field_state_key.dart';
import 'package:pick_books/presentation/pages/image_viewer/image_viewer.dart';
import 'package:pick_books/presentation/widgets/color_circle.dart';
import 'package:pick_books/presentation/widgets/dialogs/show_content_dialog.dart';
import 'package:pick_books/presentation/widgets/rounded_button.dart';
import 'package:pick_books/presentation/widgets/sheets/show_photo_and_crop_bottom_sheet.dart';
import 'package:pick_books/presentation/widgets/show_indicator.dart';
import 'package:pick_books/presentation/widgets/thumbnail.dart';
import 'package:pick_books/utils/logger.dart';

Future<void> showEditProfileDialog({
  required BuildContext context,
}) async {
  return showContentDialog(
    context: context,
    contentWidget: const _Dialog(),
  );
}

class _Dialog extends HookConsumerWidget {
  const _Dialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(fetchProfileProvider).value;

    /// カスタムフック
    final nameFormKey = useFormFieldStateKey();

    /// カスタムフック
    useEffectOnce(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameFormKey.currentState?.didChange(profile?.name);
      });
      return null;
    });

    return Column(
      children: [
        Stack(
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
            Positioned(
              right: 0,
              bottom: 0,
              child: ColorCircleIcon(
                onTap: () async {
                  final selectedImage = await showPhotoAndCropBottomSheet(
                    context,
                    title: 'プロフィール画像',
                  );
                  if (selectedImage == null) {
                    return;
                  }

                  logger.info(selectedImage.readAsBytesSync().length);

                  /// 圧縮して設定
                  final compressImage =
                      await ref.read(imageCompressProvider)(selectedImage);
                  if (compressImage == null) {
                    return;
                  }
                  logger.info(compressImage.lengthInBytes);
                  try {
                    showIndicator(context);
                    await ref
                        .read(saveProfileImageProvider)
                        .call(compressImage);
                  } on Exception catch (e) {
                    logger.shout(e);
                    await showOkAlertDialog(
                      context: context,
                      title: '画像を保存できませんでした',
                    );
                  } finally {
                    dismissIndicator(context);
                  }
                },
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 入力フォーム
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('名前', style: context.bodyStyle),
            ),
            TextFormField(
              style: context.bodyStyle,
              decoration: const InputDecoration(
                hintText: '名前を入力してください',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
                isDense: true,
                counterText: '',
              ),
              key: nameFormKey,
              initialValue: profile?.name,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? '名前を入力してください'
                  : null,
              maxLength: 32,
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: RoundedButton(
            elevation: 2,
            onTap: () async {
              context.hideKeyboard();
              if (!nameFormKey.currentState!.validate()) {
                return;
              }
              final name = nameFormKey.currentState?.value?.trim() ?? '';
              try {
                showIndicator(context);
                await ref.read(saveProfileProvider).call(
                      name: name,
                    );
                dismissIndicator(context);
                context.showSnackBar('保存しました');
                Navigator.of(context).pop();
              } on Exception catch (e) {
                logger.shout(e);
                dismissIndicator(context);
                await showOkAlertDialog(context: context, title: '保存できませんでした');
              }
            },
            color: ColorName.primary,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '保存する',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
