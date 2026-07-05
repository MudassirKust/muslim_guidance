import 'package:flutter/material.dart';

class TableRowItem extends StatelessWidget {
  final String number;
  final String question;
  final String answer;
  final String source;
  final bool isHeader;

  const TableRowItem({
    super.key,
    required this.number,
    required this.question,
    required this.answer,
    required this.source,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: Colors.grey.shade800,
    );

    const headerTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.black,
    );

    final questionTextStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: isHeader ? Colors.black : Colors.black,
    );

    const bgColor = Color(0xFFFFFDF7);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Text(number,
                  style: isHeader ? headerTextStyle : defaultTextStyle)),
          Expanded(flex: 3, child: Text(question, style: questionTextStyle)),
          Expanded(
              flex: 3,
              child: Text(answer,
                  style: isHeader ? headerTextStyle : defaultTextStyle)),
          Expanded(
              flex: 3,
              child: Text(source,
                  style: isHeader ? headerTextStyle : defaultTextStyle)),
        ],
      ),
    );
  }
}
