import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ehson/api/models/create_chat_model.dart';
import 'package:ehson/bloc/get_filter_product/get_filter_product_bloc.dart';
import 'package:ehson/bloc/get_one_product/get_one_product_bloc.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/screen/chat/one_chat.dart';
import 'package:ehson/screen/product_info/product_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../adjust_size.dart';
import '../../api/models/category_model.dart';
import '../../api/repository.dart';
import '../../bloc/filter_product/filter_product_bloc.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  final List<String> items = [];
  final List<String> cities = [];
  String? selectedValue_category;
  String? selectedValue_city;
  int category_id = 0;
  int city_id = 0;

  // Future<String> filter_product(int category_id, int city_id) async {
  //   var uri = Uri.parse(AppConstans.BASE_URL + '/filterproduct');
  //   var token = '';
  //   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //   final SharedPreferences prefs = await _prefs;
  //   token = prefs.getString('bearer_token') ?? '';
  //   Map data = {"category_id": 1, "city_id": 1};
  //   var body = json.encode(data);
  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": 'Bearer $token',
  //       },
  //       body: body,
  //     );
  //     if (response.statusCode == 200) {
  //       final resdata = json.decode(utf8.decode(response.bodyBytes));
  //       print(resdata);
  //       if (resdata["status"] == true) {
  //         return "Success";
  //       } else {
  //         return "Error: ${response.statusCode}";
  //       }
  //     } else {
  //       return "Error: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     return "Exception: $e";
  //   }
  // }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  CategoryModel? categoryModel_global;
  Future<bool> get_cat() async{
    CategoryModel? categoryModel = await EhsonRepository().get_category();
    if(categoryModel!=null){

        setState(() {
          categoryModel_global = categoryModel;
          items.clear();
          cities.clear();
          for (var category in categoryModel.categories!) {
            items.add(category.name.toString());
          }
          for (var city in categoryModel.cities!) {
            cities.add(city.name.toString());
          }
          selectedValue_category = items.first;
          selectedValue_city = cities.first;
          category_id = categoryModel.categories!.first.id!;
          city_id = categoryModel.cities!.first.id!;
        });
    }
    return true;
  }

  Future<bool> add_like_product(int? product_id) async {
    String add_like = await EhsonRepository().add_like(product_id);
    if (add_like.contains("Success")) {
      return true;
    } else {
      Fluttertoast.showToast(
          msg: "Serverda xatolik qayta urunib ko'ring!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  bool _heartIcon = false;
  final _scrollController = ScrollController();
  Timer? _debounce;


  int user_id = 0;
  bool admin = false;


  Future<void> getSharedPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
      admin = prefs.getBool("admin") ?? false;
    });
  }

  Future<void> create_chat(int user_one,int user_two)async{
    if(user_one == user_id && user_two == user_id){
      Fluttertoast.showToast(
          msg: "O'zingiz bilan chat qura olmaysiz!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      context.loaderOverlay.show();
      try{
        CreateChatModel? createChatModel = await EhsonRepository().create_my_chat(user_one,user_two);
        if(createChatModel!=null){
          String name = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoName.toString() : createChatModel.chat!.userOneName.toString();
          String avatar = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoAvatar.toString() : createChatModel.chat!.userOneAvatar.toString();
          int? another_id = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoId : createChatModel.chat!.userOneId;
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      create: (ctx) => MessageListBloc(),
                      child:  OneChatPage(chat_id: createChatModel.chat!.chatId,name: name.toString(),avatar: avatar,my_id: user_id,another_id: another_id ?? 0,),
                    );
                  }));
        } else {
          Fluttertoast.showToast(
              msg: "Serverda xatolik qayta urunib ko'ring!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

        }
        context.loaderOverlay.hide();
      }
      catch (e) {
        context.loaderOverlay.hide();
        Fluttertoast.showToast(
            msg: "Serverda xatolik qayta urunib ko'ring!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    get_cat();
    BlocProvider.of<GetFilterProductBloc>(context)
        .add(FilterProductGetEvent(category_id: 1, city_id: 1));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onrefresh() async {
    BlocProvider.of<GetFilterProductBloc>(context).add(ReloadGetFilterProductEvent(category_id: category_id,city_id: city_id));
    _refreshController.refreshCompleted();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // print(_scrollController.position.pixels);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<GetFilterProductBloc>(context)
            .add(FilterProductGetEvent(category_id: 1, city_id: 1));
      }
    });
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.blueAccent,
          ),
        ),
        title: Text('Filter Page'),
        centerTitle: true,
      ),
      body: LoaderOverlay(
        child: categoryModel_global == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                value: items.first,
                                isExpanded: true,
                                hint: Text(
                                  'Kategoriya',
                                  style: TextStyle(fontSize: 14),
                                ),
                                items: items
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select gender.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue_category = value.toString();
                                    Categories cat = categoryModel_global!.categories!
                                        .firstWhere((category) =>
                                    category.name == selectedValue_category);
                                    category_id = cat.id!;
                                    print(category_id);
                                  });
                                  BlocProvider.of<GetFilterProductBloc>(context).add(ReloadGetFilterProductEvent(category_id: category_id,city_id: city_id));
                                },
                                onSaved: (value) {
                                  selectedValue_category = value.toString();
                                  Categories cat = categoryModel_global!.categories!
                                      .firstWhere((category) =>
                                  category.name == selectedValue_category);
                                  category_id = cat.id!;
                                },
                                buttonStyleData: const ButtonStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: DropdownButtonFormField2(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        value: cities.first,
                        isExpanded: true,
                        hint: Text(
                          'Kategoriya',
                          style: TextStyle(fontSize: 14),
                        ),
                        items: cities
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select gender.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedValue_city = value.toString();
                            Cities cat = categoryModel_global!.cities!
                                .firstWhere((category) =>
                            category.name == selectedValue_city);
                            city_id = cat.id!;
                            print(city_id);
                          });
                          BlocProvider.of<GetFilterProductBloc>(context).add(ReloadGetFilterProductEvent(category_id: category_id,city_id: city_id));

                        },
                        onSaved: (value) {
                          selectedValue_city = value.toString();
                          Cities cat = categoryModel_global!.cities!
                              .firstWhere((category) =>
                          category.name == selectedValue_city);
                          city_id = cat.id!;
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 50,
                          padding: EdgeInsets.only(left: 20, right: 10),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<GetFilterProductBloc, GetFilterProductState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case FilterProduct.loading:
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.86,
                            child: Center(
                              child: Text(
                                "Nimadir qidirib ko'ring\n biz albatta topamiz",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        case FilterProduct.success:
                          if (state.products.isEmpty) {
                            return Container(
                              child: MyWidget().mywidget("Hech narsa topilmadi!"),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.86,
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.86,
                            child: SmartRefresher(
                              child: MasonryGridView.count(
                                  controller: _scrollController,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  crossAxisSpacing: 15,
                                  crossAxisCount: 2,
                                  itemCount: state.islast
                                      ? state.products.length
                                      : state.products.length + 2,
                                  scrollDirection: Axis.vertical,
                                  mainAxisSpacing: 10,
                                  itemBuilder: (BuildContext context, index) {
                                    if (index >= state.products.length) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    String? asosiy_img;
                                    if (state.products.length > index) {
                                      if (state.products[index].img1 != null) {
                                        asosiy_img = state.products[index].img1;
                                      } else if (state.products[index].img2 != null) {
                                        asosiy_img = state.products[index].img2;
                                      } else if (state.products[index].img3 != null) {
                                        asosiy_img = state.products[index].img3;
                                      } else {
                                        asosiy_img = null;
                                      }
                                    }
                                    return index >= state.products.length
                                        ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                        : Container(
                                      child: Stack(
                                        children: [
                                          InkWell(
                                            child: Container(
                                              padding:
                                              EdgeInsets.only(bottom: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(25),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        25),
                                                    child: Stack(
                                                      children: [
                                                        asosiy_img ==
                                                            null &&
                                                            state.products
                                                                .length >
                                                                index
                                                            ? MyWidget().defimagewidget(context)
                                                            :CachedNetworkImage(
                                                            imageUrl:AppConstans.BASE_URL2 + "images/" + asosiy_img!,
                                                            placeholder: (context, url) => Container(
                                                                width: MediaQuery.of(context).size.width*0.5,
                                                                height:MediaQuery.of(context).size.height*0.2,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    CircularProgressIndicator(),
                                                                  ],
                                                                )
                                                            ),
                                                            errorWidget: (context, url, error) =>
                                                                MyWidget().defimagewidget(context)
                                                        ),
                                                        Positioned(
                                                          right: 10,
                                                          top: 10,
                                                          child: Container(
                                                            height: Sizes.heights(
                                                                context) *
                                                                0.04,
                                                            width: Sizes.widths(
                                                                context) *
                                                                0.07,
                                                            decoration:
                                                            BoxDecoration(
                                                              color:
                                                              Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: IconButton(
                                                              style: IconButton
                                                                  .styleFrom(
                                                                minimumSize:
                                                                Size.zero,
                                                                padding:
                                                                EdgeInsets
                                                                    .zero,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                int?
                                                                product_id =
                                                                    state
                                                                        .products[
                                                                    index]
                                                                        .id;
                                                                bool add_like =
                                                                await add_like_product(
                                                                    product_id);

                                                                if (add_like) {
                                                                  state
                                                                      .products[
                                                                  index]
                                                                      .isliked = state
                                                                      .products[index]
                                                                      .isliked ==
                                                                      0
                                                                      ? 1
                                                                      : 0;
                                                                }
                                                                setState(() {
                                                                  _heartIcon =
                                                                  !_heartIcon;
                                                                });
                                                              },
                                                              icon: Icon(
                                                                state.products[index].isliked ==
                                                                    1
                                                                    ? Icons
                                                                    .favorite
                                                                    : Icons
                                                                    .favorite_border,
                                                                color:
                                                                Colors.red,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 10,
                                                          bottom: 10,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: Sizes
                                                                    .heights(
                                                                    context) *
                                                                    0.037,
                                                                width: Sizes.widths(
                                                                    context) *
                                                                    0.077,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child:
                                                                IconButton(
                                                                  style: IconButton
                                                                      .styleFrom(
                                                                    minimumSize:
                                                                    Size.zero,
                                                                    padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                  ),
                                                                  onPressed:
                                                                      () async{
                                                                        Dialogs.materialDialog(
                                                                            color: Colors.white,
                                                                            msg: "Chatni boshlashni xoxlaysizmi?",
                                                                            titleStyle: TextStyle(fontSize: 18),
                                                                            titleAlign: TextAlign.center,
                                                                            title: "Mehr",
                                                                            customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                                                            context: context,
                                                                            actions: [
                                                                              TextButton(onPressed: (){
                                                                                Navigator.pop(context);
                                                                              }, child: Text("Orqaga qaytish")),
                                                                              IconsButton(
                                                                                onPressed: () async{
                                                                                  Navigator.pop(context);
                                                                                  await create_chat(user_id,state.products[index].userId ?? 0);
                                                                                },
                                                                                text: 'Chatni boshlash',
                                                                                // iconData: Icons.done,
                                                                                color: Colors.blue,
                                                                                textStyle: TextStyle(color: Colors.white),
                                                                                iconColor: Colors.white,
                                                                              ),
                                                                            ]);
                                                                      },
                                                                  icon: Icon(
                                                                    Icons.chat,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: IconSize
                                                                        .smallIconSize(
                                                                        context),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              Container(
                                                                height: Sizes
                                                                    .heights(
                                                                    context) *
                                                                    0.04,
                                                                width: Sizes.widths(
                                                                    context) *
                                                                    0.08,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child:
                                                                IconButton(
                                                                  style: IconButton
                                                                      .styleFrom(
                                                                    minimumSize:
                                                                    Size.zero,
                                                                    padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                  ),
                                                                  onPressed:
                                                                      () async{
                                                                        if(state
                                                                            .products[index]
                                                                            .phone != null){
                                                                          Dialogs.materialDialog(
                                                                              color: Colors.white,
                                                                              msg: "Telefon raqam orqali bog'lanishni xoxlaysizmi?",
                                                                              titleStyle: TextStyle(fontSize: 20),
                                                                              titleAlign: TextAlign.center,
                                                                              title: "Mehr",
                                                                              customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                                                              context: context,
                                                                              actions: [
                                                                                TextButton(onPressed: (){
                                                                                  Navigator.pop(context);
                                                                                }, child: Text("Orqaga qaytish")),
                                                                                IconsButton(
                                                                                  onPressed: () async{
                                                                                    makePhoneCall(state
                                                                                        .products[index]
                                                                                        .phone!);
                                                                                  },
                                                                                  text: 'Telefon qilish',
                                                                                  // iconData: Icons.done,
                                                                                  color: Colors.blue,
                                                                                  textStyle: TextStyle(color: Colors.white),
                                                                                  iconColor: Colors.white,
                                                                                ),
                                                                              ]);
                                                                        }
                                                                        else{
                                                                          Fluttertoast.showToast(
                                                                              msg: "Bu foydalanuvchi telefon raqamini hali kiritmagan!",
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 1,
                                                                              backgroundColor: Colors.red,
                                                                              textColor: Colors.white,
                                                                              fontSize: 16.0);
                                                                        }
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.phone,
                                                                    color: Colors
                                                                        .green,
                                                                    size: IconSize
                                                                        .smallIconSize(
                                                                        context),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8,
                                                        right: 8,
                                                        top: 8),
                                                    child: Text(
                                                      state.products[index]
                                                          .title!,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8,
                                                        right: 8,
                                                        top: 8),
                                                    child: Row(
                                                      children: [
                                                        Text(' \$ free')
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                        return BlocProvider(
                                                          create: (ctx) =>
                                                              GetOneProductBloc(),
                                                          child: ProductInfo(
                                                              product_id: state
                                                                  .products[
                                                              index]!
                                                                  .id!),
                                                        );
                                                      }));
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              controller: _refreshController,
                              onRefresh: _onrefresh,
                            ),
                          );
                        case FilterProduct.error:
                          return Center(
                            child: Text("Internet error"),
                          );
                      }
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
