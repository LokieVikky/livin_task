import 'package:livin_task/invoice.dart';
import 'package:livin_task/mock_menu_repository.dart';

class Biller {
  static final Biller _instance = Biller._internal();

  factory Biller() {
    return _instance;
  }

  Biller._internal();

  List<String> _groupOneInvoice = [];
  List<String> _groupTwoInvoice = [];
  List<String> _groupThreeInvoice = [];

  List<String> get groupOneInvoice {
    if (_groupOneInvoice.isEmpty) {
      _groupOneInvoice = List.from(_getGroupOneInvoices());
    }
    return _groupOneInvoice;
  }

  List<String> get groupTwoInvoice {
    if (_groupTwoInvoice.isEmpty) {
      _groupTwoInvoice = List.from(_getGroupTwoInvoices());
    }
    return _groupTwoInvoice;
  }

  List<String> get groupThreeInvoice {
    if (_groupThreeInvoice.isEmpty) {
      _groupThreeInvoice = List.from(_getGroupThreeInvoices());
    }
    return _groupThreeInvoice;
  }

  /// Generate Invoice for Group One
  List<String> _getGroupOneInvoices() {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().bigBrekkie, 2),
      InvoiceItem(MenuMockRepository().bruchetta, 1),
      InvoiceItem(MenuMockRepository().poachedEggs, 1),
      InvoiceItem(MenuMockRepository().coffee, 1),
      InvoiceItem(MenuMockRepository().tea, 1),
      InvoiceItem(MenuMockRepository().soda, 1),
    ];
    Invoice invoice = Invoice('Group 1', items, splitBy: 3);
    List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();
    for (InvoiceDetails id in splitInvoices) {
      id.pay(id.total, PaymentMethod.cash);
    }
    return splitInvoices.map((e) => '${_getPrintableInvoice(e)}\n').toList();
  }

  /// Generate Invoice for Group Two
  List<String> _getGroupTwoInvoices() {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().bigBrekkie, 3),
      InvoiceItem(MenuMockRepository().gardenSalad, 1),
      InvoiceItem(MenuMockRepository().poachedEggs, 1),
      InvoiceItem(MenuMockRepository().coffee, 3),
      InvoiceItem(MenuMockRepository().tea, 1),
      InvoiceItem(MenuMockRepository().soda, 1),
    ];
    Invoice invoice = Invoice('Group 2', items);
    InvoiceDetails invoiceDetails = invoice.createInvoice();
    invoiceDetails.pay(invoiceDetails.total, PaymentMethod.creditCard);
    return ['${_getPrintableInvoice(invoiceDetails)}\n'];
  }

  /// Generate Invoice for Group Three
  List<String> _getGroupThreeInvoices() {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().tea, 2),
      InvoiceItem(MenuMockRepository().coffee, 3),
      InvoiceItem(MenuMockRepository().soda, 2),
      InvoiceItem(MenuMockRepository().bruchetta, 5),
      InvoiceItem(MenuMockRepository().bigBrekkie, 5),
      InvoiceItem(MenuMockRepository().poachedEggs, 2),
      InvoiceItem(MenuMockRepository().gardenSalad, 3),
    ];
    Invoice invoice = Invoice('Group 3', items, splitBy: 3);
    List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();
    for (InvoiceDetails id in splitInvoices) {
      id.pay(id.total, PaymentMethod.cash);
    }
    return splitInvoices.map((e) => '${_getPrintableInvoice(e)}\n').toList();
  }

  /// Function to convert invoice to string
  String _getPrintableInvoice(InvoiceDetails details) {
    String itemsDetails = '';
    for (InvoiceItem item in details.items) {
      itemsDetails =
          '$itemsDetails ${item.menuItem.name} ${item.quantity.toStringAsFixed(2)} ${item.menuItem.price.toStringAsFixed(2)}';
    }
    return 'Group Name: ${details.groupName}\nInvoice no: ${details.invoiceNumber}\nItems: $itemsDetails\nDiscount: ${details.discount}\nGST: ${details.gst.toStringAsFixed(2)}\nSGRT: ${details.sgrt.toStringAsFixed(2)}\nSubtotal: ${details.subTotal.toStringAsFixed(2)}\nTotal: ${details.total.toStringAsFixed(2)}\nPayment details\nCollected: ${details.transaction.collected.toStringAsFixed(2)}\nPaid via: ${details.transaction.paymentMethod.name}';
  }
}
