import 'package:doctor/models/doctor.dart';
import 'package:flutter/cupertino.dart';

class Details {
  final List medicalnotes;
  final List labresults;
  final List prescription;
  final List diagnosis;
  final EhrDoctor doctordetails;

  Details({
    @required this.medicalnotes,
    @required this.labresults,
    @required this.prescription,
    @required this.diagnosis,
    @required this.doctordetails,
  });
}
