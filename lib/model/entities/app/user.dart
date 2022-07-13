import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../model/entities/storage_file/storage_file.dart';
import '../../../model/repositories/firestore/document.dart';
import '../../converters/date_time_timestamp_converter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String email,
    String? name,
    StorageFile? image,
    @Default(0) int bookCount,
    @DateTimeTimestampConverter() DateTime? createdAt,
    @DateTimeTimestampConverter() DateTime? updatedAt,
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  static String get collectionPath => 'sample/v1/users';
  static CollectionReference<SnapType> colRef() =>
      Document.colRef(collectionPath);

  static String docPath(String id) => '$collectionPath/$id';
  static DocumentReference<SnapType> docRef(String id) =>
      Document.docRefWithDocPath(docPath(id));

  static String imagePath(
    String id,
    String filename,
  ) =>
      '${docPath(id)}/image/$filename';

  Map<String, dynamic> get toCreateDoc => <String, dynamic>{
        'userId': userId,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> get toUpdateDoc => <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> get toDocWithNotImage {
    final data = <String, dynamic>{
      ...toJson(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }..remove('image');
    return data;
  }

  Map<String, dynamic> get toImageOnly => <String, dynamic>{
        'userId': userId,
        'image': image?.toJson(),
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
