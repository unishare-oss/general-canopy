import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class FirestoreAdminDatasource {
  Future<bool> isAdmin(String uid);
  Future<void> createAdminDocument(String uid);
}

class FirestoreAdminDatasourceImpl implements FirestoreAdminDatasource {
  FirestoreAdminDatasourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection('admins');

  @override
  Future<bool> isAdmin(String uid) async {
    final doc = await _admins.doc(uid).get();
    return doc.exists && doc.data()?['isAdmin'] == true;
  }

  @override
  Future<void> createAdminDocument(String uid) =>
      _admins.doc(uid).set({'isAdmin': true});
}
