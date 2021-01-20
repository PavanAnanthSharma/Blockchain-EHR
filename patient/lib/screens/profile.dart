import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patient/providers/auth_provider.dart';
import 'package:patient/widgets/custom_tile.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void showSnackBarMessage(String message) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: CustomText(message),
      ),
    );
  }

  var _isloading = false;

  @override
  Widget build(BuildContext context) {
    DocumentReference users = FirebaseFirestore.instance
        .collection('Users')
        .doc(Provider.of<UserAuthProvider>(context).userid);

    final deviceheight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: CustomText('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: users.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: CustomText('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomText("Loading"));
          }
          return Container(
            height: deviceheight,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Container(
                  height: deviceheight * 0.33,
                  child: Image.asset(
                    snapshot.data['gender'] == 'Male'
                        ? 'assets/male_patient.png'
                        : 'assets/female_patient.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 5),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(10),
                    physics: ClampingScrollPhysics(),
                    children: [
                      SizedBox(height: 5),
                      CustomText(
                        'Hello, ${snapshot.data['name'][0].toUpperCase()}${snapshot.data['name'].substring(1)}',
                        alignment: TextAlign.center,
                        fontsize: 20,
                        fontweight: FontWeight.bold,
                      ),
                      SizedBox(height: 10),
                      CustomTile(
                        leadingiconData: Icons.person,
                        title: 'Account',
                        subtitle: 'Update your profile',
                        iconData: Icons.navigate_next,
                        onpressed: () {
                          Navigator.of(context)
                              .pushNamed('edit_account',
                                  arguments: snapshot.data)
                              .then(
                                (value) => {
                                  if (value != null)
                                    {showSnackBarMessage(value)}
                                },
                              );
                        },
                      ),
                      Divider(color: Colors.grey, endIndent: 20, indent: 10),
                      CustomTile(
                        title: 'Ehr keys',
                        subtitle: 'View your public and private keys',
                        iconData: Icons.navigate_next,
                        leadingiconData: Icons.lock,
                        onpressed: () {
                          Navigator.of(context)
                              .pushNamed('view_keys', arguments: {
                            'publickey': snapshot.data['publickey'],
                            'privatekey': snapshot.data['privatekey'],
                          });
                        },
                      ),
                      Divider(color: Colors.grey, endIndent: 20, indent: 10),
                      CustomTile(
                        title: 'Settings',
                        subtitle: 'Explore app settings',
                        leadingiconData: Icons.settings,
                        iconData: Icons.navigate_next,
                        onpressed: () {
                          Navigator.of(context).pushNamed('settings_page');
                        },
                      ),
                      Divider(color: Colors.grey, endIndent: 20, indent: 10),
                      CustomTile(
                        title: 'Logout',
                        subtitle: 'Logout from your account',
                        iconData: Icons.navigate_next,
                        leadingiconData: Icons.exit_to_app,
                        onpressed: () {
                          setState(() {
                            _isloading = true;
                          });
                          Provider.of<UserAuthProvider>(context, listen: false)
                              .logout();
                          setState(() {
                            _isloading = false;
                          });
                        },
                        iconcolor: Theme.of(context).accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
