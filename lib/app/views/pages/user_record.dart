import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import '../../controller/shared_list_state.dart';
import '../../models/book.dart';
import '../../utils/app_colors.dart';
import '../../utils/util_fuctions.dart';
import '../widgets/general_divider.dart';

class UserRecord extends StatefulWidget {
  final Book book;
  final String existingRecord;
  final UserRecordOption userRecordOption;

  const UserRecord({super.key, required this.book, required this.existingRecord, required this.userRecordOption});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  late TextEditingController _textController;
  final List<File?> _image = [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingRecord);
  }

  void saveUserRecord(Book book) {
    if (_textController.text.isEmpty && _image.isEmpty) {
      return;
    }

    switch (widget.userRecordOption) {
      case UserRecordOption.comment:
        book.customInfo.comment = _textController.text;
      case UserRecordOption.note:
        book.customInfo.note[getCurrentDateAndTimeAsString()] =
        {
          'text': _textController.text,
          'images': _image.map((file) => file!.path).toList()
        };
      case UserRecordOption.highlight:
        book.customInfo.highlight[getCurrentDateAndTimeAsString()] =
        {
          'text': _textController.text,
          'images': _image.map((file) => file!.path).toList()
        };
      default:
        return;
    }
  }

  Future<void> _pickImage() async {
    if (await requestStoragePermission()) {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final String imagePath = await saveImagePermanently(pickedFile.path);
        setState(() {
          _image.add(File(imagePath));
        });
      }
    }
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<String> saveImagePermanently(String imagePath) async {
    final Directory dir = await getApplicationDocumentsDirectory(); // Get the documents directory
    final Directory skoobDir = Directory('${dir.path}/SKOOB');
    print('skoob Dir: ${skoobDir}');

    if (!await skoobDir.exists()) {
      await skoobDir.create(recursive: true);
    }

    final String fileName = Path.basename(imagePath); // Use the path package to get the file name
    final File tempFile = File(imagePath); // The current file
    final File newFile = File('${skoobDir.path}/$fileName'); // The new file location within 'skoob' directory

    await tempFile.copy(newFile.path); // Copy the file to 'skoob' directory

    return newFile.path; // Return the new file path
  }

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
            book.basicInfo.title,
          style: const TextStyle(
            fontFamily: 'NotoSansKRMedium',
            fontSize: 16.0,
            color: AppColors.softBlack,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                cursorWidth: 1.2,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 14.0
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          if (_image.isNotEmpty)
            SizedBox(
              height: 80.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ListView.builder(
                  itemCount: _image.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      child: Image.file(_image[index]!, width: 64, fit: BoxFit.fill,),
                    );
                  }
                ),
              ),
            ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const GeneralDivider(verticalPadding: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.userRecordOption == UserRecordOption.comment
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: const Icon(FluentIcons.image_16_regular)
                    ),
                    IconButton(
                        onPressed: () {
                          saveUserRecord(book);
                          Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                          Navigator.pop(context, book);
                          },
                        icon: const Icon(FluentIcons.checkmark_16_filled)
                    )
                  ],
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

enum UserRecordOption {comment, note, highlight}
