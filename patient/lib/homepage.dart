import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/block.dart';
import 'models/transaction.dart';
import 'providers/record_provider.dart';
import 'visit_details.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Block> _updatedrecords = [];
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  CalendarController _calendarController;

  var _isloading = false;
  var _erroroccurred = false;
  var i = 0;
  var _chosen = DateTime.now();
  final _selectedDay = DateTime.now();

  @override
  void initState() {
    setState(() {
      _isloading = true;
    });
    fetch().then((value) => {
          setState(() {
            _isloading = false;
          }),
        });
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    final provider = Provider.of<RecordsProvider>(context, listen: false);

    try {
      await provider.loadKeys();
      final publicKey = provider.publickey;
      await provider.getPatientChain(publicKey);
      await provider.resolveConflicts();

      _updatedrecords = provider.records;

      while (i < _updatedrecords.length) {
        _events.putIfAbsent(
          DateTime.fromMillisecondsSinceEpoch(
              double.parse(_updatedrecords[i].timestamp).toInt() * 1000),
          () => _updatedrecords[i].transaction,
        );
        i++;
      }
      _selectedEvents = _events[_selectedDay] ?? [];
      _calendarController = CalendarController();
    } catch (e) {
      setState(() {
        _erroroccurred = true;
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: CustomText('Ehr Kenya', fontsize: 20)),
      body: _erroroccurred
          ? ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  height: deviceheight * 0.5,
                  child: Image.asset(
                    'assets/404.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'An Error Occured!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                SizedBox(height: 20),
                Text(
                  'The Server may be offline, please retry after some time',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Center(
                    child: CustomButton('Retry', () {
                  setState(() {
                    _erroroccurred = false;
                  });
                  setState(() {
                    _isloading = true;
                  });
                  fetch().then((value) => {
                        setState(() {
                          _isloading = false;
                        }),
                      });
                }))
              ],
            )
          : _isloading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: deviceheight,
                  padding: EdgeInsets.all(10),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TableCalendar(
                        headerStyle: HeaderStyle(centerHeaderTitle: true),
                        events: _events,
                        availableCalendarFormats: {
                          CalendarFormat.month: 'Month'
                        },
                        calendarController: _calendarController,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        availableGestures: AvailableGestures.horizontalSwipe,
                        initialCalendarFormat: CalendarFormat.month,
                        calendarStyle: CalendarStyle(
                          selectedColor:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                          todayColor: Theme.of(context).primaryColor,
                          markersColor: Theme.of(context).primaryColor,
                          outsideDaysVisible: false,
                        ),
                        onDaySelected: (day, events, holidays) {
                          _chosen = day;
                          setState(() {
                            _selectedEvents = events;
                          });
                        },
                        builders: CalendarBuilders(
                          markersBuilder: (context, date, events, holidays) {
                            final children = <Widget>[];
                            if (events.isNotEmpty) {
                              children.add(
                                Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: _buildEventsMarker(date, events),
                                ),
                              );
                            }
                            return children;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildEventList(_chosen),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.7),
      ),
      width: 8.0,
      height: 8.0,
    );
  }

  Widget _buildEventList(DateTime day) {
    final f = DateFormat('dd-MM-yyyy');
    final transactionformat = DateFormat().add_jms();

    String tapped = DateFormat().add_yMMMMEEEEd().format(day);
    String chosenday = f.format(day);

    final List<Transaction> fetchedtransaction = [];

    final _newupdatedrecords = _updatedrecords
        .where(
          (element) =>
              f.format(
                DateTime.fromMillisecondsSinceEpoch(
                    double.parse(element.timestamp).toInt() * 1000),
              ) ==
              chosenday,
        )
        .toList();

    _newupdatedrecords.forEach((element) {
      element.transaction.forEach((element) {
        fetchedtransaction.add(element);
      });
    });

    return fetchedtransaction.length > 0
        ? Card(
            elevation: 7,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              physics: ClampingScrollPhysics(),
              children: [
                SizedBox(height: 10),
                CustomText(
                  '$tapped',
                  alignment: TextAlign.center,
                  fontweight: FontWeight.bold,
                ),
                CustomText(
                  'You had ${fetchedtransaction.length} visits on this day.',
                  alignment: TextAlign.center,
                ),
                Divider(color: Colors.black, indent: 20, endIndent: 20),
                ListView.separated(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Divider(
                    indent: 20,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) => ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Icon(Icons.history),
                    title: Text(
                      'View visit at ${transactionformat.format(fetchedtransaction[index].timestamp)}',
                    ),
                    trailing: IconButton(
                      iconSize: 30,
                      color: Theme.of(context).primaryColor,
                      icon: Icon(Icons.navigate_next),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VisitDetails(
                              fetchedtransaction[index],
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VisitDetails(
                            fetchedtransaction[index],
                          ),
                        ),
                      );
                    },
                  ),
                  itemCount: fetchedtransaction.length,
                ),
              ],
            ),
          )
        : ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: [
              CustomText(
                'You have no visits for this date',
                alignment: TextAlign.center,
                fontweight: FontWeight.bold,
              ),
              SizedBox(height: 20),
              Icon(
                Icons.event_busy_rounded,
                color: Theme.of(context).accentColor,
                size: 100,
              ),
            ],
          );
  }
}
