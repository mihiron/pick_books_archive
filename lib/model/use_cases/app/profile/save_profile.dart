import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/exceptions/app_exception.dart';
import 'package:pick_books/model/entities/app/user.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'fetch_profile.dart';

final saveProfileProvider = Provider((ref) => SaveProfile(ref.read));

class SaveProfile {
  SaveProfile(this._read);
  final Reader _read;

  Future<void> call({
    String? name,
  }) async {
    final userId = _read(firebaseAuthRepositoryProvider).loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    final profile = _read(fetchProfileProvider).value;
    final email = profile!.email;
    final newProfile = profile.copyWith(
      name: name,
      email: email,
    );
    await _read(documentRepositoryProvider).save(
      User.docPath(userId),
      data: newProfile.toDocWithNotImage,
    );
  }
}
