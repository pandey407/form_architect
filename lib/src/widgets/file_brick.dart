import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/form_architect.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/type_parser_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:thumbnailer/thumbnailer.dart';
import 'package:mime/mime.dart';
import 'dart:io';

class FileBrick extends StatefulWidget {
  const FileBrick({super.key, required this.brick});

  final FormBrick brick;

  @override
  State<FileBrick> createState() => _FileBrickState();
}

class _FileBrickState extends State<FileBrick> {
  final ImagePicker _picker = ImagePicker();

  bool get _isImage => widget.brick.type == FormBrickType.image;
  bool get _isVideo => widget.brick.type == FormBrickType.video;
  bool get _isFile => widget.brick.type == FormBrickType.file;

  /// Returns the minimum number of files allowed by this brick from validation rules, or null if none.
  int? get _minFiles {
    final minFilesRule = widget.brick.validation?.firstWhereOrNull(
      (rule) => rule.type == FormValidationRuleType.min,
    );
    final minValue = minFilesRule?.value;
    if (minValue != null) {
      final min = TypeParserHelper.parseNum(minValue)?.toInt();
      return min;
    }
    return null;
  }

  /// Returns the maximum number of files allowed by this brick from validation rules, or null if none.
  int? get _maxFiles {
    final maxFilesRule = widget.brick.validation?.firstWhereOrNull(
      (rule) => rule.type == FormValidationRuleType.max,
    );
    final maxValue = maxFilesRule?.value;
    if (maxValue != null) {
      final max = TypeParserHelper.parseNum(maxValue)?.toInt();
      return max;
    }
    return null;
  }

  static const double _thumbnailSize = 72.0;

  /// Picks files according to the current brick type (image, video, or file).
  ///
  /// [remainingSlots] limits the number of files to select, if provided.
  /// Returns an empty list if nothing picked or if [remainingSlots] <= 0.
  ///
  /// For images/videos:
  ///   - If [remainingSlots] is 1, opens single picker.
  ///   - Otherwise, supports multiple selection (gallery/multi picker).
  /// For files:
  ///   - Uses [FilePicker] and returns up to [remainingSlots] files if set.
  Future<List<XFile>> _pick({int? remainingSlots}) async {
    try {
      if (remainingSlots != null && remainingSlots <= 0) {
        return [];
      }

      /// Helper to return up to [remainingSlots], or all if [remainingSlots] is null.
      List<XFile> limitFiles(List<XFile> files) {
        if (remainingSlots == null) return files;
        return files.take(remainingSlots).toList();
      }

      if (_isImage) {
        if (remainingSlots == 1) {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
          return image != null ? [image] : [];
        }
        final images = await _picker.pickMultiImage(limit: remainingSlots);
        return limitFiles(images);
      }

      if (_isVideo) {
        if (remainingSlots == 1) {
          final XFile? video = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
          return video != null ? [video] : [];
        }
        final videos = await _picker.pickMultiVideo(limit: remainingSlots);
        return limitFiles(videos);
      }

      if (_isFile) {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result != null) {
          return limitFiles(result.xFiles);
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  IconData get _typeIcon {
    if (_isImage) return Icons.add_photo_alternate_outlined;
    if (_isVideo) return Icons.video_call_outlined;
    return Icons.upload_file_outlined;
  }

  /// Helper to reuse picking and apply the files to the field.
  Future<void> _handlePickAndApply(
    FormFieldState<List<XFile>> field,
    int? remainingSlots,
    List<XFile> selectedFiles,
  ) async {
    final addedFiles = await _pick(remainingSlots: remainingSlots);
    final updatedFiles = [...addedFiles, ...selectedFiles];
    field.didChange(updatedFiles);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBuilderField<List<XFile>>(
      name: widget.brick.key,
      enabled: widget.brick.isEnabled,
      validator: (selectedFiles) =>
          widget.brick.validate(values: selectedFiles),
      builder: (field) {
        final selectedFiles = field.value ?? <XFile>[];

        final remainingSlots = _maxFiles != null
            ? _maxFiles! - selectedFiles.length
            : null;
        final canSelectMore = remainingSlots != 0 || remainingSlots == null;
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.brick.label,
            hintText: widget.brick.hint,
            errorText: field.errorText,
            enabled: widget.brick.isEnabled,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // File area
              if (selectedFiles.isEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      _handlePickAndApply(field, remainingSlots, selectedFiles),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(_typeIcon, size: 32, color: theme.iconTheme.color),
                        SizedBox(height: 8),
                        if (widget.brick.hint != null)
                          Text(
                            widget.brick.hint!,
                            style: theme.inputDecorationTheme.hintStyle,
                          ),
                      ],
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    if (canSelectMore) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handlePickAndApply(
                          field,
                          remainingSlots,
                          selectedFiles,
                        ),
                        child: Container(
                          width: _thumbnailSize,
                          height: _thumbnailSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 24,
                            color: (theme.iconTheme.color),
                          ),
                        ),
                      ),
                      if (selectedFiles.isNotEmpty) SizedBox(width: 10),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: _thumbnailSize + 20,
                          child: Row(
                            children: selectedFiles
                                .map(
                                  (file) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: _Thumbnailer(
                                      file: file,
                                      isImage: _isImage,
                                      isVideo: _isVideo,
                                      thumbnailSize: _thumbnailSize,
                                      onRemove: (file) {
                                        final updatedFiles = List<XFile>.from(
                                          selectedFiles,
                                        );
                                        updatedFiles.remove(file);
                                        field.didChange(updatedFiles);
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // File count indicator
              if (selectedFiles.isNotEmpty && _maxFiles != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${selectedFiles.length} of $_maxFiles files',
                    style: theme.inputDecorationTheme.helperStyle,
                  ),
                ),
            ],
          ),
        );
      },
      valueTransformer: (values) {
        final selectedFiles = values ?? <XFile>[];
        // Transform files to their paths for form submission
        return selectedFiles
            .map((file) {
              return file.path;
            })
            .where((path) => path.isNotEmpty)
            .toList();
      },
    );
  }
}

class _Thumbnailer extends StatefulWidget {
  final XFile file;
  final bool isImage;
  final bool isVideo;
  final double thumbnailSize;
  final void Function(XFile) onRemove;

  const _Thumbnailer({
    required this.file,
    required this.isImage,
    required this.isVideo,
    required this.thumbnailSize,
    required this.onRemove,
  });

  @override
  State<_Thumbnailer> createState() => __ThumbnailerState();
}

class __ThumbnailerState extends State<_Thumbnailer> {
  final AsyncMemoizer<Uint8List?> _thumbnailMemoizer = AsyncMemoizer();

  Future<Uint8List?> _generateVideoThumbnail() {
    return _thumbnailMemoizer.runOnce(() async {
      try {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: widget.file.path,
          imageFormat: ImageFormat.PNG,
          maxHeight: (widget.thumbnailSize * 2).toInt(),
          quality: 75,
        );
        return thumbnail;
      } catch (e) {
        debugPrint('Error generating video thumbnail: $e');
        return null;
      }
    });
  }

  String _getMimeType(XFile file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget preview;

    if (widget.isImage) {
      preview = Image.file(
        File(widget.file.path),
        fit: BoxFit.cover,
        width: widget.thumbnailSize,
        height: widget.thumbnailSize,
      );
    } else if (widget.isVideo) {
      preview = FutureBuilder<Uint8List?>(
        future: _generateVideoThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(snapshot.data!, fit: BoxFit.cover),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: theme.iconTheme.color ?? Colors.white70,
                  size: 28,
                ),
              ),
            );
          }
        },
      );
    } else {
      // Use thumbnailer to get the appropriate icon for the file type
      final mimeType = _getMimeType(widget.file);
      final fileIcon = Thumbnailer.getIconDataForMimeType(mimeType);
      final ext = _getFileExtension(widget.file);

      preview = Container(
        color: colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(fileIcon, color: theme.iconTheme.color, size: 32),
            if (ext.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                ext,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: widget.thumbnailSize,
          height: widget.thumbnailSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: preview,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => widget.onRemove(widget.file),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 1.5),
              ),
              child: Icon(Icons.close, size: 12, color: colorScheme.surface),
            ),
          ),
        ),
      ],
    );
  }

  String _getFileExtension(XFile file) {
    final name = file.name;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toUpperCase();
    }
    return '';
  }
}
