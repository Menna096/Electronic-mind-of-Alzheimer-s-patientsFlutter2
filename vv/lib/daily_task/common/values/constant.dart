import 'package:easy_localization/easy_localization.dart';

class AppConstant {
  static String get INITIAL_RECURRENCE => 'no_recurrence'.tr();
  static String get INITIAL_LIST => 'default_list'.tr();
  
  static List<String> get RECURRENCE => [
    'no_recurrence'.tr(),
    'hourly'.tr(),
    'daily'.tr(),
    'weekly'.tr(),
  ];

  static List<String> get LIST => [
    'default_list'.tr(),
    'personal'.tr(),
    'shopping'.tr(),
    'wishlist'.tr(),
  ];
}
