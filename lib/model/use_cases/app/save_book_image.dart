import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/exceptions/app_exception.dart';
import 'package:pick_books/model/entities/app/book.dart';
import 'package:pick_books/model/entities/storage_file/storage_file.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firebase_storage/firebase_storage_repository.dart';
import 'package:pick_books/model/repositories/firebase_storage/mime_type.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'package:pick_books/model/use_cases/app/book_controller.dart';
import 'package:pick_books/utils/uuid_generator.dart';

final saveBookImageProvider = Provider((ref) => SaveBookImage(ref.read));

class SaveBookImage {
  SaveBookImage(this._read);
  final Reader _read;

  Future<void> call(Uint8List file, String bookId) async {
    final userId = _read(firebaseAuthRepositoryProvider).loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }

    /// 画像をCloudStorageへ保存
    final filename = UuidGenerator.create();
    final imagePath = Book.imagePath(userId, bookId, filename);
    const mimeType = MimeType.applicationOctetStream;
    final imageUrl = await _read(firebaseStorageRepositoryProvider).save(
      file,
      path: imagePath,
      mimeType: mimeType,
    );

    /// 画像情報をFirestoreへ保存
    final oldBook = await _read(bookProvider.notifier).fetchOne(bookId);
    final newBook = oldBook?.copyWith(
      image: StorageFile(
        url: imageUrl,
        path: imagePath,
        mimeType: mimeType.value,
      ),
    );
    await _read(documentRepositoryProvider).save(
      Book.docPath(userId, bookId),
      data: newBook!.toImageOnly,
    );

    /// 古い画像をCloudStorageから削除
    final oldImage = oldBook!.image;
    if (oldImage != null) {
      await _read(firebaseStorageRepositoryProvider).delete(oldImage.path);
    }
  }
}
