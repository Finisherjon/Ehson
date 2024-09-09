import 'package:ehson/screen/chat/lichka.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.filter_alt_rounded,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ],
          centerTitle: true,
          title: Text("Chat"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(50),
                    //   topRight: Radius.circular(50),
                    // ),
                    // color: Colors.grey,
                    ),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 20,
                  shrinkWrap: true,
                  itemBuilder: (contex, index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen()),
                            );
                          },
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                'https://c8.alamy.com/comp/RAJNWN/publicity-photo-of-chris-rock-circa-1999-file-reference-33636-945tha-RAJNWN.jpg'),
                          ),
                          title: Text("Ajalbek Toshpo'latov"),
                          subtitle: Text('Qalay bobikmi', maxLines: 1),
                          trailing: Text('12:00'),
                        ),
                        Container(
                          child: Divider(
                            color: Colors.grey,
                          ),
                          width: 400,
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
