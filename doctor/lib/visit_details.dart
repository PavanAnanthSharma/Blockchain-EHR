import 'package:doctor/models/doctor.dart';
import 'package:doctor/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/transaction.dart';

import 'widgets/custom_card.dart';
import 'widgets/custom_text.dart';

class VisitDetails extends StatefulWidget {
  final Transaction transaction;
  VisitDetails(this.transaction);
  @override
  _VisitDetailsState createState() => _VisitDetailsState();
}

class _VisitDetailsState extends State<VisitDetails> {
  var isloading = false;

  // @override
  // void didChangeDependencies() async {
  //   setState(() {
  //     isloading = true;
  //   });
  //   await Provider.of<DoctorAuthProvider>(context, listen: false)
  //       .getTransactiondetails(
  //     widget.transaction.sender,
  //     widget.transaction.receiver,
  //   );
  //   setState(() {
  //     isloading = false;
  //   });
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;
    final EhrDoctor doctordetails =
        Provider.of<DoctorAuthProvider>(context, listen: false).ehrDoctor;
    List medicalNotes = [];
    List labResults = [];
    List prescription = [];
    List diagnosis = [];
    for (var item in widget.transaction.details) {
      medicalNotes = item.medicalnotes;
      diagnosis = item.diagnosis;
      prescription = item.prescription;
      labResults = item.labresults;
    }
    return Scaffold(
      appBar: AppBar(
        title: CustomText('Health Record'),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: deviceheight,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Card(
                    elevation: 7,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text('Doctor: ${doctordetails.name}'),
                      subtitle: Text('${doctordetails.hospital}'),
                      leading: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  SizedBox(height: 10),
                  CustomText('Medical Notes', fontweight: FontWeight.bold),
                  SizedBox(height: 10),
                  CustomCard(medicalNotes, Icons.assignment),
                  SizedBox(height: 10),
                  CustomText('Lab Results', fontweight: FontWeight.bold),
                  SizedBox(height: 10),
                  CustomCard(labResults, Icons.format_list_bulleted),
                  SizedBox(height: 10),
                  CustomText('Prescription', fontweight: FontWeight.bold),
                  SizedBox(height: 10),
                  CustomCard(prescription, Icons.grain),
                  SizedBox(height: 10),
                  CustomText('Diagnosis', fontweight: FontWeight.bold),
                  SizedBox(height: 10),
                  CustomCard(diagnosis, Icons.format_align_center),
                ],
              ),
            ),
    );
  }
}
