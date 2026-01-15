import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for downloading and managing audio files
class DownloadService {
  static const String _audioDownloadedKey = 'audio_downloaded';
  static const String _downloadProgressKey = 'download_progress';
  static const String _hasSeenDownloadPromptKey = 'has_seen_download_prompt';
  static const String _downloadTimestampKey = 'audio_download_timestamp';
  
  /// GitHub release URL for audio files
  static const String audioZipUrl = 
      'https://github.com/Ayomide-16/Audio-Bible/releases/latest/download/audio-files.zip';
  
  /// Check if user has already seen the download prompt (to avoid repeated prompts)
  static Future<bool> hasSeenDownloadPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenDownloadPromptKey) ?? false;
  }
  
  /// Mark that user has seen the download prompt
  static Future<void> markDownloadPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenDownloadPromptKey, true);
  }
  
  /// Check if audio files are already downloaded
  static Future<bool> isAudioDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getBool(_audioDownloadedKey) ?? false;
    
    if (downloaded) {
      // Verify files actually exist
      final audioDir = await getAudioDirectory();
      if (await audioDir.exists()) {
        final files = audioDir.listSync();
        return files.isNotEmpty;
      }
    }
    return false;
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
  
  /// Get the audio directory path
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/audio');
  }
  
  /// Get audio file path for a specific book and chapter
  static Future<String> getAudioPath(int bookId, int chapter) async {
    final audioDir = await getAudioDirectory();
    return '${audioDir.path}/$bookId/$chapter.mp3';
  }
  
  /// Check if specific audio file exists
  static Future<bool> audioFileExists(int bookId, int chapter) async {
    final path = await getAudioPath(bookId, chapter);
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
      
      final request = http.Request('GET', Uri.parse(audioZipUrl));
      final response = await http.Client().send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
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
            progress * 0.7, // 0-70% for download
            'Downloading... ${mb.toStringAsFixed(1)}/${totalMb.toStringAsFixed(0)} MB',
          );
        }
      }
      
      // Save ZIP file
      onProgress(0.7, 'Saving download...');
      await zipFile.writeAsBytes(bytes);
      
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
}
