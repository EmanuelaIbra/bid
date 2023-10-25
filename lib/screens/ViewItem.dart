import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewItem extends StatefulWidget {
  const ViewItem({
    Key? key,
    required this.document,
    required this.id,
  }) : super(key: key);
  final Map<String, dynamic> document;
  final String id;
  @override
  State<ViewItem> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewItem> {
  late String label1;
  late String item1;
  late String image1;
  late double bid1;
  late DateTime endDate1;
  TextEditingController _newBidController = TextEditingController();
  @override
  void initState() {
    super.initState();
    label1 = widget.document["name"];
    item1 = widget.document['description'];
    image1 = widget.document["thumbnailUrl"] == null
        ? 'https://www.zdnet.com/a/img/2022/10/06/801c71b9-f8d8-46b3-aa3f-c10ee6932c36/iphone-14-plus.jpg'
        : widget.document["thumbnail"];
    bid1 = widget.document["bide"];
    Timestamp timestamp = widget.document["endDate"];
    endDate1 = timestamp.toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.white54),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.arrow_left,
                    color: Colors.black,
                    size: 28,
                  )),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.white,
                      Colors.indigo.shade100,
                      Colors.white
                    ]),
                  ),
                  child: Image(
                    image: NetworkImage(image1),
                    fit: BoxFit.contain,
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    label(label1),
                    SizedBox(height: 20),
                    description(item1),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "Current Bid(\$): ",
                          style: TextStyle(
                              fontSize: 16, // Metin boyutunu azalttık
                              fontFamily: "Alkatra",
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        bid(bid1),
                      ],
                    ),
                    SizedBox(height: 20),
                    endDate(endDate1),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 250,
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
                          child: TextField(
                            controller: _newBidController,
                            keyboardType: TextInputType
                                .number, // Sadece sayı girişine izin vermek için
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'New Bid',
                              hintStyle:
                                  TextStyle(color: Colors.black, fontSize: 15),
                              contentPadding:
                                  EdgeInsets.only(left: 20, right: 20),
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              double newBid =
                                  double.tryParse(_newBidController.text) ??
                                      0.0;
                              if (newBid > bid1) {
                                submitNewBid(newBid);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'New bid must be greater than the current bid.'),
                                  ),
                                );
                              }
                            },
                            child: Text('Submit'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors
                                  .indigoAccent), // Change button background color
                              foregroundColor: MaterialStateProperty.all(
                                  Colors.white), // Change text color
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(10.0)), // Adjust padding
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Adjust border radius
                                ),
                              ),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitNewBid(double newBid) async {
    final itemRef =
        FirebaseFirestore.instance.collection('Item').doc(widget.id);

    await itemRef.update({
      'bide': newBid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New bid submitted successfully.'),
      ),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => ViewItem(document: widget.document, id: widget.id),
    ));
  }

  Widget label(String label) {
    return Text(
      label,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: "Alkatra",
          fontSize: 38,
          letterSpacing: 1),
    );
  }

  Widget description(String description) {
    return Text(
      description,
      style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          letterSpacing: 1,
          fontFamily: "Alkatra"),
    );
  }

  Widget bid(double bid) {
    return Text(
      bid.toString(),
      style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          letterSpacing: 1,
          fontFamily: "Alkatra"),
    );
  }

  Widget endDate(DateTime endDate) {
    return Text(
      "End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}",
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        letterSpacing: 1,
        fontFamily: "Alkatra",
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
