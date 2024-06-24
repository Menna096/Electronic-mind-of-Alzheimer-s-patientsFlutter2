

import 'package:vv/Chatbot/helpers/texts.dart';

import 'action_answer.dart';

abstract class ActionChatbot {
  String title;
  String name;
  String methodName;
  ActionAnswerRequest? answerRequest;

  ActionChatbot({required this.title, required this.name, required this.methodName});

  List<dynamic> args = [];

  ActionChatbot withArgs(List<dynamic> args) {
    this.args = args;
    return this;
  }

  factory ActionChatbot.getActionByName(String name) {
    final actionName = name.trim().toLowerCase();
    for (ActionChatbot action in [CreateAlarmAction(), SearchAction(), ShowAllTasksAction(), CreateTaskAction()]) {
      if (action.name == actionName) return action;
    }
    return UnknownAction();
  }
}

class CreateAlarmAction extends ActionChatbot {
  DateTime? alarmTime;

  CreateAlarmAction() : super(title: Texts.createAlarmAtGivenTime, name: "alarm", methodName: Texts.createAlarmAction);
}

class SearchAction extends ActionChatbot {
  SearchAction() : super(title: Texts.searchForSomeone, name: "search", methodName: Texts.searchForSomeoneAction);
}

class ShowAllTasksAction extends ActionChatbot {
  ShowAllTasksAction() : super(title: Texts.showAllTasks, name: "show_all_tasks", methodName: Texts.showAllTasksAction);
}

class CreateTaskAction extends ActionChatbot {
  CreateTaskAction() : super(title: Texts.createNewTask, name: "task", methodName: Texts.createNewTaskAction);
}

class UnknownAction extends ActionChatbot {
  UnknownAction() : super(title: Texts.unknownAction, name: "unknown", methodName: "unknown");
}
