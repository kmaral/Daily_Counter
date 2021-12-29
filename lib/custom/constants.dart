import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Contstants {
  static getTheme(String _theme) {
    (_theme == 'light')
        ? ThemeData.light().copyWith(primaryColor: Colors.blueAccent[200])
        : ThemeData.dark().copyWith(primaryColor: Colors.blueGrey);
  }

  static textGetDays(String lastUpdatetimeStamp, String createdTimeStamp) {
    var createdDate = DateTime.tryParse(createdTimeStamp);
    var lastUpdatedDate = DateTime.tryParse(lastUpdatetimeStamp);
    Duration duration = daysElapsedSince(createdDate, lastUpdatedDate);

    int days = 0;
    days = duration.inDays + 1;
    // if (createdDate != null && lastUpdatedDate != null) {
    //   // int years = lastUpdatedDate.year - createdDate.year;
    //   // int months = lastUpdatedDate.month - createdDate.month;
    //   days = lastUpdatedDate.day - createdDate.day;

    //   // if (months < 0 || (months == 0 && days < 0)) {
    //   //   years--;
    //   //   months += (days < 0 ? 11 : 12);
    //   // }

    //   // if (days < 0) {
    //   //   final monthAgo =
    //   //       new DateTime(now.year, now.month - 1, selectedDate.day);
    //   //   days = lastUpdatedDate.difference(monthAgo).inDays + 1;
    //   // }
    // }
    return days;
  }

  static Text displayTimer(Duration duration, String timestamp, bool _isDark) {
    var selectedDate = DateTime.tryParse(timestamp);
    if (selectedDate != null) {
      final now = new DateTime.now();
      int years = now.year - selectedDate.year;
      int months = now.month - selectedDate.month;
      int days = now.day - selectedDate.day;

      if (months < 0 || (months == 0 && days < 0)) {
        years--;
        months += (days < 0 ? 11 : 12);
      }

      if (days < 0) {
        final monthAgo =
            new DateTime(now.year, now.month - 1, selectedDate.day);
        days = now.difference(monthAgo).inDays + 1;
      }

      // final daysOver = duration.inDays.toString();
      // print('Days Over ' + daysOver);

      // // twoDigits((duration.inDays - (duration.inDays ~/ 365) * 365) - 30)
      // //     .toString();
      // final years = (duration.inDays ~/ 365).toString();
      // final months =
      //     ((duration.inDays - (duration.inDays ~/ 365) * 365) ~/ 30).toString();
      // // if (int.parse(months) > 0) {
      // //   days = twoDigits((duration.inDays - (duration.inDays ~/ 365) * 365) -
      // //           duration.inDays ~/ 365)
      // //       .toString();
      // // }
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours.remainder(24));
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return months > 0 && years > 0
          ? Text(
              '$years y $months m $days d $hours h $minutes m $seconds s',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : Colors.black,
              ),
            )
          : months > 0
              ? Text(
                  '$months m $days d $hours h $minutes m $seconds s',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : Colors.black,
                  ),
                )
              : days > 0
                  ? Text('$days d $hours h $minutes m $seconds s',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : Colors.black,
                      ))
                  : int.parse(hours) > 0
                      ? Text('$hours h $minutes m $seconds s',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.white : Colors.black,
                          ))
                      : int.parse(minutes) > 0
                          ? Text('$minutes m $seconds s',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: _isDark ? Colors.white : Colors.black,
                              ))
                          : Text('$seconds s',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: _isDark ? Colors.white : Colors.black,
                              ));
    }

    return Text('');
  }

  static Duration getDuration(Duration duration, String timestamp) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime date1 = formatter.parse(timestamp);
    DateTime date2 = DateTime.now();
    // LocalDateTime a = LocalDateTime.now();
    // LocalDateTime b = LocalDateTime.dateTime(date1);
    // Period diff = a.periodSince(b);
    // print(
    //     "years: ${diff.years}; months: ${diff.months}; days: ${diff.days}; hours: ${diff.hours}; minutes: ${diff.minutes}; seconds: ${diff.seconds}");

    return daysElapsedSince(date1, date2);
  }

  static Duration daysElapsedSince(DateTime from, DateTime to) {
// get the difference in term of days, and not just a 24h difference
    var start = DateTime(
        from.year, from.month, from.day, from.hour, from.minute, from.second);
    var end =
        DateTime(to.year, to.month, to.day, to.hour, to.minute, to.second);
    return end.difference(start);
  }
}
