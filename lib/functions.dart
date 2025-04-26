import 'package:flutter/material.dart';

Future<void> noInternet({required BuildContext context}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  'You do not have an internet connection, please connect to the internet to continue.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  softWrap: true,
                ),
              ),
              // const SizedBox(height: 20),
              // InkWell(
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   child: appNormalText(
              //       title: 'De acuerdo',
              //       fontSize: 15,
              //       textFontWeight: FontWeight.w700),
              // ),
            ],
          ),
        ),
      );
    },
  );
}

String cleanCommaPrice(String price) {
  return price.replaceAll(',', '');
}
