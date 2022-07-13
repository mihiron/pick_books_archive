import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/extensions/exception_extension.dart';
import 'package:pick_books/gen/colors.gen.dart';
import 'package:pick_books/model/entities/app/book.dart';
import 'package:pick_books/model/use_cases/app/book_controller.dart';
import 'package:pick_books/presentation/custom_hooks/use_effect_once.dart';
import 'package:pick_books/presentation/custom_hooks/use_form_field_state_key.dart';
import 'package:pick_books/presentation/widgets/dialogs/show_content_dialog.dart';
import 'package:pick_books/presentation/widgets/show_indicator.dart';
import 'package:pick_books/presentation/widgets/thumbnail.dart';
import 'package:pick_books/utils/logger.dart';

Future<void> showEditBookDialog(
  BuildContext context, {
  Book? data,
}) =>
    showContentDialog<void>(
      context: context,
      contentWidget: _Dialog(data),
    );

class _Dialog extends HookConsumerWidget {
  const _Dialog(
    this.data,
  );

  final Book? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// カスタムフック
    final titleKey = useFormFieldStateKey();
    final urlKey = useFormFieldStateKey();
    final descriptionKey = useFormFieldStateKey();

    /// カスタムフック
    useEffectOnce(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        titleKey.currentState?.didChange(data?.title);
        urlKey.currentState?.didChange(data?.url);
        descriptionKey.currentState?.didChange(data?.description);
      });
      return null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Center(
          child: Text('本を登録'),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Thumbnail(
              width: 120,
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: titleKey,
          initialValue: data?.title,
          style: context.bodyStyle,
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'タイトルを入力してください' : null,
          decoration: const InputDecoration(
            labelText: 'タイトル',
            hintText: '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
        TextFormField(
          key: urlKey,
          initialValue: data?.url,
          style: context.bodyStyle,
          decoration: const InputDecoration(
            labelText: 'URL',
            hintText: '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
        TextFormField(
          key: descriptionKey,
          initialValue: data?.description,
          style: context.bodyStyle,
          decoration: const InputDecoration(
            labelText: '説明',
            hintText: '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: ColorName.primary,
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              if (titleKey.currentState?.validate() != true) {
                return;
              }
              final title = titleKey.currentState?.value?.trim() ?? '';
              final url = urlKey.currentState?.value?.trim() ?? '';
              final description =
                  descriptionKey.currentState?.value?.trim() ?? '';
              try {
                context.hideKeyboard();
                showIndicator(context);
                if (data != null) {
                  /// 更新
                  await ref.read(bookProvider.notifier).update(
                        data!.copyWith(
                          title: title,
                          url: url,
                          description: description,
                        ),
                      );
                  context.showSnackBar('更新しました');
                } else {
                  /// 新規作成
                  await ref.read(bookProvider.notifier).create(
                        title,
                        url,
                        description,
                      );
                  context.showSnackBar('登録しました');
                }
                dismissIndicator(context);

                Navigator.pop(context);
              } on Exception catch (e) {
                logger.shout(e);
                dismissIndicator(context);
                context.showSnackBar(
                  e.errorMessage,
                  backgroundColor: Colors.grey,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '登録',
                style: context.bodyStyle
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
