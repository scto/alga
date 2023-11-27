import 'dart:io';

import 'package:alga/models/app_atom.dart';
import 'package:alga/models/app_category.dart';
import 'package:alga/routers/app_router.dart';
import 'package:alga/ui/global.provider.dart';
import 'package:alga/ui/views/favorite_view.dart';
import 'package:alga/ui/views/search_view.dart';
import 'package:alga/ui/views/settings_view.dart';
import 'package:alga/utils/constants/import_helper.dart';

import 'alga_app_item.dart';
import 'alga_app_view_provider.dart';

class AppsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AlgaAppView();
  }
}

class AlgaAppView extends ConsumerStatefulWidget {
  const AlgaAppView({super.key});

  @override
  ConsumerState<AlgaAppView> createState() => AlgaAppViewState();
}

class AlgaAppViewState extends ConsumerState<AlgaAppView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(isDesktopProvider);
    return Scaffold(
      appBar: isDesktop
          ? AppBar(
              title: Text(S.of(context).appName),
              centerTitle: Platform.isIOS,
              bottom: const AppCategoriesPanel(),
            )
          : AppBar(
              // title: Text(S.of(context).appName),
              title: const MobileSearchBar(),
              centerTitle: Platform.isIOS,
              bottom: const AppCategoriesPanel(),
            ),
      body: Consumer(builder: (context, ref, _) {
        return TabBarView(
          controller: ref.watch(appTabControllerProvider(vsync: this)),
          children: [AppCategory.allApps, ...AppCategory.items].map((e) {
            return AppCategoryView(e);
          }).toList(),
        );
      }),
    );
  }
}

class MobileSearchBar extends StatelessWidget {
  const MobileSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barHintText: '${context.tr.appName} ${context.tr.search}',
      isFullScreen: true,
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final items = SearchViewState.findAtom(context, controller.text);
        return items
            .map(
              (e) => ListTile(
                leading: e.icon,
                title: Text(e.title(context)),
                onTap: () {
                  GoRouter.of(context).go(e.path);
                },
              ),
            )
            .toList();
      },
      barElevation: const MaterialStatePropertyAll(0),
      barBackgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.surfaceVariant),
      barTrailing: [
        IconButton(
          onPressed: () {
            FavoriteRoute().push(context);
          },
          icon: const Icon(Icons.favorite_outline_rounded),
        ),
        IconButton(
          onPressed: () {
            SettingsRoute().push(context);
          },
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class AppCategoriesPanel extends StatefulWidget implements PreferredSizeWidget {
  const AppCategoriesPanel({super.key});

  @override
  State<AppCategoriesPanel> createState() => _AppCategoriesPanelState();

  @override
  Size get preferredSize => const Size.fromHeight(46);
}

class _AppCategoriesPanelState extends State<AppCategoriesPanel> {
  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<AlgaAppViewState>()!;
    return Consumer(
      builder: (context, ref, _) {
        return TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: ref.watch(appTabControllerProvider(vsync: parentState)),
          indicatorPadding: const EdgeInsets.only(top: 44, left: 0, right: 0),
          tabs: [
            Tab(text: S.of(context).allApps),
            ...AppCategory.items.map((e) => Tab(text: e.name(context))),
          ],
        );
      },
    );
  }
}

class AppCategoryView extends ConsumerWidget {
  const AppCategoryView(this.category, {super.key});

  final AppCategory category;

  List<AppAtom> get items => categoryMapping[category.uuid] ?? [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(useGridLayoutProvider)) {
      return GridView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 2.0,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return AlgaAppItem(item);
        },
        itemCount: items.length,
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView.builder(
            itemBuilder: (context, index) {
              final item = items[index];
              return AlgaAppItem(item, useGrid: false);
            },
            itemCount: items.length,
          ),
        ),
      );
    }
  }
}
