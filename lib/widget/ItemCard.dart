import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String thumbnailUrl;
  final double bid;
  final String username;

  ItemCard({
    required this.title,
    required this.thumbnailUrl,
    required this.bid,
    required this.username,
    required String id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 200, // Yüksekliği azalttık
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: Offset(0.0, 10.0),
            blurRadius: 10.0,
            spreadRadius: -5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                image: NetworkImage(thumbnailUrl),
                width: 180, // Resim boyutunu ayarladık
                height: 200, // Resim boyutunu ayarladık
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20, // Metin boyutunu azalttık
                      fontFamily: "Alkatra",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      Text(
                        "By @",
                        style: TextStyle(
                          fontSize: 12, // Metin boyutunu azalttık
                          fontFamily: "Alkatra",
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 12, // Metin boyutunu azalttık
                          fontFamily: "Alkatra",
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Text(
                        "Bid(\$): ",
                        style: TextStyle(
                            fontSize: 16, // Metin boyutunu azalttık
                            fontFamily: "Alkatra",
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        bid.toString(),
                        style: TextStyle(
                          fontSize: 16, // Metin boyutunu azalttık
                          fontFamily: "Alkatra",
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                  /*  TextButton(
                    onPressed: () {
                      // Butona tıklama işlemi buraya eklenir.
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Colors.indigoAccent, // Butonun arka plan rengi
                      primary: Colors.white, // Buton metin rengi
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 5), // Buton iç içe padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Butonun köşe yuvarlama derecesi
                      ),
                    ),
                    child: Text(
                      "Your Bid",
                      style: TextStyle(
                        fontSize: 16, // Metin boyutu
                        fontFamily: "Alkatra", // Metin fontu
                      ),
                    ),
                  )*/
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
