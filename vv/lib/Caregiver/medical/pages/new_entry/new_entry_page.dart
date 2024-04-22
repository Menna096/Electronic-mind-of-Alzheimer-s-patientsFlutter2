import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/models/errors.dart';
import 'package:vv/Caregiver/medical/models/medicine.dart';
import 'package:vv/Caregiver/medical/pages/home_page.dart';
import 'package:vv/Caregiver/medical/pages/new_entry/new_entry_bloc.dart';
import 'package:vv/Caregiver/medical/pages/success_screen/success_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import '../../common/convert_time.dart';
import '../../models/medicine_type.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({Key? key}) : super(key: key);

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NewEntryBloc _newEntryBloc;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  final SecureStorageManager storageManager = SecureStorageManager();
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
    _newEntryBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _newEntryBloc = NewEntryBloc();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initializeNotifications();
    initializeErrorListen();
  }

  Future<void> postMedicationData() async {
    Dio dio = Dio();
    final String apiUrl =
        "https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/AddMedicationReminder";

    // Retrieve patient ID securely
    String? patientId = await storageManager.getPatientId();
    if (patientId == null) {
      print("Error: Patient ID is null");
      return; // Early return if patient ID is not found
    }

    // Full API URL with patient ID
    final String fullApiUrl = "$apiUrl/$patientId";

    // Data map with null safety checks
    Map<String, dynamic> data = {
      "medication_Name": nameController.text,
      "dosage": dosageController.text,
      "medicineType": _newEntryBloc
          .selectedMedicineType?.value.index, // Directly as integer
      "repeater": _newEntryBloc.selectIntervals?.value, // Directly as integer
      "startDate": _newEntryBloc.selectedDate$?.value?.toIso8601String(),
      "endDate": _newEntryBloc.selectedDate$?.value?.toIso8601String()
    };

    try {
      // Send a POST request using Dio
      Response response = await DioService().dio.post(fullApiUrl, data: data);
      if (response.statusCode == 200) {
        print("Success: ${response.data}");
      } else {
        print("Failed: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("Dio error: $e");
      // Handle Dio-specific errors (e.g., network issues)
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add New'),
      ),
      body: SingleChildScrollView(
        child: Provider<NewEntryBloc>.value(
          value: _newEntryBloc,
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PanelTitle(
                  title: 'Medicine Name',
                  isRequired: true,
                ),
                TextFormField(
                  maxLength: 12,
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: kOtherColor),
                ),
                const PanelTitle(
                  title: 'Dosage in mg',
                  isRequired: false,
                ),
                TextFormField(
                  maxLength: 12,
                  controller: dosageController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: kOtherColor),
                ),
                SizedBox(
                  height: 1.h,
                ),
                const PanelTitle(title: 'Medicine Type', isRequired: true),
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: StreamBuilder<MedicineType>(
                    //new entry block
                    stream: _newEntryBloc.selectedMedicineType,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //not yet clickable?
                          MedicineTypeColumn(
                              medicineType: MedicineType.Bottle,
                              name: 'Bottle',
                              iconValue:
                                  'lib/page/task_screens/assets/icons/liquid.gif',
                              isSelected: snapshot.data == MedicineType.Bottle
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Pill,
                              name: 'Pill',
                              iconValue:
                                  'lib/page/task_screens/assets/icons/pills.gif',
                              isSelected: snapshot.data == MedicineType.Pill
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Syringe,
                              name: 'Syringe',
                              iconValue:
                                  'lib/page/task_screens/assets/icons/syringe.gif',
                              isSelected: snapshot.data == MedicineType.Syringe
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Tablet,
                              name: 'Tablet',
                              iconValue:
                                  'lib/page/task_screens/assets/icons/tablet.gif',
                              isSelected: snapshot.data == MedicineType.Tablet
                                  ? true
                                  : false),
                        ],
                      );
                    },
                  ),
                ),
                const PanelTitle(title: 'Interval Selection', isRequired: true),
                const IntervalSelection(),
                const PanelTitle(title: 'Starting Time', isRequired: true),
                const SelectTime(),
                const PanelTitle(title: 'Ending Day', isRequired: true),
                const SelectDate(),
                Text(
                  "_______________________________________________________",
                  style: TextStyle(color: Color(0xff3B5998)),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.w,
                    right: 8.w,
                  ),
                  child: SizedBox(
                    width: 80.w,
                    height: 8.h,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 20, 191, 80),
                        shape: const StadiumBorder(),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'ConcertOne',
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      onPressed: () async {
                        String? medicineName;
                        int? dosage;

                        if (nameController.text.isEmpty) {
                          _newEntryBloc.submitError(EntryError.nameNull);
                          return;
                        }
                        medicineName = nameController.text;

                        if (dosageController.text.isEmpty) {
                          dosage = 0;
                        } else {
                          dosage = int.tryParse(dosageController.text) ?? 0;
                        }

                        if (globalBloc.medicineList$!.value.any((medicine) =>
                            medicineName == medicine.medicineName)) {
                          _newEntryBloc.submitError(EntryError.nameDuplicate);
                          return;
                        }
                        if (_newEntryBloc.selectIntervals!.value == 0) {
                          _newEntryBloc.submitError(EntryError.interval);
                          return;
                        }
                        if (_newEntryBloc.selectedTimeOfDay$!.value == 'None') {
                          _newEntryBloc.submitError(EntryError.startTime);
                          return;
                        }
                        if (_newEntryBloc.selectedDate$!.value == null) {
                          _newEntryBloc.submitError(EntryError.endTime);
                          return;
                        }

                        String medicineType = _newEntryBloc
                            .selectedMedicineType!.value
                            .toString()
                            .substring(13);
                        int interval = _newEntryBloc.selectIntervals!.value;
                        String startTime =
                            _newEntryBloc.selectedTimeOfDay$!.value;
                        var endTime = _newEntryBloc.selectedDate$!.value;

                        List<int> intIDs =
                            makeIDs(24 / _newEntryBloc.selectIntervals!.value);
                        List<String> notificationIDs =
                            intIDs.map((i) => i.toString()).toList();

                        Medicine newEntryMedicine = Medicine(
                          notificationIDs: notificationIDs,
                          medicineName: medicineName,
                          dosage: dosage,
                          medicineType: medicineType,
                          interval: interval,
                          startTime: startTime,
                          endTime: endTime,
                        );

                        globalBloc.updateMedicineList(newEntryMedicine);
                        scheduleNotification(newEntryMedicine);

                        try {
                          await postMedicationData();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen()));
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add medication: $error"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$!.listen((EntryError error) {
      switch (error) {
        case EntryError.nameNull:
          displayError("Please enter the medicine's name");
          break;

        case EntryError.nameDuplicate:
          displayError("Medicine name already exists");
          break;
        case EntryError.dosage:
          displayError("Please enter the dosage required");
          break;
        case EntryError.interval:
          displayError("Please select the reminder's interval");
          break;
        case EntryError.startTime:
          displayError("Please select the reminder's starting time");
          break;
        case EntryError.endTime:
          displayError("Please select the reminder's Ending Day");
          break;
        default:
      }
    });
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kOtherColor,
        content: Text(error),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');

    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  Future<void> scheduleNotification(Medicine medicine) async {
    var hour = int.parse(medicine.startTime![0] + medicine.startTime![1]);
    var ogValue = hour;
    var minute = int.parse(medicine.startTime![2] + medicine.startTime![3]);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id', 'repeatDailyAtTime channel name',
        importance: Importance.max,
        ledColor: kOtherColor,
        sound:
            RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true);

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    for (int i = 0; i < (24 / medicine.interval!).floor(); i++) {
      if (hour + (medicine.interval! * i) > 23) {
        hour = hour + (medicine.interval! * i) - 24;
      } else {
        hour = hour + (medicine.interval! * i);
      }
      await flutterLocalNotificationsPlugin.periodicallyShow(
          int.parse(medicine.notificationIDs![i]),
          'Reminder: ${medicine.medicineName}',
          medicine.medicineType.toString() != MedicineType.None.toString()
              ? 'It is time to take your ${medicine.medicineType!.toLowerCase()}, according to schedule'
              : 'It is time to take your medicine, according to schedule',
          TimeOfDay(hour: hour, minute: minute) as RepeatInterval,
          platformChannelSpecifics);
      hour = ogValue;
    }
  }
}

class SelectDate extends StatefulWidget {
  const SelectDate({Key? key}) : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  DateTime _date = DateTime.now();
  bool _clicked = false;

  Future<void> _selectDate() async {
    final NewEntryBloc newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _clicked = true;

        // Update state via provider
        newEntryBloc.updateDate(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7.h, ////////////////
      child: Padding(
        padding: EdgeInsets.only(top: 1.h),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor, shape: const StadiumBorder()),
          onPressed: _selectDate,
          child: Center(
            child: Text(
              _clicked ? "${_date.toString().split(' ')[0]}" : "Select Date",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: kScaffoldColor),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({Key? key}) : super(key: key);

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay> _selectTime() async {
    final NewEntryBloc newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);

    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;

        //update state via provider, we will do later
        newEntryBloc.updateTime(convertTime(_time.hour.toString()) +
            convertTime(_time.minute.toString()));
      });
    }
    return picked!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor, shape: const StadiumBorder()),
          onPressed: () {
            _selectTime();
          },
          child: Center(
            child: Text(
              _clicked
                  ? "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}"
                  : "Select Time",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: kScaffoldColor),
            ),
          ),
        ),
      ),
    );
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({Key? key}) : super(key: key);

  @override
  State<IntervalSelection> createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [6, 8, 12, 24];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Remind me every',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: kTextColor,
                ),
          ),
          DropdownButton(
            iconEnabledColor: kOtherColor,
            dropdownColor: kScaffoldColor,
            itemHeight: 8.h,
            hint: _selected == 0
                ? Text(
                    'Select an Interval',
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: kPrimaryColor,
                        ),
                  )
                : null,
            elevation: 4,
            value: _selected == 0 ? null : _selected,
            items: _intervals.map(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: kSecondaryColor,
                        ),
                  ),
                );
              },
            ).toList(),
            onChanged: (newVal) {
              setState(
                () {
                  _selected = newVal!;
                  newEntryBloc.updateInterval(newVal);
                },
              );
            },
          ),
          Text(
            _selected == 1 ? " hour" : " hours",
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: kTextColor),
          ),
        ],
      ),
    );
  }
}

class MedicineTypeColumn extends StatelessWidget {
  const MedicineTypeColumn(
      {Key? key,
      required this.medicineType,
      required this.name,
      required this.iconValue,
      required this.isSelected})
      : super(key: key);
  final MedicineType medicineType;
  final String name;
  final String iconValue;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return GestureDetector(
      onTap: () {
        //select medicine type
        //lets create a new block for selecting and adding new entry
        newEntryBloc.updateSelectedMedicine(medicineType);
      },
      child: Column(
        children: [
          Container(
            width: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.h),
                color: isSelected
                    ? Color.fromARGB(255, 166, 169, 174)
                    : Colors.white),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 1.h,
                  bottom: 1.h,
                ),
                child: Image.asset(
                  iconValue,
                  height: 7.h,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
              width: 20.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(1.h),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: isSelected ? Colors.white : kTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const PanelTitle({Key? key, required this.title, required this.isRequired})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: kTextColor,
                ),
          ),
        ],
      ),
    );
  }
}
