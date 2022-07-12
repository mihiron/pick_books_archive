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
    final textKey = useFormFieldStateKey();

    /// カスタムフック
    useEffectOnce(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        textKey.currentState?.didChange(data?.title);
      });
      return null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            key: textKey,
            initialValue: data?.title,
            style: context.bodyStyle,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? '正しい値を入力してください'
                : null,
            decoration: const InputDecoration(
              labelText: 'テキスト入力',
              hintText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 3,
            maxLength: 1024,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: ColorName.primary,
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              if (textKey.currentState?.validate() != true) {
                return;
              }
              final title = textKey.currentState?.value?.trim() ?? '';
              try {
                context.hideKeyboard();
                showIndicator(context);
                if (data != null) {
                  /// 更新
                  await ref
                      .read(bookProvider.notifier)
                      .update(data!.copyWith(title: title));
                  context.showSnackBar('更新しました');
                } else {
                  /// 新規作成
                  await ref.read(bookProvider.notifier).create(title, '', '');
                  context.showSnackBar('作成しました');
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
                '投稿する',
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
