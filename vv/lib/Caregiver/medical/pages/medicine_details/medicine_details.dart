import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/pages/success_screen/success_screen.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';

class MedicineDetails extends StatefulWidget {
  final dynamic data; // Accepting dynamic data directly
  final VoidCallback onDelete; // Callback to notify deletion
  const MedicineDetails({super.key, required this.data, required this.onDelete});

  @override
  _MedicineDetailsState createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            children: [
              if (widget.data != null) ...[
                MainSection(data: widget.data),
                ExtendedSection(data: widget.data),
                SizedBox(
                  width: 100.w,
                  height: 7.h,
                  child: Builder(
                    // Use Builder to provide correct context
                    builder: (context) => TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        openAlertBox(context);
                      },
                      child: Text(
                        'Delete'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: kScaffoldColor),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ] else
                Text('No medicine data available'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  void openAlertBox(BuildContext context) {
    final SecureStorageManager storageManager = SecureStorageManager();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kScaffoldColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          contentPadding: EdgeInsets.only(top: 1.h),
          title: Text(
            'Delete This Reminder?'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'.tr(), style: Theme.of(context).textTheme.bodySmall),
            ),
            TextButton(
              onPressed: () async {
                try {
                  String? reminderId = widget.data['reminderId'].toString();
                  print("Reminder ID: $reminderId"); // Debug print
                  var response = await DioService().dio.delete(
                      'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/DeleteMedicationReminder/$reminderId');
                  print(
                      "Response Status: ${response.statusCode}"); // Debug print
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                        content: Text('Reminder Deleted Successfully'.tr())));
                    widget.onDelete();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SuccessScreen())); // Notify the HomePage of the deletion
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                        content: Text('Failed to Delete Reminder: ${response.statusCode}'.tr())));
                  }
                                } catch (e) {
                  print("Error: $e"); // Debug print
                  // ScaffoldMessenger.of(dialogContext)
                  //     .showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  // Ensuring navigation even if an error occurs
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  Navigator.pushReplacement(
                      dialogContext,
                      MaterialPageRoute(
                          builder: (context) => const mainpagecaregiver()));
                }
              },
              child: Text(
                'OK'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: kSecondaryColor),
              ),
            )
          ],
        );
      },
    );
  }
}

class MainSection extends StatelessWidget {
  final dynamic data;
  const MainSection({super.key, required this.data});

  // This function returns the widget for the icon based on the medicine type
  Widget _makeIcon(int type, double size) {
    switch (type) {
      case 0:
        return Image.asset('lib/page/task_screens/assets/icons/pills.gif'.tr(),
            height: size);
      case 1:
        return Image.asset('lib/page/task_screens/assets/icons/syringe.gif',
            height: size);
      case 2:
        return Image.asset('lib/page/task_screens/assets/icons/liquid.gif',
            height: size);
      case 3:
        return Image.asset('lib/page/task_screens/assets/icons/tablet.gif',
            height: size);
      default:
        return Icon(Icons.error,
            color: kOtherColor, size: size); // Default icon if type is unknown
    }
  }

  // This function converts the medicine type integer to a descriptive string
  String _getTypeName(int type) {
    switch (type) {
      case 0:
        return 'Pill'.tr();
      case 1:
        return 'Syringe'.tr();
      case 2:
        return 'Bottle'.tr();
      case 3:
        return 'Tablet'.tr();
      default:
        return 'Unknown Type'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    String medicineName = data['medication_Name'] ?? 'Unknown';
    int medicineType = data['medcineType']
        as int; // Make sure this key matches your data exactly
    String dosage = data['dosage'] ?? 'Not specified';
    String typeName = _getTypeName(medicineType); // Convert type to string name

    // Structure to layout the icon and type description
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            _makeIcon(medicineType, 7.h), // Display the icon
            Text(typeName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium), // Display the type name below the icon
          ],
        ),
        SizedBox(width: 2.w),
        Column(
          children: [
            Hero(
              tag:
                  "$medicineName-${medicineType.toString()}-$dosage", // Unique tag for Hero widget
              child: Material(
                color: Colors.transparent,
                child: MainInfoTab(
                  fieldTitle: 'Medicine Name'.tr(),
                  fieldInfo: medicineName,
                ),
              ),
            ),
            MainInfoTab(
              fieldTitle: 'Dosage'.tr(),
              fieldInfo: dosage,
            ),
          ],
        )
      ],
    );
  }
}

class ExtendedSection extends StatelessWidget {
  final dynamic data;
  const ExtendedSection({super.key, required this.data});

  // Method to convert medicine type code to string description
  static String _getTypeName(int type) {
    switch (type) {
      case 0:
        return 'Pill'.tr();
      case 1:
        return 'Syringe'.tr();
      case 2:
        return 'Bottle'.tr();
      case 3:
        return 'Tablet'.tr();
      default:
        return 'Unknown Type'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure medicineType is treated as an integer and safely fallback to 'Unknown Type' if null
    String medicineTypeString = _getTypeName(
        data['medcineType'] as int? ?? -1); // Safely handle possible null

    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(
          fieldTitle: 'Medicine Type'.tr(),
          fieldInfo: medicineTypeString, // Use the converted type name
        ),
        ExtendedInfoTab(
          fieldTitle: 'Dose Interval'.tr(),
          fieldInfo: '${data['repeater'] ?? "Interval not available"}'.tr(),
        ),
        ExtendedInfoTab(
          fieldTitle: 'Start Time'.tr(),
          fieldInfo: data['startDate'] != null
              ? DateFormat('HH:mm').format(DateTime.parse(data['startDate']))
              : 'Start time not available'.tr(),
        ),
        ExtendedInfoTab(
          fieldTitle: 'End Date'.tr(),
          fieldInfo: data['endDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['endDate']))
              : 'End date not available'.tr(),
        ),
      ],
    );
  }
}

class MainInfoTab extends StatelessWidget {
  final String fieldTitle;
  final String fieldInfo;
  const MainInfoTab(
      {super.key, required this.fieldTitle, required this.fieldInfo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 10.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fieldTitle, style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 0.3.h),
            Text(fieldInfo,
                style: Theme.of(context).textTheme.headlineSmall), // Corrected line
          ],
        ),
      ),
    );
  }
}

class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab(
      {super.key, required this.fieldTitle, required this.fieldInfo});
  final String fieldTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Text(
              fieldTitle,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: kTextColor,
                  ),
            ),
          ),
          Text(
            fieldInfo,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
