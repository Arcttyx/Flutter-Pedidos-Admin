import 'package:cloud_firestore/cloud_firestore.dart';

/*
This class represent all possible CRUD operation for Firestore.
It contains all generic implementation needed based on the provided document
path and documentID,since most of the time in Firestore design, we will have
documentID and path for any document and collections.
 */
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<bool> addData({required String collection, required Map<String, dynamic> data, bool insertId = false}) async {
    return FirebaseFirestore.instance.collection(collection)
    .add(data)
    .then((value) async {
      print("Document Added");

      if (insertId) {
        await editData(collection: collection, data: {'id': value.id}, docId: value.id);
        // FirebaseFirestore.instance.collection(collection)
        //   .doc(value.id)
        //   .update({'id': value.id})
        //   .catchError((error) { print("Failed to insert id of $collection: $error"); });
      }

      return true;
    })
    .catchError((error) {
      print("Failed to add document of type $collection: $error");
      return false;
    });
  }

  Future<bool> editData({required String collection, required Map<String, dynamic> data, required String? docId, bool merge = false}) async {
    return FirebaseFirestore.instance.collection(collection)
    .doc(docId)
    .update(data)
    .then((value) {
      print("Document Updated");
      return true;
    })
    .catchError((error) {
      print("Failed to update document of type $collection: $error");
      return false;
    });
  }

  Future<bool> deleteData({required String collection, required String? docId}) async {
    return FirebaseFirestore.instance.collection(collection)
    .doc(docId)
    .delete()
    .then((value) {
      print("Document Deleted");
      return true;
    })
    .catchError((error) {
      print("Failed to delete document of type $collection: $error");
      return false;
    });
  }
  
  Future<DocumentSnapshot> getByDocId({required String collection, required String docId}) async {
    return FirebaseFirestore.instance.collection(collection)
    .doc(docId)
    .get();
  }

  Future<List<T>> getCollectionList<T>({
    required String collection,
    required T builder(Map<String, dynamic>? data, String documentID),
    Query queryBuilder(Query query)?,
    int sort(T lhs, T rhs)?,
  }) async {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final QuerySnapshot snapshots = await query.get();
    List<T> result = [];
    for (QueryDocumentSnapshot doc in snapshots.docs) {
      result.add(builder(doc.data(), doc.id));
    }
    if (sort != null) {
      result.sort(sort);
    }
    return result;
  }

  //Consultas a firestore at low cost
  //https://stackoverflow.com/questions/61064461/what-is-the-right-way-to-make-a-search-bar-in-flutter-without-unnecessary-calls
  Stream<List<T>> collectionListStream<T>({
    required String collection,
    required T builder(Map<String, dynamic>? data, String documentID),
    Query queryBuilder(Query query)?,
    int sort(T lhs, T rhs)?,
  }) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    //return query.orderBy('fecha', descending: true).snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<QuerySnapshot> getCollectionStream<T>({
    required String collection,
    Query queryBuilder(Query query)?,
    String? order
  }) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    if (order != null) {
      query = query.orderBy(order, descending: true);
    }
    return query.snapshots();
  }

  // Stream<T> collectorioStreamListener<T>({
  //   required String collection,
  //   required T builder(Map<String, dynamic>? data),
  // }) {
  //   Query query = FirebaseFirestore.instance.collection(collection);
  //   query.snapshots().listen((event) {
  //     event.docChanges.forEach((documentChange) {
  //       if (documentChange.type == DocumentChangeType.added){
  //         print("document: ${documentChange.doc.data} added");
  //       } else if (documentChange.type == DocumentChangeType.modified){
  //         print("document: ${documentChange.doc.data} modified");
  //       } else if (documentChange.type == DocumentChangeType.removed){
  //         print("document: ${documentChange.doc.data} removed");
  //       } 
  //     });
  //     print('Error in processing changes');
  //   });
  // }
}