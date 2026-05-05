import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/xodim_model.dart';
import '../../data/repositories/xodim_repository.dart';

// Repository Provider
final xodimRepositoryProvider = Provider<XodimRepository>((ref) {
  return XodimRepository();
});

// Active Xodimlar Stream Provider
final activeXodimlarProvider = StreamProvider<List<XodimModel>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return repository.getActiveXodimlar();
});

// All Xodimlar Stream Provider (Admin)
final allXodimlarProvider = StreamProvider<List<XodimModel>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return repository.getAllXodimlar();
});
