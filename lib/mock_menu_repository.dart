import 'package:livin_task/invoice.dart';

/// MockMenuRepository is a singleton class which is used to mock the menu items list and the items itself separately
class MenuMockRepository {
  static final MenuMockRepository _instance = MenuMockRepository._internal();

  factory MenuMockRepository() {
    return _instance;
  }

  MenuMockRepository._internal();

  MenuItem bigBrekkie = const MenuItem('Big Brekkie', 16);
  MenuItem bruchetta = const MenuItem('Bruchetta', 8);
  MenuItem poachedEggs = const MenuItem('Poached Eggs', 12);
  MenuItem coffee = const MenuItem('Coffee', 5);
  MenuItem tea = const MenuItem('Tea', 3);
  MenuItem soda = const MenuItem('Soda', 4);
  MenuItem gardenSalad = const MenuItem('Garden Salad', 10);

  /// Getter to mock the menu item list
  List<InvoiceDetails> get menuItems => List.unmodifiable(
      [bigBrekkie, bruchetta, poachedEggs, coffee, tea, soda, gardenSalad]);
}
