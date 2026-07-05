class ZakatAssets {
  final double cashAndSavings;
  final double goldGrams;
  final double silverGrams;
  final double investmentValue;
  final double otherAssetsValue;

  ZakatAssets({
    this.cashAndSavings = 0.0,
    this.goldGrams = 0.0,
    this.silverGrams = 0.0,
    this.investmentValue = 0.0,
    this.otherAssetsValue = 0.0,
  });

  double getTotalAssets({
    required double goldPrice,
    required double silverPrice,
  }) {
    final goldValue = goldGrams * goldPrice;
    final silverValue = silverGrams * silverPrice;
    return cashAndSavings + goldValue + silverValue + investmentValue + otherAssetsValue;
  }

  ZakatAssets copyWith({
    double? cashAndSavings,
    double? goldGrams,
    double? silverGrams,
    double? investmentValue,
    double? otherAssetsValue,
  }) {
    return ZakatAssets(
      cashAndSavings: cashAndSavings ?? this.cashAndSavings,
      goldGrams: goldGrams ?? this.goldGrams,
      silverGrams: silverGrams ?? this.silverGrams,
      investmentValue: investmentValue ?? this.investmentValue,
      otherAssetsValue: otherAssetsValue ?? this.otherAssetsValue,
    );
  }
}

class ZakatLiabilities {
  final double immediateBills;
  final double shortTermDebts;

  ZakatLiabilities({
    this.immediateBills = 0.0,
    this.shortTermDebts = 0.0,
  });

  double getTotalLiabilities() {
    return immediateBills + shortTermDebts;
  }

  ZakatLiabilities copyWith({
    double? immediateBills,
    double? shortTermDebts,
  }) {
    return ZakatLiabilities(
      immediateBills: immediateBills ?? this.immediateBills,
      shortTermDebts: shortTermDebts ?? this.shortTermDebts,
    );
  }
}

class NisabSettings {
  static const double goldGrams = 87.48;
  static const double silverGrams = 612.36;
  static const double zakatPercentage = 0.025; // 2.5%

  final String standard; // 'gold' or 'silver'
  final double goldPricePerGram;
  final double silverPricePerGram;

  NisabSettings({
    this.standard = 'silver',
    this.goldPricePerGram = 0.0,
    this.silverPricePerGram = 0.0,
  });

  double getNisabValue() {
    if (standard == 'gold') {
      return goldGrams * goldPricePerGram;
    } else {
      return silverGrams * silverPricePerGram;
    }
  }

  NisabSettings copyWith({
    String? standard,
    double? goldPricePerGram,
    double? silverPricePerGram,
  }) {
    return NisabSettings(
      standard: standard ?? this.standard,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
    );
  }
}

enum UserType {
  individual,
}

class ZakatCalculation {
  final ZakatAssets assets;
  final ZakatLiabilities liabilities;
  final NisabSettings nisabSettings;
  final UserType userType;
  final String currency;

  ZakatCalculation({
    required this.assets,
    required this.liabilities,
    required this.nisabSettings,
    this.userType = UserType.individual,
    this.currency = 'USD',
  });

  double getTotalAssets() {
    return assets.getTotalAssets(
      goldPrice: nisabSettings.goldPricePerGram,
      silverPrice: nisabSettings.silverPricePerGram,
    );
  }

  double getTotalLiabilities() {
    return liabilities.getTotalLiabilities();
  }

  double getNetWorth() {
    final total = getTotalAssets() - getTotalLiabilities();
    return total > 0 ? total : 0;
  }

  double getNisabThreshold() {
    return nisabSettings.getNisabValue();
  }

  bool isZakatObligatory() {
    return getNetWorth() >= getNisabThreshold();
  }

  double getZakatAmount() {
    if (!isZakatObligatory()) {
      return 0.0;
    }
    return getNetWorth() * NisabSettings.zakatPercentage;
  }

  String getInstructionText() {
    return 'individual_instruction';
  }

  ZakatCalculation copyWith({
    ZakatAssets? assets,
    ZakatLiabilities? liabilities,
    NisabSettings? nisabSettings,
    UserType? userType,
    String? currency,
  }) {
    return ZakatCalculation(
      assets: assets ?? this.assets,
      liabilities: liabilities ?? this.liabilities,
      nisabSettings: nisabSettings ?? this.nisabSettings,
      userType: userType ?? this.userType,
      currency: currency ?? this.currency,
    );
  }
}
