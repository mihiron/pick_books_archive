import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/exceptions/app_exception.dart';
import 'package:pick_books/model/entities/app/book.dart';
import 'package:pick_books/model/repositories/firebase_auth/firebase_auth_repository.dart';
import 'package:pick_books/model/repositories/firestore/collection_paging_repository.dart';
import 'package:pick_books/model/repositories/firestore/document.dart';
import 'package:pick_books/model/repositories/firestore/document_repository.dart';
import 'package:pick_books/utils/provider.dart';

final bookProvider = StateNotifierProvider<BookController, List<Book>>((ref) {
  ref.watch(authStateProvider);
  return BookController(ref.read);
});

class BookController extends StateNotifier<List<Book>> {
  BookController(
    this._read,
  ) : super([]) {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      return;
    }
    _collectionPagingRepository = _read(
      bookPagingProvider(
        CollectionParam<Book>(
          query: Document.colRef(
            Book.collectionPath(userId),
          ).orderBy('createdAt', descending: true),
          limit: 20,
          decode: Book.fromJson,
        ),
      ),
    );
  }

  final Reader _read;

  FirebaseAuthRepository get _firebaseAuthRepository =>
      _read(firebaseAuthRepositoryProvider);

  DocumentRepository get _documentRepository =>
      _read(documentRepositoryProvider);

  CollectionPagingRepository<Book>? _collectionPagingRepository;

  /// 一覧取得
  Future<void> fetch() async {
    final repository = _collectionPagingRepository;
    if (repository == null) {
      return;
    }
    final data = await repository.fetch(
      fromCache: (cache) {
        /// キャッシュから即時反映する
        state = cache.map((e) => e.entity).whereType<Book>().toList();
      },
    );
    state = data.map((e) => e.entity).whereType<Book>().toList();
  }

  /// ページング取得
  Future<void> fetchMore() async {
    final repository = _collectionPagingRepository;
    if (repository == null) {
      return;
    }
    final data = await repository.fetchMore();
    if (data.isEmpty) {
      return;
    }
    state = [
      ...state.toList(),
      ...data.map((e) => e.entity).whereType<Book>().toList(),
    ];
  }

  /// 作成
  Future<void> create(String title, String? url, String? description) async {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    final ref = Document.docRef(Book.collectionPath(userId));
    final now = DateTime.now();
    final data = Book(
      bookId: ref.id,
      title: title,
      url: url,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    await _documentRepository.save(
      Book.docPath(userId, ref.id),
      data: data.toCreateDoc,
    );
    state = [data, ...state];
  }

  /// 更新
  Future<void> update(Book book) async {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    final docId = book.bookId;
    if (docId == null) {
      return;
    }
    final data = book.copyWith(updatedAt: DateTime.now());
    await _documentRepository.update(
      Book.docPath(userId, docId),
      data: data.toUpdateDoc,
    );
    state = state
        .map(
          (e) => e.bookId == book.bookId ? book : e,
        )
        .toList();
  }

  /// 削除
  Future<void> remove(String docId) async {
    final userId = _firebaseAuthRepository.loggedInUserId;
    if (userId == null) {
      throw AppException(title: 'ログインしてください');
    }
    await _documentRepository.remove(Book.docPath(userId, docId));
    state = state
        .where(
          (e) => e.bookId != docId,
        )
        .toList();
  }
}
