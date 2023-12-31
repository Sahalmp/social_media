import 'package:bind/model/user.dart' as model;

import 'package:bind/resources/firestore_methods.dart';

import 'package:bind/view/screens/commentScreen/commentsScreen.dart';
import 'package:bind/view/screens/feedScreen/widgets/likesViewScreen.dart';
import 'package:bind/view/screens/profile/profile.dart';
import 'package:bind/view/screens/screenwidgets/like_animation.dart';
import 'package:bind/view/widgets/ImageAlertView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../controller/user_provider.dart';

class UserPosts extends StatefulWidget {
  final snap;
  bool isProfile = false;
  UserPosts({Key? key, required this.snap}) : super(key: key);

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  int commentLenght = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
    widget.snap['uid'] == FirebaseAuth.instance.currentUser!.uid
        ? widget.isProfile = true
        : widget.isProfile = false;
  }

  void getComments() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .get();

    try {
      final commentLengh = snap.docs.length;
      setState(() {
        commentLenght = commentLengh;
      });
    } catch (e) {
      print(e.toString());
      // showSnackBarr(e.toString(), context);
    }
  }

  bool isLikeAnimation = false;
  @override
  Widget build(BuildContext context) {
    getComments();
    final model.User? user = Provider.of<UserProvider>(context).getUser;

    return Card(
      child: Column(
        children: [
          Padding(
            padding:  EdgeInsets.all(10.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (() => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Profile(uid: widget.snap['uid'])))),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    widget.snap['profImage']),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        widget.snap['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                widget.isProfile
                    ? IconButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                actionsPadding: EdgeInsets.symmetric(horizontal: 10.w),
                                    title: Text('Delete Post'),
                                    content:
                                        Text('Are you sure want to delete ?'),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                          final result=await FireStoreMethods().deletePost(
                                                    widget.snap['postId'], context);
                                                    if(result=='success'){
                                                      Get.back();
                                                    }
                                                
                                              },
                                              child: Row(
                                                children: [Text('Yes'),
                                                  const Icon(Icons.delete),
                                                ],
                                              )),
                                                ElevatedButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: const Text('No'))
                                        ],
                                      ),
                                        
                                    ],
                                  ));
                        },
                        icon: const Icon(Icons.more_vert))
                    : SizedBox()
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              FireStoreMethods().likePost(
                  widget.snap['postId'], user!.uid!, widget.snap['likes']);
              setState(() {
                isLikeAnimation = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(context: context, builder: (builder){
                                    return ImageAlertView(isProfile: false,imageUrl: widget.snap
                                          ['postUrl'],);
                                  });
                  },
                  child: CachedNetworkImage(
                    height: 400.h,
                    imageUrl: widget.snap['postUrl'],
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'lib/model/assets/placeholder_for_homepost.jpg'),
                              fit: BoxFit.cover)),
                    ),
                    errorWidget: (context, url, error) =>   Icon(
                      Icons.error,
                      size: 30.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimation ? 1 : 0,
                  child: LikeAnimation(
                    child:  
                     Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120.sp,
                    ),
                    isAnimating: isLikeAnimation,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimation = false;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(user?.uid),
                    smallLike: true,
                    child: IconButton(
                      icon: widget.snap['likes'].contains(user?.uid)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          :const  Icon(
                              Icons.favorite_border_outlined,
                              color: Colors.black,
                            ),
                      onPressed: () async {
                        FireStoreMethods().likePost(widget.snap['postId'],
                            user!.uid!, widget.snap['likes']);
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding:  EdgeInsets.only(right: 5.0.w),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              CommentsScreen(snap: widget.snap)));
                    },
                    icon: const Icon(Icons.chat_bubble_outline)),
              ),
            ],
          ),
          Padding(
            padding:  EdgeInsets.only(left: 8.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(onTap: (){
                  showModalBottomSheet(context: context, builder: (builder){
                    return LikesViewScreen(postId: widget.snap['postId'],);

                  });
                },
                  child: _likesViewCount()),
                _commentsViewSection(context),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _usernameAndBioView(),
              _publishedDate()
            ],
          ),
        ],
      ),
    );
  }

  Padding _publishedDate() {
    return Padding(
              padding:  EdgeInsets.all(8.0.r),
              child: InkWell(
                onTap: () {},
                child: Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate()),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
            );
  }

  Padding _usernameAndBioView() {
    return Padding(
              padding:  EdgeInsets.only(left: 8.0.w),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: '${widget.snap['username']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '  ${widget.snap['description']}')
                      ])),
            );
  }

  Padding _commentsViewSection(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(8.0.r),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommentsScreen(snap: widget.snap)));
        },
        child: commentLenght == 0
            ? Text(
                '${commentLenght} comments',
                style: TextStyle(color: Colors.grey[800]),
              )
            : Text(
                'View all ${commentLenght} comments',
                style: TextStyle(color: Colors.grey[800]),
              ),
      ),
    );
  }

  Row _likesViewCount() {
    return Row(
      children: [
        Text('Liked by '),
        Text(
          '${widget.snap['likes'].length}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          ' people ',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
