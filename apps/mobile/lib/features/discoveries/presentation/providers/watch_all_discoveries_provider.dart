import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/watch_all_discoveries.dart';
import 'package:canopy/features/discoveries/presentation/providers/discovery_repository_provider.dart';

part 'watch_all_discoveries_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Discovery>> watchAllDiscoveries(Ref ref) =>
    WatchAllDiscoveries(ref.watch(discoveryRepositoryProvider))();
