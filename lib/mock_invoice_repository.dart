import 'package:livin_task/invoice.dart';

/// Mock repository is a singleton class which is used to hold the invoices and generate invoice number
class InvoiceMockRepository {
  static final InvoiceMockRepository _instance =
      InvoiceMockRepository._internal();

  factory InvoiceMockRepository() {
    return _instance;
  }

  InvoiceMockRepository._internal();

  final List<InvoiceDetails> _invoices = List.empty(growable: true);

  /// Getter to get the saved invoices
  List<InvoiceDetails> get invoices => List.unmodifiable(_invoices);

  /// function to save the Invoice details to Invoice repository
  void saveInvoice(InvoiceDetails invoiceDetails) {
    _invoices.add(invoiceDetails);
  }

  /// Gives the next invoice number
  int getNextInvoiceNumber() {
    if (_invoices.isEmpty) {
      return 1;
    }
    return _invoices.last.invoiceNumber + 1;
  }
}
