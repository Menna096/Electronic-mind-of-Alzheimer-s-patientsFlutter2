import 'package:flutter/material.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/models/medicine.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MedicineDetails extends StatefulWidget {
  const MedicineDetails(this.medicine, {Key? key}) : super(key: key);
  final Medicine medicine;

  @override
  State<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            children: [
              if (widget.medicine != null) ...[
                MainSection(medicine: widget.medicine),
                ExtendedSection(medicine: widget.medicine),
                SizedBox(
                  width: 100.w,
                  height: 7.h,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      openAlertBox(context, _globalBloc);
                    },
                    child: Text(
                      'Delete',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: kScaffoldColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
              ] else
                Text('No medicine data available'),
            ],
          ),
        ),
      ),
    );
  }

  openAlertBox(BuildContext context, GlobalBloc _globalBloc) {
    return showDialog(
      context: context,
      builder: (context) {
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
            'Delete This Reminder?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            TextButton(
              onPressed: () {
                _globalBloc.removeMedicine(widget.medicine);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text(
                'OK',
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: kSecondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MainSection extends StatelessWidget {
  const MainSection({Key? key, required this.medicine}) : super(key: key);
  final Medicine? medicine;

  Hero makeIcon(double size) {
    if (medicine != null && medicine!.medicineType != null) {
      if (medicine!.medicineType == 'Bottle') {
        return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'lib/page/task_screens/assets/icons/liquid.gif',
            height: 14.h,
          ),
        );
      } else if (medicine!.medicineType == 'Pill') {
        return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'lib/page/task_screens/assets/icons/pills.gif',
            height: 14.h,
          ),
        );
      } else if (medicine!.medicineType == 'Syringe') {
        return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'lib/page/task_screens/assets/icons/syringe.gif',
            height: 14.h,
          ),
        );
      } else if (medicine!.medicineType == 'Tablet') {
        return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'lib/page/task_screens/assets/icons/tablet.gif',
            height: 14.h,
          ),
        );
      }
    }
    return Hero(
      tag: medicine!.medicineName! + medicine!.medicineType!,
      child: Icon(
        Icons.error,
        color: kOtherColor,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        makeIcon(7.h),
        SizedBox(
          width: 2.w,
        ),
        Column(
          children: [
            if (medicine != null && medicine!.medicineName != null)
              Hero(
                tag: medicine!.medicineName!,
                child: Material(
                  color: Colors.transparent,
                  child: MainInfoTab(
                    fieldTitle: 'Medicine Name',
                    fieldInfo: medicine!.medicineName!,
                  ),
                ),
              ),
            MainInfoTab(
              fieldTitle: 'Dosage',
              fieldInfo: medicine != null && medicine!.dosage != null
                  ? (medicine!.dosage == 0 ? 'Not Specified' : "${medicine!.dosage} mg")
                  : 'Dosage not available',
            ),
          ],
        )
      ],
    );
  }
}

class MainInfoTab extends StatelessWidget {
  const MainInfoTab(
      {Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);
  final String fieldTitle;
  final String fieldInfo;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 10.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldTitle,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(
              height: 0.3.h,
            ),
            Text(
              fieldInfo,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }
}

class ExtendedSection extends StatelessWidget {
  const ExtendedSection({Key? key, required this.medicine}) : super(key: key);
  final Medicine? medicine;
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(
          fieldTitle: 'Medicine Type ',
          fieldInfo: medicine != null && medicine!.medicineType != null
              ? (medicine!.medicineType == 'None' ? 'Not Specified' : medicine!.medicineType!)
              : 'Medicine type not available',
        ),
        ExtendedInfoTab(
          fieldTitle: 'Dose Interval',
          fieldInfo: medicine != null && medicine!.interval != null
              ? ('Every ${medicine!.interval} hours   | ${medicine!.interval == 24 ? "One time a day" : "${(24 / medicine!.interval!).floor()} times a day"}')
              : 'Dose interval not available',
        ),
        ExtendedInfoTab(
          fieldTitle: 'Start Time',
          fieldInfo: medicine != null && medicine!.startTime != null
              ? ('${medicine!.startTime![0]}${medicine!.startTime![1]}:${medicine!.startTime![2]}${medicine!.startTime![3]}')
              : 'Start time not available',
        ),
       ExtendedInfoTab(
  fieldTitle: 'End Date',
  fieldInfo: medicine != null && medicine!.endTime != null
      ? '${medicine!.endTime!.year}-${medicine!.endTime!.month}-${medicine!.endTime!.day}'
      : 'End date not available',
),

      ],
    );
  }
}

class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab(
      {Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);
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
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: kTextColor,
                  ),
            ),
          ),
          Text(
            fieldInfo,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: kSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}

