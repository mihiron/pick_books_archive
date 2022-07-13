import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/exceptions/app_exception.dart';
import 'package:pick_books/model/entities/app/user.dart';
import 'package:pick_books/model/entities/storage_file/storage_file.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firebase_storage/firebase_storage_repository.dart';
import 'package:pick_books/model/repositories/firebase_storage/mime_type.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'package:pick_books/utils/uuid_generator.dart';

import 'fetch_profile.dart';

final saveProfileImageProvider = Provider((ref) => SaveProfileImage(ref.read));

class SaveProfileImage {
  SaveProfileImage(this._read);
  final Reader _read;

  Future<void> call(Uint8List file) async {
    final userId = _read(firebaseAuthRepositoryProvider).loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }

    /// 画像をCloudStorageへ保存
    final filename = UuidGenerator.create();
    final imagePath = User.imagePath(userId, filename);
    const mimeType = MimeType.applicationOctetStream;
    final imageUrl = await _read(firebaseStorageRepositoryProvider).save(
      file,
      path: imagePath,
      mimeType: mimeType,
    );

    /// 画像情報をFirestoreへ保存
    final profile = _read(fetchProfileProvider).value;
    final newProfile = profile?.copyWith(
      image: StorageFile(
        url: imageUrl,
        path: imagePath,
        mimeType: mimeType.value,
      ),
    );
    await _read(documentRepositoryProvider).save(
      User.docPath(userId),
      data: newProfile!.toImageOnly,
    );

    /// 古い画像をCloudStorageから削除
    final oldImage = profile!.image;
    if (oldImage != null) {
      await _read(firebaseStorageRepositoryProvider).delete(oldImage.path);
    }
  }
}
