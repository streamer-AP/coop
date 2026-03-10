import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/resonance/presentation/screens/collection_detail_screen.dart';
import '../../features/resonance/presentation/screens/import_screen.dart';
import '../../features/resonance/presentation/screens/player_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/player',
        name: RouteNames.resonancePlayer,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: '/collection/:id',
        name: RouteNames.collectionDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CollectionDetailScreen(collectionId: id);
        },
      ),
      GoRoute(
        path: '/import',
        name: RouteNames.importScreen,
        builder: (context, state) => const ImportScreen(),
      ),
    ],
    redirect: (context, state) {
      // TODO: implement auth guard
      return null;
    },
  );
}
