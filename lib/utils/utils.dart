import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:typhon/widgets/loading_page.dart';

class StringWithAssociatedID {
  int id;
  String text;

  StringWithAssociatedID({this.id = -1, this.text = ""});
}

class Utils {
  static final encrypt.Key _encryptDecryptKey =
      encrypt.Key.fromBase64("aWhTZlWhBiduT0vPuT8pvQ==");
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_encryptDecryptKey));
  static final _iv = encrypt.IV.fromUtf8("aWhTZlWhBiduT0vP");

  static String encryptString(String toEncrypt) {
    final encrypted = _encrypter.encrypt(toEncrypt, iv: _iv);
    return encrypted.base64;
  }

  static String decryptString(String toDecrypt) {
    final decrypted = _encrypter.decrypt64(toDecrypt, iv: _iv);
    return decrypted;
  }

  static void copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  static bool isNumberCloseToInt(double number, double variation) {
    return number > number.roundToDouble() - variation &&
        number < number.roundToDouble() + variation;
  }

  static bool isNumberCloseTo(double number, double closeTo, double variation) {
    return number > closeTo - variation && number < closeTo + variation;
  }

  static bool validateEmail(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\s*$");
    return regex.hasMatch(email);
  }

  static String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return '';
    }).join(' ');
  }

  static DateTime startOfWeek(DateTime date) {
    // Calculate the difference from Monday
    int daysFromMonday = date.weekday - DateTime.monday;
    // Subtract the difference to get to the start of the week
    return DateTime(date.year, date.month, date.day - daysFromMonday)
        .add(const Duration(minutes: 1));
  }

  static DateTime endOfWeek(DateTime date) {
    // Calculate the difference to Sunday
    int daysToSunday = DateTime.sunday - date.weekday;
    // Add the difference to get to the end of the week
    return DateTime(
        date.year, date.month, date.day + daysToSunday, 23, 59, 59, 999);
    // This sets the time to the last millisecond of the day, representing the end of the week.
  }

  static String colorToCSS(Color color) {
    return "#${color.toString().substring("Color(0xff".length, color.toString().length - 1)}";
  }

  static bool hasNewWeekStarted(DateTime date1, DateTime date2) {
    DateTime startOfWeekDate1 = startOfWeek(date1);
    DateTime startOfWeekDate2 = startOfWeek(date2);

    return !startOfWeekDate1.isAtSameMomentAs(startOfWeekDate2);
  }

  static String hashString(String text) {
    var bytes1 = utf8.encode(text); // data being hashed
    var digest1 = sha256.convert(bytes1);

    return digest1.toString();
  }


  static String formatDate(DateTime date, {bool usDate = false}) {
    if (usDate) {
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}";
  }

  static String formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  static void showLoadingPage({required BuildContext context,required Future<Either<String,String>> Function() futureFunction}) {
    Navigator.of(context).push(MaterialPageRoute(builder:(context) => LoadingPage(futureFunction: futureFunction,)));
  }

}
