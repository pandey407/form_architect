import 'package:flutter/material.dart';
import 'package:form_architect/form_architect.dart';
import 'package:form_architect/src/widgets/external_brick_label.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileBrick extends StatefulWidget {
  const FileBrick({super.key, required this.brick});

  final FormBrick brick;

  @override
  State<FileBrick> createState() => _FileBrickState();
}

class _FileBrickState extends State<FileBrick> {
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _selectedFiles = [];

  bool get _isImage => widget.brick.type == FormBrickType.image;
  bool get _isVideo => widget.brick.type == FormBrickType.video;
  bool get _isFile => widget.brick.type == FormBrickType.file;

  int get _maxFiles => 10;
  bool get _canAddMore => _selectedFiles.length < _maxFiles;

  static const double _thumbnailSize = 72.0;

  Future<void> _pick() async {
    try {
      final remainingSlots = _maxFiles - _selectedFiles.length;
      if (remainingSlots <= 0) return;

      if (_isImage) {
        if (remainingSlots == 1) {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            setState(() => _selectedFiles.insert(0, image));
          }
        } else {
          final List<XFile> images = await _picker.pickMultiImage(
            limit: remainingSlots,
          );
          setState(
            () => _selectedFiles.insertAll(0, images.take(remainingSlots)),
          );
        }
      } else if (_isVideo) {
        if (remainingSlots == 1) {
          final XFile? video = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
          if (video != null) {
            setState(() => _selectedFiles.insert(0, video));
          }
        } else {
          final List<XFile> videos = await _picker.pickMultiVideo(
            limit: remainingSlots,
          );
          setState(
            () => _selectedFiles.insertAll(0, videos.take(remainingSlots)),
          );
        }
      } else if (_isFile) {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
        );
        if (result != null) {
          setState(() {
            _selectedFiles.insertAll(0, result.files.take(remainingSlots));
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _removeFile(dynamic file) {
    setState(() => _selectedFiles.remove(file));
  }

  IconData get _typeIcon {
    if (_isImage) return Icons.add_photo_alternate_outlined;
    if (_isVideo) return Icons.video_call_outlined;
    return Icons.upload_file_outlined;
  }

  String get _typeLabel {
    if (_isImage) return 'Add Image';
    if (_isVideo) return 'Add Video';
    return 'Add File';
  }

  Widget _buildAddButton() {
    final isEmpty = _selectedFiles.isEmpty;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pick,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: isEmpty ? double.infinity : _thumbnailSize,
        height: isEmpty ? null : _thumbnailSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor, width: 1.5),
        ),
        child: isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _typeIcon,
                      size: 28,
                      color: theme.iconTheme.color ?? Colors.grey[600],
                    ),
                    SizedBox(height: 6),
                    Text(
                      _typeLabel,
                      style:
                          theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 13,
                          ) ??
                          TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Max $_maxFiles files',
                      style:
                          theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 11,
                          ) ??
                          TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              )
            : Icon(
                Icons.add,
                size: 24,
                color: theme.iconTheme.color ?? Colors.grey[600],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BrickLabel(brick: widget.brick),
        // File area
        if (_selectedFiles.isEmpty)
          _buildAddButton()
        else
          SizedBox(
            height: _thumbnailSize + 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 6),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  if (_canAddMore) ...[
                    _buildAddButton(),
                    if (_selectedFiles.isNotEmpty) SizedBox(width: 10),
                  ],
                  for (int i = 0; i < _selectedFiles.length; i++) ...[
                    if (i > 0) SizedBox(width: 10),
                    _ThumbnailWidget(
                      file: _selectedFiles[i],
                      isImage: _isImage,
                      isVideo: _isVideo,
                      thumbnailSize: _thumbnailSize,
                      onRemove: _removeFile,
                    ),
                  ],
                ],
              ),
            ),
          ),
        // File count indicator
        if (_selectedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_selectedFiles.length} of $_maxFiles files',
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ) ??
                  TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
      ],
    );
  }
}

class _ThumbnailWidget extends StatelessWidget {
  final dynamic file;
  final bool isImage;
  final bool isVideo;
  final double thumbnailSize;
  final void Function(dynamic) onRemove;

  const _ThumbnailWidget({
    required this.file,
    required this.isImage,
    required this.isVideo,
    required this.thumbnailSize,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget preview;

    if (file is XFile && isImage) {
      preview = Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: thumbnailSize,
        height: thumbnailSize,
      );
    } else if (file is XFile && isVideo) {
      preview = Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: theme.iconTheme.color ?? Colors.white70,
            size: 28,
          ),
        ),
      );
    } else if (file is PlatformFile) {
      final ext = _getFileExtension(file);
      preview = Container(
        color: colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: theme.iconTheme.color ?? Colors.grey[700],
              size: 24,
            ),
            if (ext.isNotEmpty) ...[
              SizedBox(height: 2),
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
    } else {
      preview = Container(color: colorScheme.surfaceContainerHighest);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: thumbnailSize,
          height: thumbnailSize,
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
            onTap: () => onRemove(file),
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

  String _getFileName(dynamic file) {
    if (file is XFile) {
      return file.name;
    } else if (file is PlatformFile) {
      return file.name;
    }
    return 'File';
  }

  String _getFileExtension(dynamic file) {
    final name = _getFileName(file);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toUpperCase();
    }
    return '';
  }
}
