import 'dart:convert';

class CounterInfoHistory {
  CounterInfoHistory({
    this.historyid,
    this.counterId,
    this.counter,
    this.lasttimeStamp,
  });

  int historyid;
  int counterId;
  String counter;
  String lasttimeStamp;

  factory CounterInfoHistory.fromJson(String str) =>
      CounterInfoHistory.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CounterInfoHistory.fromMap(Map<String, dynamic> json) =>
      CounterInfoHistory(
        counterId: json["counterId"],
        historyid: json["historyid"],
        counter: json["counter"],
        lasttimeStamp: json["lasttimeStamp"],
      );

  Map<String, dynamic> toMap() => {
        "counterId": counterId,
        "historyid": historyid,
        "counter": counter,
        "lasttimeStamp": lasttimeStamp,
      };
}
