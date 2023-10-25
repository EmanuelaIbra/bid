import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newbid/screens/AddItem.dart';
import 'package:newbid/screens/ViewItem.dart';
import 'package:newbid/widget/ItemCard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("Item").snapshots();
  List<String> _dismissedItems = [];
  @override
  void deleteCard(String id) async {
    FirebaseFirestore.instance.collection('Item').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "Good Bid",
                style: TextStyle(fontSize: 22, fontFamily: "Alkatra"),
              ),
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 32,
                color: Colors.black,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => AddItem()));
                },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.indigoAccent, Colors.indigo],
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                size: 32,
                color: Colors.black,
              ),
              label: 'Settings')
        ],
      ),
      body: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              print("Hata: ${snapshot.error}");
              return Text("Error");
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text("No data");
            }

            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> document =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  print(document.toString());
                  return Dismissible(
                    key: Key(snapshot.data!.docs[index].id),
                    onDismissed: (direction) {
                      setState(() {
                        _dismissedItems.add(snapshot.data!.docs[index].id);
                      });
                      deleteCard(snapshot.data!.docs[index].id);
                    },
                    child: _dismissedItems
                            .contains(snapshot.data!.docs[index].id)
                        ? SizedBox()
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => ViewItem(
                                            document: document,
                                            id: snapshot.data!.docs[index].id,
                                          )));
                            },
                            child: ItemCard(
                              thumbnailUrl: document["thumbnailUrl"] == null
                                  ? 'https://www.zdnet.com/a/img/2022/10/06/801c71b9-f8d8-46b3-aa3f-c10ee6932c36/iphone-14-plus.jpg'
                                  : document["thumbnailUrl"],
                              title: document["name"] == null
                                  ? "Item name"
                                  : document["name"],
                              username: document["uplodedBy"] == null
                                  ? "unknow"
                                  : document["uplodedBy"],
                              bid: document["bide"] == null
                                  ? 10
                                  : document["bide"],
                              id: snapshot.data!.docs[index].id,
                            ),
                          ),
                  );
                });
          }),
    );
  }
}
