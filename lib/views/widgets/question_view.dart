// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../controllers/test_yourself_controller.dart';
//
// class QuestionView extends StatelessWidget {
//   final QuizController controller = Get.put(QuizController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final question =
//           controller.questions[controller.currentQuestionIndex.value];
//
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               question.questionText,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             ...List.generate(question.options.length, (index) {
//               final isSelected = controller.selectedOptionIndex.value == index;
//               final isCorrect = index == question.correctIndex;
//
//               Color tileColor = Colors.white;
//               if (controller.showCorrectAnswer.value) {
//                 if (isCorrect) {
//                   tileColor = Colors.green.shade300;
//                 } else if (isSelected && !isCorrect) {
//                   tileColor = Colors.red.shade300;
//                 }
//               }
//
//               return GestureDetector(
//                 onTap: () => controller.selectOption(index),
//                 child: Container(
//                   width: double.infinity,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: tileColor,
//                     border: Border.all(color: Colors.black),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(question.options[index]),
//                 ),
//               );
//             }),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: controller.nextQuestion,
//               child: Text(controller.currentQuestionIndex.value ==
//                       controller.questions.length - 1
//                   ? "View Results"
//                   : "Next"),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
