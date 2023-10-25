import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _deccontroller = TextEditingController();
  TextEditingController _bidController = TextEditingController();
  DateTime? selectedDate;
  XFile? image;
  String? imageUrl;
  XFile? imageTemp;
  FirebaseStorage storage = FirebaseStorage.instance;
  Future<String?> uploadImageToFirebase(XFile imageFile) async {
    try {
      File file = File(imageFile.path);
      String fileName = file.path.split('/').last;
      Reference reference = storage.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await (await snapshot.ref.getDownloadURL());
      print(downloadUrl);
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (image == null) return;
      final imageTemp = XFile(image!.path);
      print("olduuu");
      String? imageUrl = await uploadImageToFirebase(imageTemp);
      setState(() => this.imageUrl = imageUrl);
      print("gfd");
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.arrow_left,
                        color: Colors.black,
                        size: 28,
                      )),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Item",
                      style: TextStyle(
                          fontSize: 38,
                          fontFamily: "Alkatra",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        label(" Item Image"),
                        IconButton(
                            color: Colors.black,
                            icon: Icon(
                              Icons.add_a_photo,
                              size: 25,
                            ),
                            onPressed: () {
                              pickImage();
                            }),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildImage(),
                    label(" Item Name"),
                    SizedBox(
                      height: 12,
                    ),
                    title(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(height: 20),
                    label(" Description"),
                    SizedBox(
                      height: 12,
                    ),
                    Descrip(),
                    SizedBox(
                      height: 40,
                    ),
                    label("Starting Bid"),
                    bid(),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Select End Day',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (selectedDate != null) ...[
                      Text(
                          "Selected End Day: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"),
                    ],
                    SizedBox(
                      height: 40,
                    ),
                    button(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getUsernameFromFirestore(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot?['username'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting username: $e");
      return null;
    }
  }

  Future<void> addItem() async {
    double bidAmount = double.tryParse(_bidController.text) ?? 0.0;

    if (bidAmount > 0) {
      String? username = await getUsernameFromFirestore(
          FirebaseAuth.instance.currentUser!.uid);
      await FirebaseFirestore.instance.collection("Item").add({
        "name": _namecontroller.text,
        "description": _deccontroller.text,
        "thumbnailUrl": imageUrl,
        "bide": bidAmount,
        "endDate": Timestamp.fromDate(selectedDate!),
        "uplodedBy": username,
      }).then((value) {
        print("Item added with ID: ${value.id}");
        Navigator.pop(context);
      }).catchError((error) {
        print("Error adding item: $error");
      });
    } else {
      print("Invalid bid amount.");
      _showErrorSnackBar("Invalid bid amount.Bit must be more than 0");
    }
  }

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget button() {
    return InkWell(
      onTap: () async {
        addItem();
      },
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Add Item",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: "Alkatra"),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null) {
      return Text("No image selected");
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Image.network(imageUrl!),
      );
    }
  }

  Widget Descrip() {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white54,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _deccontroller,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Item Description",
          hintStyle: TextStyle(color: Colors.black, fontSize: 15),
          contentPadding: EdgeInsets.only(left: 20, right: 20),
        ),
      ),
    );
  }

  Widget title() {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white54,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ], // changes position of shadow
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _namecontroller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Item Name",
          hintStyle: TextStyle(color: Colors.black, fontSize: 15),
          contentPadding: EdgeInsets.only(left: 20, right: 20),
        ),
      ),
    );
  }

  Widget bid() {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white54,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ], // changes position of shadow
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _bidController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Item Name",
          hintStyle: TextStyle(color: Colors.black, fontSize: 15),
          contentPadding: EdgeInsets.only(left: 20, right: 20),
        ),
      ),
    );
  }

  Widget label(String label) {
    return Text(
      label,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          fontFamily: "Alkatra",
          letterSpacing: 0.2),
    );
  }
}
