import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
const db = admin.firestore();

// 登録時に件数をインクリメント
exports.bookCountUp = functions.region("asia-northeast1").firestore
    .document("sample/v1/users/{userId}/books/{bookId}")
    .onCreate((change, context) => {
      const userId = context.params.userId;
      const FieldValue = admin.firestore.FieldValue;
      const countsRef = db.collection("sample/v1/users").doc(userId);

      return countsRef.update({bookCount: FieldValue.increment(1)});
    });

// 削除時に件数をデクリメント
exports.bookCountDown = functions.region("asia-northeast1").firestore
    .document("sample/v1/users/{userId}/books/{bookId}")
    .onDelete((change, context) => {
      const userId = context.params.userId;
      const FieldValue = admin.firestore.FieldValue;
      const countsRef = db.collection("sample/v1/users").doc(userId);

      return countsRef.update({bookCount: FieldValue.increment(-1)});
    });
