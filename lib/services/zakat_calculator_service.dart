import 'package:intl/intl.dart';
import '../models/zakat_model.dart';

class ZakatCalculatorService {
  /// Format a number as currency with the specified currency code
  static String formatCurrency(double amount, String currency) {
    try {
      final formatter = NumberFormat.currency(
        locale: _getLocaleForCurrency(currency),
        symbol: _getCurrencySymbol(currency),
        decimalDigits: 2,
      );
      return formatter.format(amount);
    } catch (e) {
      return '$amount $currency';
    }
  }

  /// Get the locale string for the currency
  static String _getLocaleForCurrency(String currency) {
    switch (currency) {
      case 'USD':
        return 'en_US';
      case 'EUR':
        return 'de_DE';
      case 'GBP':
        return 'en_GB';
      case 'SAR':
        return 'ar_SA';
      case 'AED':
        return 'ar_AE';
      case 'PKR':
        return 'ur_PK';
      case 'IDR':
        return 'id_ID';
      case 'TRY':
        return 'tr_TR';
      default:
        return 'en_US';
    }
  }

  /// Get the currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'PKR':
        return 'Rs';
      case 'IDR':
        return 'Rp';
      case 'TRY':
        return '₺';
      default:
        return currency;
    }
  }

  /// Get list of supported currencies
  static List<String> getSupportedCurrencies() {
    return ['USD', 'EUR', 'GBP', 'SAR', 'AED', 'PKR', 'IDR', 'TRY'];
  }

  /// Validate asset input
  static bool isValidAssetInput(double value) {
    return value >= 0 && !value.isNaN && !value.isInfinite;
  }

  /// Validate price input
  static bool isValidPriceInput(double value) {
    return value > 0 && !value.isNaN && !value.isInfinite;
  }

  /// Validate gram input
  static bool isValidGramInput(double value) {
    return value >= 0 && !value.isNaN && !value.isInfinite;
  }

  /// Calculate the breakdown of assets
  static Map<String, double> getAssetBreakdown({
    required ZakatAssets assets,
    required double goldPrice,
    required double silverPrice,
  }) {
    return {
      'cash': assets.cashAndSavings,
      'gold': assets.goldGrams * goldPrice,
      'silver': assets.silverGrams * silverPrice,
      'investments': assets.investmentValue,
      'other': assets.otherAssetsValue,
    };
  }

  /// Calculate the breakdown of liabilities
  static Map<String, double> getLiabilityBreakdown({
    required ZakatLiabilities liabilities,
  }) {
    return {
      'bills': liabilities.immediateBills,
      'debts': liabilities.shortTermDebts,
    };
  }

  /// Get user-friendly formatted calculation result
  static String getCalculationSummary({
    required ZakatCalculation calculation,
  }) {
    final netWorth = calculation.getNetWorth();
    final nisab = calculation.getNisabThreshold();
    final zakatAmount = calculation.getZakatAmount();
    final currency = calculation.currency;

    final buffer = StringBuffer();
    buffer.writeln('Total Assets: ${formatCurrency(calculation.getTotalAssets(), currency)}');
    buffer.writeln('Total Liabilities: ${formatCurrency(calculation.getTotalLiabilities(), currency)}');
    buffer.writeln('Net Worth: ${formatCurrency(netWorth, currency)}');
    buffer.writeln('Nisab Threshold: ${formatCurrency(nisab, currency)}');
    buffer.writeln('---');

    if (calculation.isZakatObligatory()) {
      buffer.writeln('Zakat Due: ${formatCurrency(zakatAmount, currency)}');
    } else {
      buffer.writeln('No Zakat Due (below Nisab)');
    }

    return buffer.toString();
  }

  /// Check if the calculation is valid
  static bool isValidCalculation({
    required ZakatAssets assets,
    required ZakatLiabilities liabilities,
    required NisabSettings nisabSettings,
  }) {
    // Validate that prices are set
    if (nisabSettings.goldPricePerGram <= 0 || nisabSettings.silverPricePerGram <= 0) {
      return false;
    }

    // Validate that all inputs are valid
    final allInputsValid = isValidAssetInput(assets.cashAndSavings) &&
        isValidGramInput(assets.goldGrams) &&
        isValidGramInput(assets.silverGrams) &&
        isValidAssetInput(assets.investmentValue) &&
        isValidAssetInput(assets.otherAssetsValue) &&
        isValidAssetInput(liabilities.immediateBills) &&
        isValidAssetInput(liabilities.shortTermDebts);

    return allInputsValid;
  }
}
