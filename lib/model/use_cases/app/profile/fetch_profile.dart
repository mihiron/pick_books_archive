import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/model/entities/app/user.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'package:pick_books/utils/provider.dart';

final fetchProfileProvider = StreamProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState == AuthState.noSignIn) {
    return Stream.value(null);
  }
  final userId = ref.read(firebaseAuthRepositoryProvider).loggedInUserId;
  if (userId == null) {
    return Stream.value(null);
  }
  return ref
      .read(documentRepositoryProvider)
      .snapshots(User.docPath(userId))
      .map((event) {
    final data = event.data();
    return data != null ? User.fromJson(data) : null;
  });
});
