/// The app models money as rupees (double); the backend stores integer paise.
/// These are the single conversion point so rounding is consistent everywhere.
int rupeesToPaise(double rupees) => (rupees * 100).round();

double paiseToRupees(int paise) => paise / 100.0;

/// Parse an ISO-8601 timestamp from the API into a local DateTime.
DateTime parseApiDate(String iso) => DateTime.parse(iso).toLocal();

/// Format a DateTime for the API as UTC ISO-8601.
String formatApiDate(DateTime date) => date.toUtc().toIso8601String();
