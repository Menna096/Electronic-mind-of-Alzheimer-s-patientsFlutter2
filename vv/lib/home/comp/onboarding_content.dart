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
      title: 'Never forget your medicine again!',
      image: 'lib/home/image/1.gif',
      description:
          "Remember what to take, when to take, when to refill. Never miss a dose again."),
  UnbordingContent(
      title: 'Find the best and nearest services!',
      image: 'lib/home/image/3.gif',
      description:
          "Find the nearest helpline with ease. Find the nearest hospital and pharmacy. All on your fingertips"),
  UnbordingContent(
      title: 'Track your progress!',
      image: 'lib/home/image/4.gif',
      description:
          "Take control of your medication. Never miss a dose again. Stay organized. Stay healthy!"),
];
