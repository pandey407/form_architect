import 'package:flutter/material.dart';
import 'package:form_architect/form_architect.dart';
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

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
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

  Widget _buildThumbnail(dynamic file, int index) {
    Widget preview;

    if (file is XFile && _isImage) {
      preview = Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: _thumbnailSize,
        height: _thumbnailSize,
      );
    } else if (file is XFile && _isVideo) {
      preview = Container(
        color: Color(0xFF1a1a2e),
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white70,
            size: 28,
          ),
        ),
      );
    } else if (file is PlatformFile) {
      final ext = _getFileExtension(file);
      preview = Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: Color(0xFF666666),
              size: 24,
            ),
            if (ext.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                ext,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      preview = Container(color: Color(0xFFF5F5F5));
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _thumbnailSize,
          height: _thumbnailSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE0E0E0)),
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
            onTap: () => _removeFile(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color(0xFF444444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    final isEmpty = _selectedFiles.isEmpty;

    return GestureDetector(
      onTap: _pick,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: isEmpty ? double.infinity : _thumbnailSize,
        height: isEmpty ? null : _thumbnailSize,
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFDDDDDD), width: 1.5),
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
                    Icon(_typeIcon, size: 28, color: Color(0xFF888888)),
                    SizedBox(height: 6),
                    Text(
                      _typeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Max $_maxFiles files',
                      style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                    ),
                  ],
                ),
              )
            : Icon(Icons.add, size: 24, color: Color(0xFF888888)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.brick.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.brick.label!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
        // Hint
        if (widget.brick.hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.brick.hint!,
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ),
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
                    _buildThumbnail(_selectedFiles[i], i),
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
              style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ),
      ],
    );
  }
}
