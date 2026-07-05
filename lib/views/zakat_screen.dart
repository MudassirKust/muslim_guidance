import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/zakat_controller.dart';
import '../services/zakat_calculator_service.dart';
import 'constants/appcolors.dart';
import 'zakat_info_screen.dart';

class ZakatScreen extends StatelessWidget {
  final controller = Get.put(ZakatController());

  ZakatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNisabSettings(context),
            const SizedBox(height: 16),
            _buildCurrencySelector(context),
            const SizedBox(height: 20),
            _buildAssetsSection(context),
            const SizedBox(height: 20),
            _buildLiabilitiesSection(context),
            const SizedBox(height: 20),
            _buildExclusionsCard(context),
            const SizedBox(height: 20),
            _buildCalculationResult(context),
            const SizedBox(height: 20),
            _buildResetButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appbarText,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        easy.tr('zakat_calculator'),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => Get.to(() => const ZakatInfoScreen()),
          tooltip: easy.tr('zakat_information'),
        ),
      ],
      elevation: 0,
    );
  }

  Widget _buildNisabSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('nisab_standard'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.containerColorThemed(context),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.greyBorderThemed(context)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        easy.tr('gold'),
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        easy.tr('nisab_gold_grams'),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.greyBorderThemed(context)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        easy.tr('silver'),
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        easy.tr('nisab_silver_grams'),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleNisabStandard('gold'),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: controller.nisabStandard.value == 'gold'
                                  ? AppColors.appbarText
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: controller.nisabStandard.value == 'gold'
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.appbarText,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(easy.tr('gold'),
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => controller.toggleNisabStandard('silver'),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: controller.nisabStandard.value == 'silver'
                                  ? AppColors.appbarText
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: controller.nisabStandard.value == 'silver'
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.appbarText,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(easy.tr('silver'),
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          Text(
            easy.tr('manual_price_entry'),
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextInputField(
                  label: easy.tr('gold_per_gram'),
                  onChanged: controller.updateGoldPrice,
                  context: context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextInputField(
                  label: easy.tr('silver_per_gram'),
                  onChanged: controller.updateSilverPrice,
                  context: context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appbarText.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      easy.tr('current_nisab_value'),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      controller.getFormattedNisab(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appbarText,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('currency'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => DropdownButton<String>(
                value: controller.currency.value,
                items: ZakatCalculatorService.getSupportedCurrencies()
                    .map((curr) => DropdownMenuItem(
                          value: curr,
                          child: Text(curr),
                        ))
                    .toList(),
                onChanged: (value) => controller.setCurrency(value ?? 'USD'),
                isExpanded: true,
                underline: const SizedBox(),
              )),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr('zakatable_assets'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('cash_and_savings'),
          children: [
            _buildTextInputField(
              label: easy.tr('bank_accounts'),
              onChanged: controller.updateCashAndSavings,
              context: context,
            ),
          ],
          context: context,
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('gold_and_silver'),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextInputField(
                    label: easy.tr('gold_grams'),
                    onChanged: controller.updateGoldGrams,
                    context: context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextInputField(
                    label: easy.tr('silver_grams'),
                    onChanged: controller.updateSilverGrams,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(easy.tr('gold_value'),
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text(controller.getFormattedGoldValue(),
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                )),
            const SizedBox(height: 8),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(easy.tr('silver_value'),
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text(controller.getFormattedSilverValue(),
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                )),
          ],
          context: context,
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('investments'),
          children: [
            _buildTextInputField(
              label: easy.tr('stocks_bonds'),
              onChanged: controller.updateInvestmentValue,
              context: context,
            ),
          ],
          context: context,
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('other_assets'),
          children: [
            _buildTextInputField(
              label: easy.tr('property_for_resale'),
              onChanged: controller.updateOtherAssetsValue,
              context: context,
            ),
          ],
          context: context,
        ),
        const SizedBox(height: 16),
        Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.appbarText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    easy.tr('total_assets'),
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    controller.getFormattedAssets(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appbarText,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLiabilitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr('deductible_liabilities'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('immediate_bills'),
          children: [
            _buildTextInputField(
              label: easy.tr('rent_due'),
              onChanged: controller.updateImmediateBills,
              context: context,
            ),
          ],
          context: context,
        ),
        const SizedBox(height: 12),
        _buildExpandableAssetCard(
          title: easy.tr('short_term_debts'),
          children: [
            _buildTextInputField(
              label: easy.tr('credit_cards'),
              onChanged: controller.updateShortTermDebts,
              context: context,
            ),
          ],
          context: context,
        ),
        const SizedBox(height: 16),
        Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    easy.tr('total_liabilities'),
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    controller.getFormattedLiabilities(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildExclusionsCard(BuildContext context) {
    return _buildExpandableAssetCard(
      title: easy.tr('exclusions'),
      children: [
        _buildExclusionItem(easy.tr('primary_residence')),
        _buildExclusionItem(easy.tr('personal_vehicles')),
        _buildExclusionItem(easy.tr('household_items')),
        _buildExclusionItem(easy.tr('work_equipment')),
        _buildExclusionItem(easy.tr('dependent_support_costs')),
        _buildExclusionItem(easy.tr('long_term_debts')),
      ],
      context: context,
    );
  }

  Widget _buildExclusionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationResult(BuildContext context) {
    return Obx(() {
      final isObligatory = controller.calculation.value.isZakatObligatory();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isObligatory
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isObligatory ? Colors.green : Colors.grey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              easy.tr('calculation_result'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackTextThemed(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildCalculationRow(
              easy.tr('net_zakatable_wealth'),
              controller.getFormattedNetWorth(),
              '${controller.getFormattedAssets()} - ${controller.getFormattedLiabilities()}',
            ),
            const SizedBox(height: 12),
            _buildCalculationRow(
              easy.tr('nisab_threshold'),
              controller.getFormattedNisab(),
              controller.nisabStandard.value == 'gold'
                  ? easy.tr('nisab_gold_subtitle')
                  : easy.tr('nisab_silver_subtitle'),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.greyBorderThemed(context), thickness: 1),
            const SizedBox(height: 16),
            if (isObligatory)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        easy.tr('zakat_is_obligatory_on_you'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        easy.tr('zakat_not_due'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (isObligatory)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    easy.tr('zakat_amount_due'),
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.appbarText.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.getFormattedZakat(),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.appbarText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${easy.tr('percentage_of')} ${controller.getFormattedNetWorth()}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            easy.tr('hawl_due'),
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCalculationRow(String label, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12)),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.resetCalculator,
        icon: const Icon(Icons.refresh),
        label: Text(easy.tr('reset_calculator')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appbarText,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableAssetCard({
    required String title,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputField(
      {required String label,
      required Function(String) onChanged,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextField(
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppColors.greyBorderThemed(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppColors.greyBorderThemed(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.appbarText),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }
}
