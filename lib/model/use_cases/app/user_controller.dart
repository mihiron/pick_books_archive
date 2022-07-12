import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/exceptions/app_exception.dart';
import 'package:pick_books/model/entities/app/user.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'package:pick_books/utils/provider.dart';

final userProvider = StateNotifierProvider<UserController, List<User>>((ref) {
  ref.watch(authStateProvider);
  return UserController(ref.read);
});

class UserController extends StateNotifier<List<User>> {
  UserController(
    this._read,
  ) : super([]) {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      return;
    }
  }

  final Reader _read;

  FirebaseAuthRepository get _firebaseAuthRepository =>
      _read(firebaseAuthRepositoryProvider);

  DocumentRepository get _documentRepository =>
      _read(documentRepositoryProvider);

  /// 作成
  Future<void> create(String email) async {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    final now = DateTime.now();
    final data = User(
      userId: userId,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
    await _documentRepository.save(
      User.docPath(userId),
      data: data.toCreateDoc,
    );
    state = [data, ...state];
  }

  /// 更新
  Future<void> update(User user) async {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    final data = user.copyWith(updatedAt: DateTime.now());
    await _documentRepository.update(
      User.docPath(userId),
      data: data.toUpdateDoc,
    );
    state = state
        .map(
          (e) => e.userId == user.userId ? user : e,
        )
        .toList();
  }
}
