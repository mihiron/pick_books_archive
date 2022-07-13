import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/extensions/context_extension.dart';
import 'package:pick_books/extensions/exception_extension.dart';
import 'package:pick_books/model/use_cases/app/book_controller.dart';
import 'package:pick_books/presentation/custom_hooks/use_effect_once.dart';
import 'package:pick_books/presentation/custom_hooks/use_refresh_controller.dart';
import 'package:pick_books/presentation/widgets/smart_refresher_custom.dart';
import 'package:pick_books/presentation/widgets/thumbnail.dart';
import 'package:pick_books/utils/logger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'show_edit_book_dialog.dart';

class BookPage extends HookConsumerWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bookProvider);
    final scrollController = useScrollController();

    /// カスタムフック
    final refreshController = useRefreshController();

    /// カスタムフック
    useEffectOnce(() {
      Future(() async {
        try {
          await ref.read(bookProvider.notifier).fetch();
        } on Exception catch (e) {
          logger.shout(e);
          context.showSnackBar(
            e.errorMessage,
            backgroundColor: Colors.grey,
          );
        }
      });
      return null;
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Scrollbar(
        controller: scrollController,
        child: SmartRefresher(
          header: const SmartRefreshHeader(),
          footer: const SmartRefreshFooter(),
          // ignore: avoid_redundant_argument_values
          enablePullDown: true,
          enablePullUp: true,
          controller: refreshController,
          physics: const BouncingScrollPhysics(),
          onRefresh: () async {
            try {
              await ref.read(bookProvider.notifier).fetch();
            } on Exception catch (e) {
              logger.shout(e);
              context.showSnackBar(
                e.errorMessage,
                backgroundColor: Colors.grey,
              );
            }
            refreshController.refreshCompleted();
          },
          onLoading: () async {
            try {
              await ref.read(bookProvider.notifier).fetchMore();
            } on Exception catch (e) {
              logger.shout(e);
              context.showSnackBar(
                e.errorMessage,
                backgroundColor: Colors.grey,
              );
            }
            refreshController.loadComplete();
          },
          child: ListView.builder(
            controller: scrollController,
            itemBuilder: (BuildContext context, int index) {
              final data = items[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        final docId = data.bookId;
                        if (docId == null) {
                          return;
                        }
                        final result = await showOkCancelAlertDialog(
                          context: context,
                          title: '削除しますか？',
                        );
                        if (result == OkCancelResult.cancel) {
                          return;
                        }
                        try {
                          await ref.read(bookProvider.notifier).remove(docId);
                          context.showSnackBar('削除しました');
                        } on Exception catch (e) {
                          logger.shout(e);
                          context.showSnackBar(
                            e.errorMessage,
                            backgroundColor: Colors.grey,
                          );
                        }
                      },
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: '削除',
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    title: Text(
                      data.title ?? '',
                      style: context.bodyStyle,
                    ),
                    subtitle: Text(
                      data.dateLabel,
                      style: context.smallStyle,
                    ),
                    trailing: const Thumbnail(
                      width: 40,
                    ),
                    onTap: () {
                      showEditBookDialog(context, data: data);
                    },
                  ),
                ),
              );
            },
            itemCount: items.length,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showEditBookDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
