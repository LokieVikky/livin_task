import 'package:flutter_test/flutter_test.dart';
import 'package:livin_task/invoice.dart';
import 'package:livin_task/mock_menu_repository.dart';

void main() {
  /// One cent is defined as acceptable difference
  double acceptableDifference = 0.01;

  test('Group 1 Invoice', () {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().bigBrekkie, 2),
      InvoiceItem(MenuMockRepository().bruchetta, 1),
      InvoiceItem(MenuMockRepository().poachedEggs, 1),
      InvoiceItem(MenuMockRepository().coffee, 1),
      InvoiceItem(MenuMockRepository().tea, 1),
      InvoiceItem(MenuMockRepository().soda, 1),
    ];

    Invoice invoice = Invoice('Group 1', items, splitBy: 3);

    /// Creating master invoice
    InvoiceDetails masterInvoice = invoice.createInvoice();

    /// Creating split invoices
    List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();

    /// Testing master bill total
    expect(masterInvoice.total, closeTo(64.0, acceptableDifference));

    /// Testing whether 3 separate bills are created
    expect(splitInvoices.length, 3);

    /// Paying transactions
    for (InvoiceDetails id in splitInvoices) {
      id.pay(64, PaymentMethod.cash);
    }

    /// Testing split invoice total
    for (InvoiceDetails id in splitInvoices) {
      expect(id.total, closeTo(21.33, acceptableDifference));
    }
  });

  test('Group 2 Invoice', () {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().bigBrekkie, 3),
      InvoiceItem(MenuMockRepository().gardenSalad, 1),
      InvoiceItem(MenuMockRepository().poachedEggs, 1),
      InvoiceItem(MenuMockRepository().coffee, 3),
      InvoiceItem(MenuMockRepository().tea, 1),
      InvoiceItem(MenuMockRepository().soda, 1),
    ];

    Invoice invoice = Invoice('Group 2', items,
        splitBy: 3, discount: const Discount(10, DiscountType.percentage));

    /// Creating master invoice
    InvoiceDetails masterInvoice = invoice.createInvoice();

    /// Creating split invoices
    List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();

    /// Testing master bill total
    expect(masterInvoice.total, closeTo(82.8, acceptableDifference));

    /// Testing whether 3 separate bills are created
    expect(splitInvoices.length, 3);

    /// Paying transactions
    for (InvoiceDetails id in splitInvoices) {
      id.pay(27.6, PaymentMethod.cash);
    }

    /// Testing split invoice total
    for (InvoiceDetails id in splitInvoices) {
      expect(id.total, closeTo(27.6, acceptableDifference));
    }
  });

  test('Group 3 Invoice', () {
    List<InvoiceItem> items = [
      InvoiceItem(MenuMockRepository().tea, 2),
      InvoiceItem(MenuMockRepository().coffee, 3),
      InvoiceItem(MenuMockRepository().soda, 2),
      InvoiceItem(MenuMockRepository().bruchetta, 5),
      InvoiceItem(MenuMockRepository().bigBrekkie, 5),
      InvoiceItem(MenuMockRepository().poachedEggs, 2),
      InvoiceItem(MenuMockRepository().gardenSalad, 3),
    ];

    Invoice invoice = Invoice('Group 3', items,
        splitBy: 3, discount: const Discount(25, DiscountType.amount));

    /// Creating master invoice
    InvoiceDetails masterInvoice = invoice.createInvoice();

    /// Creating split invoices
    List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();

    /// Testing master bill total
    expect(masterInvoice.total, closeTo(175.5, acceptableDifference));

    /// Testing whether 3 separate bills are created
    expect(splitInvoices.length, 3);

    /// Paying transactions
    for (InvoiceDetails id in splitInvoices) {
      id.pay(40.16, PaymentMethod.cash);
    }

    /// Testing split invoice total
    for (InvoiceDetails id in splitInvoices) {
      expect(id.total, closeTo(40.16, acceptableDifference));
    }
  });
}
