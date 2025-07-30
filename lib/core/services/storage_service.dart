import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_config.dart';
import '../utils/result.dart';
import '../errors/failures.dart';

/// Firebase Storage service for file operations
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final FirebaseStorage _storage = FirebaseConfig.instance.storage;

  /// Upload file from path
  Future<Result<String>> uploadFile({
    required String filePath,
    required String storagePath,
    String? fileName,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(
          FileFailure(message: 'File does not exist: $filePath'),
        );
      }

      final finalFileName = fileName ?? _generateFileName(file.path);
      final ref = _storage.ref().child('$storagePath/$finalFileName');

      // Set metadata
      final settableMetadata = SettableMetadata(
        contentType: _getContentType(file.path),
        customMetadata: metadata,
      );

      final uploadTask = ref.putFile(file, settableMetadata);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to upload file: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error uploading file: $e'),
      );
    }
  }

  /// Upload file from bytes
  Future<Result<String>> uploadBytes({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
    String? contentType,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');

      // Set metadata
      final settableMetadata = SettableMetadata(
        contentType: contentType ?? 'application/octet-stream',
        customMetadata: metadata,
      );

      final uploadTask = ref.putData(bytes, settableMetadata);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to upload bytes: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error uploading bytes: $e'),
      );
    }
  }

  /// Download file to local path
  Future<Result<File>> downloadFile({
    required String downloadUrl,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final file = File(localPath);

      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);

      final downloadTask = ref.writeToFile(file);

      // Listen to progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;
      return Result.success(file);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to download file: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error downloading file: $e'),
      );
    }
  }

  /// Download file as bytes
  Future<Result<Uint8List>> downloadBytes({
    required String downloadUrl,
    int? maxSize,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final bytes = await ref.getData(
        maxSize ?? 10 * 1024 * 1024,
      ); // Default 10MB

      if (bytes != null) {
        return Result.success(bytes);
      } else {
        return const Result.failure(
          FileFailure(message: 'Failed to download file bytes'),
        );
      }
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to download bytes: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error downloading bytes: $e'),
      );
    }
  }

  /// Delete file
  Future<Result<void>> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to delete file: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error deleting file: $e'),
      );
    }
  }

  /// Get file metadata
  Future<Result<FullMetadata>> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      return Result.success(metadata);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to get file metadata: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error getting file metadata: $e'),
      );
    }
  }

  /// List files in a directory
  Future<Result<List<Reference>>> listFiles({
    required String path,
    int? maxResults,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.list(ListOptions(maxResults: maxResults));
      return Result.success(result.items);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to list files: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error listing files: $e'),
      );
    }
  }

  /// Get download URL from storage path
  Future<Result<String>> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final downloadUrl = await ref.getDownloadURL();
      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to get download URL: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error getting download URL: $e'),
      );
    }
  }

  /// Upload multiple files
  Future<Result<List<String>>> uploadMultipleFiles({
    required List<String> filePaths,
    required String storagePath,
    Map<String, String>? metadata,
    Function(int, double)? onProgress,
  }) async {
    try {
      final downloadUrls = <String>[];

      for (int i = 0; i < filePaths.length; i++) {
        final result = await uploadFile(
          filePath: filePaths[i],
          storagePath: storagePath,
          metadata: metadata,
          onProgress: (progress) => onProgress?.call(i, progress),
        );

        if (result.isSuccess) {
          downloadUrls.add(result.data!);
        } else {
          return Result.failure(result.failure!);
        }
      }

      return Result.success(downloadUrls);
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error uploading multiple files: $e',
        ),
      );
    }
  }

  /// Delete multiple files
  Future<Result<void>> deleteMultipleFiles(List<String> downloadUrls) async {
    try {
      for (final url in downloadUrls) {
        final result = await deleteFile(url);
        if (result.isFailure) {
          return result;
        }
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error deleting multiple files: $e'),
      );
    }
  }

  /// Generate unique file name
  String _generateFileName(String originalPath) {
    final extension = originalPath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${_generateRandomString(8)}.$extension';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[random % chars.length],
    ).join();
  }

  /// Get content type from file extension
  String _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }
}

/// File upload progress callback
typedef UploadProgressCallback = void Function(double progress);

/// Multiple file upload progress callback
typedef MultipleUploadProgressCallback =
    void Function(int fileIndex, double progress);

/// Storage paths helper
class StoragePaths {
  static String userProfile(String userId) =>
      '${FirebaseStoragePaths.userProfiles}/$userId';
  static String productImage(String productId) =>
      '${FirebaseStoragePaths.productImages}/$productId';
  static String categoryImage(String categoryId) =>
      '${FirebaseStoragePaths.categoryImages}/$categoryId';
  static String farmerProfile(String farmerId) =>
      '${FirebaseStoragePaths.farmerProfiles}/$farmerId';
  static String reviewImage(String reviewId) =>
      '${FirebaseStoragePaths.reviewImages}/$reviewId';
}
