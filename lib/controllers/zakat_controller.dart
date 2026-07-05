import 'package:get/get.dart';
import '../models/zakat_model.dart';
import '../services/zakat_calculator_service.dart';

class ZakatController extends GetxController {
  // Assets
  final RxDouble cashAndSavings = 0.0.obs;
  final RxDouble goldGrams = 0.0.obs;
  final RxDouble silverGrams = 0.0.obs;
  final RxDouble investmentValue = 0.0.obs;
  final RxDouble otherAssetsValue = 0.0.obs;

  // Liabilities
  final RxDouble immediateBills = 0.0.obs;
  final RxDouble shortTermDebts = 0.0.obs;

  // Nisab Settings
  final RxString nisabStandard = 'silver'.obs;
  final RxDouble goldPricePerGram = 0.0.obs;
  final RxDouble silverPricePerGram = 0.0.obs;

  // User selection
  final Rx<UserType> userType = UserType.individual.obs;
  final RxString currency = 'USD'.obs;

  // Calculation result
  late Rx<ZakatCalculation> calculation;

  // Validation
  final RxBool isValidInput = false.obs;
  final RxString validationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCalculation();

    // Listen to changes and update calculation
    ever(cashAndSavings, (_) => _updateCalculation());
    ever(goldGrams, (_) => _updateCalculation());
    ever(silverGrams, (_) => _updateCalculation());
    ever(investmentValue, (_) => _updateCalculation());
    ever(otherAssetsValue, (_) => _updateCalculation());
    ever(immediateBills, (_) => _updateCalculation());
    ever(shortTermDebts, (_) => _updateCalculation());
    ever(goldPricePerGram, (_) => _updateCalculation());
    ever(silverPricePerGram, (_) => _updateCalculation());
    ever(nisabStandard, (_) => _updateCalculation());
    ever(userType, (_) => _updateCalculation());
    ever(currency, (_) => _updateCalculation());
  }

  void _initializeCalculation() {
    calculation = ZakatCalculation(
      assets: ZakatAssets(),
      liabilities: ZakatLiabilities(),
      nisabSettings: NisabSettings(),
      userType: UserType.individual,
      currency: 'USD',
    ).obs;
  }

  void _updateCalculation() {
    final assets = ZakatAssets(
      cashAndSavings: cashAndSavings.value,
      goldGrams: goldGrams.value,
      silverGrams: silverGrams.value,
      investmentValue: investmentValue.value,
      otherAssetsValue: otherAssetsValue.value,
    );

    final liabilities = ZakatLiabilities(
      immediateBills: immediateBills.value,
      shortTermDebts: shortTermDebts.value,
    );

    final nisabSettings = NisabSettings(
      standard: nisabStandard.value,
      goldPricePerGram: goldPricePerGram.value,
      silverPricePerGram: silverPricePerGram.value,
    );

    calculation.value = ZakatCalculation(
      assets: assets,
      liabilities: liabilities,
      nisabSettings: nisabSettings,
      userType: userType.value,
      currency: currency.value,
    );

    _validateInput();
  }

  void _validateInput() {
    // Check if prices are set
    if (goldPricePerGram.value <= 0 || silverPricePerGram.value <= 0) {
      isValidInput.value = false;
      validationMessage.value = 'Please enter valid gold and silver prices';
      return;
    }

    // Check if calculation is valid
    if (!ZakatCalculatorService.isValidCalculation(
      assets: calculation.value.assets,
      liabilities: calculation.value.liabilities,
      nisabSettings: calculation.value.nisabSettings,
    )) {
      isValidInput.value = false;
      validationMessage.value = 'Please check your input values';
      return;
    }

    isValidInput.value = true;
    validationMessage.value = '';
  }

  // Update asset methods
  void updateCashAndSavings(String value) {
    try {
      cashAndSavings.value = double.parse(value);
    } catch (e) {
      cashAndSavings.value = 0.0;
    }
  }

  void updateGoldGrams(String value) {
    try {
      goldGrams.value = double.parse(value);
    } catch (e) {
      goldGrams.value = 0.0;
    }
  }

  void updateSilverGrams(String value) {
    try {
      silverGrams.value = double.parse(value);
    } catch (e) {
      silverGrams.value = 0.0;
    }
  }

  void updateInvestmentValue(String value) {
    try {
      investmentValue.value = double.parse(value);
    } catch (e) {
      investmentValue.value = 0.0;
    }
  }

  void updateOtherAssetsValue(String value) {
    try {
      otherAssetsValue.value = double.parse(value);
    } catch (e) {
      otherAssetsValue.value = 0.0;
    }
  }

  // Update liability methods
  void updateImmediateBills(String value) {
    try {
      immediateBills.value = double.parse(value);
    } catch (e) {
      immediateBills.value = 0.0;
    }
  }

  void updateShortTermDebts(String value) {
    try {
      shortTermDebts.value = double.parse(value);
    } catch (e) {
      shortTermDebts.value = 0.0;
    }
  }

  // Update nisab settings
  void updateGoldPrice(String value) {
    try {
      goldPricePerGram.value = double.parse(value);
    } catch (e) {
      goldPricePerGram.value = 0.0;
    }
  }

  void updateSilverPrice(String value) {
    try {
      silverPricePerGram.value = double.parse(value);
    } catch (e) {
      silverPricePerGram.value = 0.0;
    }
  }

  void toggleNisabStandard(String standard) {
    nisabStandard.value = standard;
  }

  // Update user type
  void setUserType(UserType type) {
    userType.value = type;
  }

  // Update currency
  void setCurrency(String curr) {
    currency.value = curr;
  }

  // Get formatted values
  String getFormattedAssets() {
    return ZakatCalculatorService.formatCurrency(
      calculation.value.getTotalAssets(),
      currency.value,
    );
  }

  String getFormattedLiabilities() {
    return ZakatCalculatorService.formatCurrency(
      calculation.value.getTotalLiabilities(),
      currency.value,
    );
  }

  String getFormattedNetWorth() {
    return ZakatCalculatorService.formatCurrency(
      calculation.value.getNetWorth(),
      currency.value,
    );
  }

  String getFormattedNisab() {
    return ZakatCalculatorService.formatCurrency(
      calculation.value.getNisabThreshold(),
      currency.value,
    );
  }

  String getFormattedZakat() {
    return ZakatCalculatorService.formatCurrency(
      calculation.value.getZakatAmount(),
      currency.value,
    );
  }

  // Reset calculator
  void resetCalculator() {
    cashAndSavings.value = 0.0;
    goldGrams.value = 0.0;
    silverGrams.value = 0.0;
    investmentValue.value = 0.0;
    otherAssetsValue.value = 0.0;
    immediateBills.value = 0.0;
    shortTermDebts.value = 0.0;
    goldPricePerGram.value = 0.0;
    silverPricePerGram.value = 0.0;
    nisabStandard.value = 'silver';
    userType.value = UserType.individual;
    currency.value = 'USD';
  }

  // Get gold value
  double getGoldValue() {
    return goldGrams.value * goldPricePerGram.value;
  }

  // Get silver value
  double getSilverValue() {
    return silverGrams.value * silverPricePerGram.value;
  }

  // Get formatted gold value
  String getFormattedGoldValue() {
    return ZakatCalculatorService.formatCurrency(getGoldValue(), currency.value);
  }

  // Get formatted silver value
  String getFormattedSilverValue() {
    return ZakatCalculatorService.formatCurrency(getSilverValue(), currency.value);
  }
}
