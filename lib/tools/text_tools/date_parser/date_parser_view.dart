import 'package:intl/intl.dart';

import 'package:alga/constants/import_helper.dart';
import 'package:alga/tools/text_tools/date_parser/date_parsed_widget.dart';

part './date_parser_provider.dart';

class DateParserView extends StatefulWidget {
  const DateParserView({Key? key}) : super(key: key);

  @override
  State<DateParserView> createState() => _DateParserViewState();
}

class _DateParserViewState extends State<DateParserView> {
  @override
  Widget build(BuildContext context) {
    return ToolView.scrollVertical(
      title: Text(S.of(context).dateParser),
      children: [
        AppTitleWrapper(
          title: S.of(context).dateParserdate,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Supported Date Format'),
                      content: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (var item in _supportDateFormat)
                            Chip(label: Text(item))
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: Text(S.of(context).confirm),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.help),
            ),
          ],
          child: Consumer(builder: (context, ref, _) {
            return TextField(
              controller: ref.read(_dateController),
              onChanged: (_) {
                ref.refresh(_date);
              },
            );
          }),
        ),
        Consumer(builder: (context, ref, _) {
          final date = ref.watch(_date);
          if (date == null) return const SizedBox.shrink();
          return Column(
            children: [
              AppTitleWrapper(
                title: S.of(context).parsedDate,
                child: DateParsedWidget(date: date),
              ),
              AppTitleWrapper(
                title: S.of(context).iso8601Date,
                actions: [
                  CopyButton(onCopy: (ref) => date.toIso8601String()),
                ],
                child: AppTextBox(data: date.toIso8601String()),
              ),
            ],
          );
        }),
        Consumer(builder: (context, ref, _) {
          return AppTitleWrapper(
            title: S.of(context).dateCustomFormat,
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Date Format Help'),
                        content: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (var item in _dateFormatHelp)
                              Chip(label: Text(item))
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Text(S.of(context).confirm),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.help),
              ),
              PasteButton(onPaste: (ref, data) {
                ref.read(_formatController).text = data;
                ref.refresh(_formatResult);
              }),
            ],
            child: TextField(
              controller: ref.read(_formatController),
              onChanged: (_) {
                ref.refresh(_formatResult);
              },
            ),
          );
        }),
        Consumer(builder: (context, ref, _) {
          return AppTitleWrapper(
            title: S.of(context).formattedDateString,
            actions: [
              IconButton(
                onPressed: () {
                  ClipboardUtil.copy(ref.watch(_formatResult) ?? '');
                },
                icon: const Icon(Icons.copy),
              ),
            ],
            child: AppTextBox(data: ref.watch(_formatResult) ?? ''),
          );
        }),
      ],
    );
  }
}
