import 'package:get/get.dart';
import 'package:hajz_sejours/features/Actualites/controller/actualites_service.dart';
import 'package:hajz_sejours/features/Actualites/model/actualite.dart';

class ActualitesController extends GetxController {
  var actualites = <Actualite>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchActualites();
    super.onInit();
  }

  void fetchActualites() async {
    try {
      isLoading(true);
      var fetchedActualites = await ActualitesService.fetchActualites();
      actualites.assignAll(fetchedActualites);
    } finally {
      isLoading(false);
    }
  }
}
