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

  // TODO: Get this from brick configuration
  int get _maxFiles => 5;

  bool get _canAddMore => _selectedFiles.length < _maxFiles;

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
            setState(() {
              _selectedFiles.add(image);
            });
          }
        } else {
          final List<XFile> images = await _picker.pickMultiImage(
            limit: remainingSlots,
          );
          setState(() {
            _selectedFiles.addAll(images.take(remainingSlots));
          });
        }
      } else if (_isVideo) {
        if (remainingSlots == 1) {
          final XFile? video = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
          if (video != null) {
            setState(() {
              _selectedFiles.add(video);
            });
          }
        } else {
          final List<XFile> videos = await _picker.pickMultiVideo(
            limit: remainingSlots,
          );
          setState(() {
            _selectedFiles.addAll(videos.take(remainingSlots));
          });
        }
      } else if (_isFile) {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
        );

        if (result != null) {
          setState(() {
            _selectedFiles.addAll(result.files.take(remainingSlots));
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Widget _buildFileItem(dynamic file, int index) {
    Widget preview;

    if (file is XFile) {
      if (_isImage) {
        preview = Image.file(
          File(file.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else if (_isVideo) {
        preview = Container(
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.play_circle_outline, size: 40)),
        );
      } else {
        preview = Container(
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.insert_drive_file, size: 40)),
        );
      }
    } else if (file is PlatformFile) {
      preview = Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 40),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  file.name,
                  style: TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      preview = Container(color: Colors.grey[300]);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: preview),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    if (!_canAddMore) return SizedBox.shrink();

    return GestureDetector(
      onTap: _pick,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.add, size: 40, color: Colors.grey[400]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.brick.label != null) Text(widget.brick.label!),
        if (widget.brick.hint != null) Text(widget.brick.hint!),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedFiles.length + (_canAddMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _selectedFiles.length) {
              return _buildAddButton();
            }
            return _buildFileItem(_selectedFiles[index], index);
          },
        ),
      ],
    );
  }
}
