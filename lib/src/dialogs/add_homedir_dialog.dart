import 'dart:io';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/mixins/stateful_mixin.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

class AddHomedirDialog extends StatefulWidget {
  const AddHomedirDialog({super.key, this.defaultHomedirPath});

  final Directory? defaultHomedirPath;

  @override
  State<AddHomedirDialog> createState() => _AddHomedirDialogState();
}

class _AddHomedirDialogState extends State<AddHomedirDialog> with StatefulMixin {
  late final I10n i10n = GetIt.I.get();

  final TextEditingController name = TextEditingController();
  final TextEditingController path = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void pickFolder() {
    final picker = DirectoryPicker()..title = i10n.main_page_select_folder_dialog_title;

    final directory = picker.getDirectory();

    if (directory == null) return;

    path.value = TextEditingValue(text: directory.path, selection: TextSelection.collapsed(offset: directory.path.length));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 512.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  i10n.main_page_dialog_title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return i10n.main_page_dialog_field_name_error;
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: i10n.main_page_dialog_field_name,
                    hintText: i10n.main_page_dialog_field_name_hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: path,
                  onTap: pickFolder,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return i10n.main_page_dialog_field_path_error;
                    }

                    if (!Directory(value).existsSync()) {
                      return i10n.main_page_dialog_field_path_error_not_exist;
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: i10n.main_page_dialog_field_path,
                    hintText: i10n.main_page_dialog_field_path_hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      showLoading();

                      final directory = Directory(path.text);

                      if (!directory.existsSync()) directory.createSync(recursive: true);

                      if (widget.defaultHomedirPath != null && !Directory(p.join(directory.path, 'Euro Truck Simulator 2')).existsSync()) {
                        await Process.run(
                          'Robocopy.exe',
                          [
                            '${widget.defaultHomedirPath!.path}/Euro Truck Simulator 2',
                            '${directory.path}/Euro Truck Simulator 2',
                            '/mir',
                            '/xd',
                            'mod',
                          ],
                        );
                      }

                      final homedir = HomedirEntity(
                        name: name.text,
                        directory: directory,
                        isDefault: false,
                        createdAt: DateTime.now(),
                      );

                      if (!mounted) return;

                      hideLoading();

                      return Navigator.pop(context, homedir);
                    }
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size.fromHeight(52.0)),
                  ),
                  child: Text(i10n.main_page_dialog_button_add),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
