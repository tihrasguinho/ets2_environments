import 'dart:io';

import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/mixins/stateful_mixin.dart';
import 'package:ets2_environments/src/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class AddHomedirDialog extends StatefulWidget {
  const AddHomedirDialog({super.key, this.defaultHomedirPath});

  final Directory? defaultHomedirPath;

  @override
  State<AddHomedirDialog> createState() => _AddHomedirDialogState();
}

class _AddHomedirDialogState extends State<AddHomedirDialog> with StatefulMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController path = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                  'Add new homedir',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name!';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: path,
                  onTap: () async {
                    final homedirPath = await pickPath(
                      context,
                      title: 'Select a folder to use as homedir',
                    );

                    if (homedirPath != null) {
                      path.text = homedirPath;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a path!';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Path',
                    hintText: 'Select path',
                    border: OutlineInputBorder(),
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
                  child: const Text('Add'),
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
