import 'package:alga/constants/import_helper.dart';
import 'package:alga/widgets/app_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDrawerController =
    StateProvider<ScrollController>((ref) => ScrollController());

final showAppTitle = StateProvider<bool>((ref) => true);

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  void initState() {
    super.initState();
    ref.read(appDrawerController).addListener(updateScrollState);
  }

  @override
  void dispose() {
    ref.read(appDrawerController).removeListener(updateScrollState);
    super.dispose();
  }

  updateScrollState() {
    if (mounted && MediaQuery.of(context).size.width > 980) {
      ref.read(showAppTitle.notifier).state =
          ref.read(appDrawerController).offset >= 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(currentToolProvider);
    final itemRead = ref.read(currentToolProvider.notifier);
    final navi = ref.watch(toolsProvider)!;
    final scrollController = ref.watch(appDrawerController);
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      S.of(context).appName,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: navi.allToolsItem.icon,
                    title: navi.allToolsItem.title,
                    onTap: () {
                      itemRead.state = navi.allToolsItem;
                    },
                    tileColor: item == navi.allToolsItem
                        ? Colors.lightBlue.withOpacity(0.1)
                        : null,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tool = navi.toolGroups[index];
                      return ExpansionTile(
                        leading: tool.icon,
                        title: tool.title,
                        children: tool.items.map((e) {
                          bool same = e == item;
                          return ListTile(
                            leading: e.icon,
                            minLeadingWidth: 24,
                            title: e.title,
                            horizontalTitleGap: 4,
                            tileColor:
                                same ? Colors.lightBlue.withOpacity(0.1) : null,
                            onTap: () {
                              itemRead.state = e;
                            },
                          );
                        }).toList(),
                      );
                    },
                    childCount: navi.toolGroups.length,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(S.of(context).settings),
            onTap: () {
              itemRead.state = navi.settingsItem;
            },
            tileColor: item == navi.settingsItem
                ? Colors.lightBlue.withOpacity(0.1)
                : null,
          ),
        ],
      ),
    );
  }
}
