import 'package:easy_localization/easy_localization.dart';

class UnbordingContent {
  String image;
  String title;
  String description;

  UnbordingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Never forget your medicine again!'.tr(),
      image: 'lib/page/task_screens/assets/icons/1.gif',
      description:
          "Remember what to take, when to take, when to refill. Never miss a dose again".tr()),
  UnbordingContent(
      title: 'Find the best and nearest services'.tr(),
      image: 'lib/page/task_screens/assets/icons/3.gif',
      description:
          "Find the nearest helpline with ease. Find the nearest hospital and pharmacy. All on your fingertips".tr()),
  UnbordingContent(
      title: 'Track your progress'.tr(),
      image: 'lib/page/task_screens/assets/icons/4.gif',
      description:
          "Take control of your medication. Never miss a dose again. Stay organized. Stay healthy".tr()),
];
