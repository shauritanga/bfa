import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../utils/result.dart';
import '../errors/failures.dart';
import '../repositories/base_repository.dart';

/// Firestore service for database operations
class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();

  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseConfig.instance.firestore;

  /// Get a document by ID
  Future<Result<Map<String, dynamic>?>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();

      if (doc.exists) {
        return Result.success(doc.data());
      } else {
        return const Result.success(null);
      }
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to get document: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error getting document: $e'),
      );
    }
  }

  /// Get multiple documents with optional filters
  Future<Result<List<Map<String, dynamic>>>> getDocuments({
    required String collection,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      if (where != null) {
        for (final entry in where.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final documents = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      return Result.success(documents);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to get documents: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error getting documents: $e'),
      );
    }
  }

  /// Get paginated documents
  Future<Result<PaginatedResult<Map<String, dynamic>>>> getPaginatedDocuments({
    required String collection,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
    int page = 1,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      if (where != null) {
        for (final entry in where.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final documents = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Get total count (this is expensive, consider caching)
      final totalSnapshot = await _firestore
          .collection(collection)
          .count()
          .get();
      final totalItems = totalSnapshot.count ?? 0;

      final paginatedResult = PaginatedResult.fromData(
        items: documents,
        currentPage: page,
        totalItems: totalItems,
        itemsPerPage: limit,
      );

      return Result.success(paginatedResult);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(
          message: 'Failed to get paginated documents: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error getting paginated documents: $e',
        ),
      );
    }
  }

  /// Create a document
  Future<Result<String>> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      DocumentReference docRef;

      if (documentId != null) {
        docRef = _firestore.collection(collection).doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }

      return Result.success(docRef.id);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to create document: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error creating document: $e'),
      );
    }
  }

  /// Update a document
  Future<Result<void>> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      final docRef = _firestore.collection(collection).doc(documentId);

      if (merge) {
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.update(data);
      }

      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to update document: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error updating document: $e'),
      );
    }
  }

  /// Delete a document
  Future<Result<void>> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to delete document: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error deleting document: $e'),
      );
    }
  }

  /// Check if document exists
  Future<Result<bool>> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();

      return Result.success(doc.exists);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(
          message: 'Failed to check document existence: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error checking document existence: $e',
        ),
      );
    }
  }

  /// Search documents
  Future<Result<List<Map<String, dynamic>>>> searchDocuments({
    required String collection,
    required String field,
    required String searchTerm,
    int? limit,
  }) async {
    try {
      // Firestore doesn't support full-text search natively
      // This is a simple prefix search
      final query = _firestore
          .collection(collection)
          .where(field, isGreaterThanOrEqualTo: searchTerm)
          .where(field, isLessThan: '${searchTerm}z');

      final limitedQuery = limit != null ? query.limit(limit) : query;
      final snapshot = await limitedQuery.get();

      final documents = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      return Result.success(documents);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to search documents: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error searching documents: $e'),
      );
    }
  }

  /// Listen to document changes
  Stream<Result<Map<String, dynamic>?>> listenToDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots().map((
      snapshot,
    ) {
      try {
        if (snapshot.exists) {
          return Result.success(snapshot.data());
        } else {
          return const Result.success(null);
        }
      } catch (e) {
        return Result.failure(
          UnknownFailure(message: 'Error listening to document: $e'),
        );
      }
    });
  }

  /// Listen to collection changes
  Stream<Result<List<Map<String, dynamic>>>> listenToCollection({
    required String collection,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    // Apply where conditions
    if (where != null) {
      for (final entry in where.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      try {
        final documents = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();

        return Result.success(documents);
      } catch (e) {
        return Result.failure(
          UnknownFailure(message: 'Error listening to collection: $e'),
        );
      }
    });
  }

  /// Batch operations
  Future<Result<void>> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = _firestore
            .collection(operation.collection)
            .doc(operation.documentId);

        switch (operation.type) {
          case BatchOperationType.create:
          case BatchOperationType.update:
            batch.set(docRef, operation.data!, SetOptions(merge: true));
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(
          message: 'Failed to execute batch operations: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error executing batch operations: $e',
        ),
      );
    }
  }

  /// Transaction
  Future<Result<T>> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      final result = await _firestore.runTransaction(updateFunction);
      return Result.success(result);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Transaction failed: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error in transaction: $e'),
      );
    }
  }
}

/// Batch operation for Firestore
class BatchOperation {
  final String collection;
  final String documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  const BatchOperation({
    required this.collection,
    required this.documentId,
    required this.type,
    this.data,
  });

  /// Create operation
  factory BatchOperation.create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.create,
      data: data,
    );
  }

  /// Update operation
  factory BatchOperation.update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.update,
      data: data,
    );
  }

  /// Delete operation
  factory BatchOperation.delete({
    required String collection,
    required String documentId,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.delete,
    );
  }
}

/// Batch operation types
enum BatchOperationType { create, update, delete }
