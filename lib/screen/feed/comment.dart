import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Comment {
  String userName;
  String userAvatarUrl;
  String text;
  DateTime timestamp;
  int likes;
  String points; // Points (e.g., "26 ball")
  List<Comment> replies;

  Comment({
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.timestamp,
    required this.points,
    this.likes = 0,
    this.replies = const [],
  });
}

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(Comment) onReply;
  final Function(Comment) onDelete;
  final Function(Comment) onLike;

  CommentWidget({
    required this.comment,
    required this.onReply,
    required this.onDelete,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(comment.userAvatarUrl),
                radius: 20,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text('- ${comment.points}'),
                    ],
                  ),
                  Text(comment.text),
                ],
              ),
              Spacer(),
              Text(
                "${comment.timestamp.hour}:${comment.timestamp.minute.toString().padLeft(2, '0')} "
                "${comment.timestamp.day} ${_monthToString(comment.timestamp.month)} ${comment.timestamp.year}",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.reply),
                onPressed: () => onReply(comment),
              ),
              Text('javob berish', style: TextStyle(color: Colors.blue)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: () => onLike(comment),
              ),
              Text(comment.likes.toString()),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(comment),
              ),
            ],
          ),
          // Display replies

          //raplayni qoy san like pageni taxla
          // keyen like bosganga api beraman va like productlani chiqaradigan api
          //tushunarlimi? ha boshla
          //nima qilopsan?
          // dizaynni taxlamoqchiman
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                children: comment.replies
                    .map((reply) => CommentWidget(
                          comment: reply,
                          onReply: onReply,
                          onDelete: onDelete,
                          onLike: onLike,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to convert month to string (for date display)
  String _monthToString(int month) {
    List<String> months = [
      "янв.",
      "февр.",
      "мар.",
      "апр.",
      "май",
      "июн.",
      "июл.",
      "авг.",
      "сен.",
      "окт.",
      "нояб.",
      "дек."
    ];
    return months[month - 1];
  }
}

//

class Mavzu extends StatefulWidget {
  int mavzu_id;

  Mavzu({super.key, required this.mavzu_id});

  @override
  State<Mavzu> createState() => _MavzuState();
}

class _MavzuState extends State<Mavzu> {
  List<Comment> comments = [];
  final TextEditingController commentController = TextEditingController();

  void _addComment(String text) {
    setState(() {
      comments.add(Comment(
        userName: "Mursaliman",
        userAvatarUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCaRg8BaRhDfuniljt47zyIWn03gFyE7T28w&s",
        text: text,
        timestamp: DateTime.now(),
        points: "461 ball",
      ));
    });
    commentController.clear();
  }

  void _replyToComment(Comment parentComment) {
    setState(() {
      parentComment.replies.add(Comment(
        userName: "Ajalbey",
        userAvatarUrl:
            "https://media.npr.org/assets/img/2017/09/12/macaca_nigra_self-portrait-fd5e770d3e129efe4b0ed6c19271ed29afc807dc.jpg?s=1100&c=85&f=jpeg",
        text: "This is a reply!",
        timestamp: DateTime.now(),
        points: "21 ball", // Example points
      ));
    });
  }

  void _deleteComment(Comment comment) {
    setState(() {
      comments.remove(comment);
    });
  }

  void _likeComment(Comment comment) {
    setState(() {
      comment.likes += 1;
    });
  }

  //hozi add commentni qilish kerakmi? ha

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
                      Icons.mail,
                      size: 25,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.menu_outlined,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 100, // Set the desired height here
                  padding: EdgeInsets.all(8.0), // Add padding if needed
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40, // Customize the size of the avatar
                        backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCaRg8BaRhDfuniljt47zyIWn03gFyE7T28w&s'),
                      ),
                      SizedBox(width: 16),
                      // Add space between the avatar and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Vertically center the content
                          children: [
                            Text(
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                // state.products[index].body.toString()
                                "Mursaliman "
                                "- 461 ball"),
                            SizedBox(height: 5),
                            Text(
                              "19:04 13 mar.2023",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // state.products[index].body.toString()
                        "Mursaliman",
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey[800],
                        ),
                        // state.products[index].body.toString()
                        "无 知 者 自 以 为 聪 明....\n聪 明 者 知 其 无 知....",
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        "Javoblar",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Colors.blue,
                            ),
                          ),
                          Text("999"),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                          Text("999"),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: comments
                        .map(
                          (comment) => CommentWidget(
                            comment: comment,
                            onReply: _replyToComment,
                            onDelete: _deleteComment,
                            onLike: _likeComment,
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Text input fixed at the bottom
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Yozish',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            _addComment(commentController.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
