import 'package:bind/model/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../model/user.dart';
import '../../../../resources/firebase_message_api.dart';

class SentNewMessageTextField extends StatefulWidget {

  User snap;
  User? currentUser;
   SentNewMessageTextField({required this.snap,
    Key? key, required this.currentUser,
  }) : super(key: key);

  @override
  State<SentNewMessageTextField> createState() => _SentNewMessageTextFieldState();
}

class _SentNewMessageTextFieldState extends State<SentNewMessageTextField> {
  
    String messages='';
    final _textController =TextEditingController();

    void sendMessage()async{
      FocusScope.of(context).unfocus();

      //upload message
     await FirebaseApi.uploadMessage(
currentUserId:widget.currentUser!.uid!,
recieverId: widget.snap.uid!,
 message: messages,
 recieverAvatarUrl: widget.snap.photoUrl!,
 recieverUsername: widget.snap.username!
       );

      //
      _textController.clear();
      messages='';

    }
    
   
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextFormField(
          controller: _textController,
         
          onChanged: (value) {
            setState(() {
              messages=value;
            });
          },
          autocorrect: true,
          enableSuggestions: true,
          textCapitalization: TextCapitalization.sentences,
          decoration:InputDecoration(
            labelText: 'Type your message....',
            filled: true,
            fillColor: Colors.grey[400],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(width: 15.w,
            color: Colors.black),
            
            gapPadding: 10.w),
            
          ) ,
        )),
        SizedBox(width: 5.w,),
        InkWell(
          onTap: ()async{
               messages.trim().isEmpty ? showSnackBarr('Type some message to sent!', context) :sendMessage();
          },
          child: CircleAvatar(
            backgroundColor:   messages.trim().isEmpty ?Colors.grey:
            Colors.black,
            radius: 24.r,
            child: const Icon(Icons.arrow_forward,color: Colors.white,),),
        ),
        SizedBox(width: 5.w,),
      ],
    );
  }
}