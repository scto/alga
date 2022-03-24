import 'package:alga/constants/import_helper.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part './uuid_provider.dart';

class UUIDGeneratorView extends StatefulWidget {
  const UUIDGeneratorView({Key? key}) : super(key: key);

  @override
  State<UUIDGeneratorView> createState() => _UUIDGeneratorViewState();
}

class _UUIDGeneratorViewState extends State<UUIDGeneratorView> {
  @override
  Widget build(BuildContext context) {
    return ToolView.scrollVertical(
      title: Text(S.of(context).generatorUUID),
      children: [
        ToolViewWrapper(
          children: [
            ToolViewConfig(
              leading: const Icon(Icons.horizontal_rule),
              title: Text(S.of(context).hypens),
              trailing: Consumer(builder: (context, ref, _) {
                return Switch(
                  value: ref.watch(_hypens),
                  onChanged: (value) {
                    ref.read(_hypens.notifier).state = value;
                  },
                );
              }),
            ),
            ToolViewConfig(
              leading: const Icon(Icons.text_fields),
              title: Text(S.of(context).upperCase),
              trailing: Consumer(builder: (context, ref, _) {
                return Switch(
                  value: ref.watch(_upperCase),
                  onChanged: (value) {
                    ref.read(_upperCase.notifier).state = value;
                  },
                );
              }),
            ),
            ToolViewConfig(
              leading: const Icon(Icons.info_outline),
              title: Text(S.of(context).uuidVersion),
              subtitle: Text(S.of(context).uuidVersionDes),
              trailing: Consumer(builder: (context, ref, _) {
                return DropdownButton<UUIDVersion>(
                  items: UUIDVersion.values.map((e) {
                    return DropdownMenuItem(
                      child: Text(e.typeName(context)),
                      value: e,
                    );
                  }).toList(),
                  value: ref.watch(_version),
                  onChanged: (version) {
                    ref.read(_version.notifier).state =
                        version ?? UUIDVersion.v1;
                  },
                );
              }),
            ),
          ],
        ),
        Row(
          children: [
            RefReadonly(builder: (ref) {
              return ElevatedButton(
                child: Text(S.of(context).generateUUIDs),
                onPressed: () {
                  ref.refresh(_results);
                },
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('X'),
            ),
            SizedBox(
              width: 100,
              child: RefReadonly(builder: (ref) {
                return TextField(
                  controller: ref.watch(_countController),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    ref.refresh(_count);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                );
              }),
            )
          ],
        ),
        AppTitle(
          title: S.of(context).uuids,
          actions: [
            RefReadonly(builder: (ref) {
              return IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  ClipboardUtil.copy(ref.read(_resultValue));
                },
              );
            }),
          ],
        ),
        Consumer(builder: (context, ref, _) {
          return AppTextBox(
            minLines: 2,
            maxLines: 20,
            data: ref.watch(_resultValue),
          );
        }),
      ],
    );
  }
}
