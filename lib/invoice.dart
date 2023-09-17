import 'package:livin_task/mock_invoice_repository.dart';

/// Class to store the menu item
class MenuItem {
  final String name;
  final double price;

  const MenuItem(this.name, this.price);

  MenuItem copyWith({String? name, double? price}) {
    return MenuItem(name ?? this.name, price ?? this.price);
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(json['name'], json['price']);
  }
}

/// Payment method enum
enum PaymentMethod { cash, creditCard }

/// Invoice item class that will act as a wrapper around [MenuItem] with quantity added
class InvoiceItem {
  final MenuItem menuItem;
  final double quantity;

  const InvoiceItem(this.menuItem, this.quantity);

  String getQuantityFraction(int splitBy) {
    return '$quantity/$splitBy';
  }

  InvoiceItem copyWith({MenuItem? menuItem, double? quantity}) {
    return InvoiceItem(menuItem ?? this.menuItem, quantity ?? this.quantity);
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(MenuItem.fromJson(json['menuItem']), json['quantity']);
  }

  @override
  String toString() {
    return 'Item name: ${menuItem.name}, Quantity: $quantity, Amount: \$${quantity * menuItem.price}';
  }
}

/// Configurations class that will hold default values need for this module
class Configurations {
  static const double gstPercentage = 10.0;
  static const double sgrtPercentage = 2.0;
  static const bool isSgrtApplicable = false;
}

/// Discount type enum
enum DiscountType { percentage, amount }

/// Discount class to specify [DiscountType] with value
class Discount {
  final double value;
  final DiscountType discountType;

  const Discount(this.value, this.discountType);
}

/// Class used to hold the tax information of the invoice, mostly used in UI
class TaxDetails {
  String description;
  double taxPercentage;

  TaxDetails(this.description, this.taxPercentage);
}

/// Custom Exception to use inside Invoice module
class InvoiceException implements Exception {
  String message;
  Object? error;

  InvoiceException({required this.message, this.error});
}

/// Core class of the Invoice module used to createInvoice and createSplitInvoices
/// Example Usage
/// Invoice invoice = Invoice('Group 1', items, splitBy: 3);
/// Creating master invoice
/// InvoiceDetails masterInvoice = invoice.createInvoice();
/// Creating split invoices
/// List<InvoiceDetails> splitInvoices = invoice.createSplitInvoices();
class Invoice {
  final String groupName;
  final List<InvoiceItem> items;
  final int splitBy;
  final Discount discount;

  const Invoice(this.groupName, this.items,
      {this.splitBy = 1,
      this.discount = const Discount(0, DiscountType.amount)});

  /// Used to create the master invoice
  InvoiceDetails createInvoice() {
    InvoiceDetails details = _getInvoiceDetails(
        InvoiceMockRepository().getNextInvoiceNumber(), items);
    InvoiceMockRepository().saveInvoice(details);
    return details;
  }

  /// Used to create split invoices if the bill is split
  List<InvoiceDetails> createSplitInvoices() {
    List<InvoiceDetails> invoices = [];
    int i = 0;
    while (i < splitBy) {
      InvoiceDetails details = _getInvoiceDetails(
          InvoiceMockRepository().getNextInvoiceNumber(), items,
          splitBy: splitBy);
      invoices.add(details);
      InvoiceMockRepository().saveInvoice(details);
      i++;
    }
    return invoices;
  }

  InvoiceDetails _getInvoiceDetails(int invoiceNumber, List<InvoiceItem> items,
      {int splitBy = 1}) {
    if (splitBy < 1) {
      throw InvoiceException(message: 'Split value cannot be less than 1');
    }
    List<InvoiceItem> itemWithoutTaxes = List.from(items);
    itemWithoutTaxes = itemWithoutTaxes
        .map((e) => e.copyWith(
            quantity: e.quantity / splitBy,
            menuItem: e.menuItem.copyWith(
                name: e.menuItem.name,
                price: _reduceIncludingTax(e.menuItem.price))))
        .toList();

    double subTotal = _sumItemTotals(itemWithoutTaxes);

    double discountAmount = discount.value > 0
        ? discount.discountType == DiscountType.amount
            ? discount.value
            : _calculateDiscountAmount(subTotal, discount.value)
        : 0.0;

    subTotal = subTotal - discountAmount;
    double gst = (subTotal * Configurations.gstPercentage) / 100;
    double sgrt = Configurations.isSgrtApplicable
        ? (subTotal * Configurations.sgrtPercentage) / 100
        : 0.0;

    List<TaxDetails> taxDetails = [];
    taxDetails.add(TaxDetails('GST ${Configurations.gstPercentage}%', gst));
    if (Configurations.isSgrtApplicable) {
      taxDetails
          .add(TaxDetails('SGRT ${Configurations.sgrtPercentage}%', sgrt));
    }
    double total = (subTotal + gst + sgrt);
    return InvoiceDetails(invoiceNumber, groupName, splitBy, itemWithoutTaxes,
        discountAmount, gst, sgrt, subTotal, taxDetails, total);
  }

  double _sumItemTotals(List<InvoiceItem> items) {
    return items.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.menuItem.price * element.quantity));
  }

  double _calculateDiscountAmount(double amount, double discountPercentage) {
    if (amount <= 0.0 ||
        discountPercentage < 0.0 ||
        discountPercentage > 100.0) {
      return 0.0;
    }
    return amount * (discountPercentage / 100.0);
  }

  double _reduceIncludingTax(double price) {
    double taxPercentage = Configurations.gstPercentage +
        (Configurations.isSgrtApplicable ? Configurations.sgrtPercentage : 0.0);
    return (price * 100.0) / (100.0 + taxPercentage);
  }
}

/// Class to hold the transaction information
class Transaction {
  final PaymentMethod paymentMethod;
  final double collected;

  const Transaction(
      {this.paymentMethod = PaymentMethod.cash, this.collected = 0.0});

  Transaction copyWith(
      {PaymentMethod? paymentMethod, double? collected, double? returned}) {
    return Transaction(
        paymentMethod: paymentMethod ?? this.paymentMethod,
        collected: collected ?? this.collected);
  }
}

/// Class to hold the generated invoice data and pay function to save transaction information with the invoice
class InvoiceDetails {
  final int invoiceNumber;
  final String groupName;
  final int splitBy;
  final List<InvoiceItem> items;
  final double discount;
  final double gst;
  final double sgrt;
  final double subTotal;
  final List<TaxDetails> taxDetails;
  final double total;
  Transaction transaction;

  double get returned => transaction.collected - total;

  double get paid => transaction.collected;

  InvoiceDetails(
      this.invoiceNumber,
      this.groupName,
      this.splitBy,
      this.items,
      this.discount,
      this.gst,
      this.sgrt,
      this.subTotal,
      this.taxDetails,
      this.total,
      {this.transaction = const Transaction()});

  /// Used to pay the invoice
  void pay(double collectedAmount, PaymentMethod paymentMethod) {
    transaction = transaction.copyWith(
        paymentMethod: paymentMethod, collected: collectedAmount);
  }

  @override
  String toString() {
    return 'Invoice Number:$invoiceNumber\nGroupName:$groupName\nsplitBy:$splitBy\nItems:${items.join(',')}\nDiscount:$discount\nSubTotal:$subTotal\nGST:$gst\nSGRT:$sgrt\nTotal:$total\nPaid:$paid\nReturned:$returned\nPayment method:${transaction.paymentMethod}';
  }
}
