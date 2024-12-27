import 'package:ehson/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
class ProfileInfo extends StatefulWidget {
  final int profile_id;
  final String? avatar;
  final String name;
  const ProfileInfo({super.key,required this.profile_id,required this.avatar,required this.name});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {

  Future<void> create_chat(int user_one,int user_two)async{
    context.loaderOverlay.show();

    // CreateChatModel? createChatModel = await EhsonRepository().create_my_chat(user_one,user_two);
    // if(createChatModel!=null){
    //   String name = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoName.toString() : createChatModel.chat!.userOneName.toString();
    //   String avatar = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoAvatar.toString() : createChatModel.chat!.userOneAvatar.toString();
    //   int? another_id = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoId : createChatModel.chat!.userOneId;
    //   Navigator.push(context,
    //       MaterialPageRoute(
    //           builder: (context) {
    //             return BlocProvider(
    //               create: (ctx) => MessageListBloc(),
    //               child:  OneChatPage(chat_id: createChatModel.chat!.chatId,name: name.toString(),avatar: avatar,my_id: user_id,another_id: another_id ?? 0,),
    //             );
    //           }));
    // } else {
    //   Fluttertoast.showToast(
    //       msg: "Serverda xatolik qayta urunib ko'ring!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //
    // }
    context.loaderOverlay.show();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: SafeArea(
          child:Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(100)),
                      width: 100,
                      height: 100,
                      child: InkWell(
                        onTap: () {

                        },
                        child:widget.avatar == null ? Icon(Icons.person,size: 30,) : Image.network(
                          AppConstans.BASE_URL2 + "images/" + widget.avatar!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),
              Text(
                widget.name,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Text(
                "Phone:-",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
      ),
    );
  }
}
