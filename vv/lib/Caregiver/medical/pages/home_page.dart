import 'package:flutter/material.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/models/medicine.dart';
import 'package:vv/Caregiver/medical/pages/medicine_details/medicine_details.dart';
import 'package:vv/Caregiver/medical/pages/new_entry/new_entry_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text('Medication!',
          style: TextStyle(fontSize: 25),),
         
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            children: [
              const TopContainer(),
              SizedBox(
                height: 2.h,
              ),
              //the widget take space as per need
              const Flexible(
                child: BottomContainer(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          // go to new entry page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEntryPage(),
            ),
          );
        },
        child: SizedBox(
          width: 18.w,
          height: 9.h,
          child: Card(
            color: kPrimaryColor,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: Icon(
              Icons.medication,
              color: kScaffoldColor,
              size: 30.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            bottom: 1.h,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);

    return StreamBuilder(
      stream: globalBloc.medicineList$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          //if no data is saved
          return Container();
        } else if (snapshot.data!.isEmpty) {
          return Center(
            child: Container(
              child: Text(
                'No Medicine Yet!',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: Colors.white), // Adjust text color
              ),
            ),
          );
        } else {
          return GridView.builder(
            padding: EdgeInsets.only(top: 1.h),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return MedicineCard(medicine: snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({Key? key, required this.medicine}) : super(key: key);
  final Medicine medicine;

  Widget makeIcon(double size) {
    if (medicine.medicineType == 'Bottle') {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Image.asset(
          'lib/page/task_screens/assets/icons/liquid.gif',
          height: 13.5.h,
        ),
      );
    } else if (medicine.medicineType == 'Pill') {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Image.asset(
          'lib/page/task_screens/assets/icons/pills.gif',
          height: 13.5.h,
        ),
      );
    } else if (medicine.medicineType == 'Syringe') {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Image.asset(
          'lib/page/task_screens/assets/icons/syringe.gif',
          height: 13.5.h,
        ),
      );
    } else if (medicine.medicineType == 'Tablet') {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Image.asset(
          'lib/page/task_screens/assets/icons/tablet.gif',
          height: 13.5.h,
        ),
      );
    }
    return Hero(
      tag: medicine.medicineName! + medicine.medicineType!,
      child: Icon(
        Icons.error,
        color: kOtherColor,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.white,
      splashColor: Colors.grey,
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, Widget? child) {
                  return Opacity(
                    opacity: animation.value,
                    child: MedicineDetails(medicine),
                  );
                },
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 1.h),
        margin: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            makeIcon(7.h),
            const Spacer(),
            Hero(
              tag: medicine.medicineName!,
              child: Text(
                medicine.medicineName!,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(
              height: 0.3.h,
            ),
            Text(
              medicine.interval == 1
                  ? "Every ${medicine.interval} hour"
                  : "Every ${medicine.interval} hour",
              overflow: TextOverflow.fade,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
