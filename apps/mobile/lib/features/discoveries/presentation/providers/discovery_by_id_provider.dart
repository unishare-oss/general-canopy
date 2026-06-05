import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/get_discovery_by_id.dart';
import 'package:canopy/features/discoveries/presentation/providers/discovery_repository_provider.dart';

part 'discovery_by_id_provider.g.dart';

@riverpod
Future<Discovery> discoveryById(Ref ref, String id) =>
    GetDiscoveryById(ref.watch(discoveryRepositoryProvider))(id);
