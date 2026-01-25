import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for downloading and managing audio files
class DownloadService {
  static const String _audioDownloadedKey = 'audio_downloaded';
  static const String _hasSeenDownloadPromptKey = 'has_seen_download_prompt';
  static const String _downloadTimestampKey = 'audio_download_timestamp';
  
  /// GitHub release URL for audio files
  static const String audioZipUrl = 
      'https://github.com/Ayomide-16/Audio-Bible/releases/latest/download/audio-files.zip';
  
  /// Check if user has already seen the download prompt
  static Future<bool> hasSeenDownloadPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenDownloadPromptKey) ?? false;
  }
  
  /// Mark that user has seen the download prompt
  static Future<void> markDownloadPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenDownloadPromptKey, true);
  }
  
  /// Check if audio files are already downloaded (including USB transfer)
  static Future<bool> isAudioDownloaded() async {
    // First check app documents directory
    final audioDir = await getAudioDirectory();
    if (await audioDir.exists()) {
      final files = audioDir.listSync();
      if (files.isNotEmpty) {
        // Mark as downloaded if not already
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_audioDownloadedKey, true);
        return true;
      }
    }
    
    // Check external USB transfer location
    final externalDir = await getExternalAudioDirectory();
    if (externalDir != null && await externalDir.exists()) {
      final files = externalDir.listSync();
      if (files.isNotEmpty) {
        // Copy to app directory for consistency
        await _copyExternalToInternal(externalDir, audioDir);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_audioDownloadedKey, true);
        return true;
      }
    }
    
    return false;
  }
  
  /// Get the primary audio directory path (app documents)
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/audio');
  }
  
  /// Get the external audio directory for USB transfers
  static Future<Directory?> getExternalAudioDirectory() async {
    try {
      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs != null && externalDirs.isNotEmpty) {
          return Directory('${externalDirs.first.path}/audio');
        }
      }
    } catch (e) {
      debugPrint('Error getting external directory: $e');
    }
    return null;
  }
  
  /// Get the USB transfer path for user instructions
  static Future<String> getUsbTransferPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Android/data/com.audiobible.audio_bible/files/audio/';
    }
    return 'Not available on this platform';
  }
  
  /// Copy external files to internal directory
  static Future<void> _copyExternalToInternal(Directory source, Directory dest) async {
    if (!await dest.exists()) {
      await dest.create(recursive: true);
    }
    
    await for (final entity in source.list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst(source.path, '');
        final destFile = File('${dest.path}$relativePath');
        await destFile.create(recursive: true);
        await entity.copy(destFile.path);
      }
    }
  }
  
  /// Get audio file path for a specific book and chapter
  static Future<String> getAudioPath(String bookName, int chapter) async {
    final audioDir = await getAudioDirectory();
    return '${audioDir.path}/$bookName/$chapter.mp3';
  }
  
  /// Check if specific audio file exists
  static Future<bool> audioFileExists(String bookName, int chapter) async {
    final path = await getAudioPath(bookName, chapter);
    return File(path).exists();
  }
  
  /// Download audio files with progress callback
  static Future<void> downloadAudioFiles({
    required Function(double progress, String status) onProgress,
    required Function() onComplete,
    required Function(String error) onError,
  }) async {
    try {
      onProgress(0.0, 'Preparing download...');
      
      final audioDir = await getAudioDirectory();
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      final tempDir = await getTemporaryDirectory();
      final zipPath = '${tempDir.path}/audio-files.zip';
      final zipFile = File(zipPath);
      
      // Download the ZIP file
      onProgress(0.01, 'Connecting to server...');
      
      try {
        final request = http.Request('GET', Uri.parse(audioZipUrl));
        final client = http.Client();
        final response = await client.send(request).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Connection timeout. Please check your internet connection.');
          },
        );
        
        if (response.statusCode == 404) {
          throw Exception(
            'Audio files not found on server.\n\n'
            'The download file may not be available yet. '
            'You can manually transfer audio files via USB instead.\n\n'
            'Go to Settings > Audio Files for instructions.'
          );
        }
        
        if (response.statusCode != 200) {
          throw Exception('Server error: HTTP ${response.statusCode}');
        }
        
        final contentLength = response.contentLength ?? 0;
        var downloadedBytes = 0;
        final bytes = <int>[];
        
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;
          
          if (contentLength > 0) {
            final progress = downloadedBytes / contentLength;
            final mb = downloadedBytes / (1024 * 1024);
            final totalMb = contentLength / (1024 * 1024);
            onProgress(
              progress * 0.7,
              'Downloading... ${mb.toStringAsFixed(1)}/${totalMb.toStringAsFixed(0)} MB',
            );
          }
        }
        
        client.close();
        
        // Save ZIP file
        onProgress(0.7, 'Saving download...');
        await zipFile.writeAsBytes(bytes);
        
      } on SocketException catch (e) {
        throw Exception(
          'Network error: Unable to connect.\n\n'
          'Please check:\n'
          '• Your internet connection is working\n'
          '• WiFi or mobile data is enabled\n\n'
          'Error details: ${e.message}'
        );
      }
      
      // Extract ZIP
      onProgress(0.75, 'Extracting audio files...');
      await _extractZip(zipFile, audioDir, onProgress);
      
      // Clean up
      onProgress(0.98, 'Cleaning up...');
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
      
      // Mark as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_audioDownloadedKey, true);
      await prefs.setInt(_downloadTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      onProgress(1.0, 'Complete!');
      onComplete();
      
    } catch (e) {
      onError(e.toString());
    }
  }
  
  /// Extract ZIP file to destination
  static Future<void> _extractZip(
    File zipFile,
    Directory destination,
    Function(double, String) onProgress,
  ) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    
    final totalFiles = archive.files.length;
    var extractedFiles = 0;
    
    for (final file in archive.files) {
      if (file.isFile) {
        final outFile = File('${destination.path}/${file.name}');
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
      
      extractedFiles++;
      final progress = 0.75 + (extractedFiles / totalFiles) * 0.23;
      if (extractedFiles % 50 == 0) {
        onProgress(progress, 'Extracting... $extractedFiles/$totalFiles files');
      }
    }
  }
  
  /// Delete all downloaded audio files
  static Future<void> deleteAudioFiles() async {
    final audioDir = await getAudioDirectory();
    if (await audioDir.exists()) {
      await audioDir.delete(recursive: true);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_audioDownloadedKey, false);
  }
  
  /// Get total size of downloaded audio
  static Future<int> getDownloadedSize() async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) return 0;
    
    var totalSize = 0;
    await for (final entity in audioDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
  
  /// Get download timestamp
  static Future<DateTime?> getDownloadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_downloadTimestampKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
}
