import 'dart:convert';

class CounterInfo {
  CounterInfo({
    this.counterId,
    this.counterName,
    this.counter,
    this.createdtimeStamp,
    this.lasttimeStamp,
    this.isDeleted,
    this.archiveOn,
  });

  int counterId;
  String counterName;
  int counter;
  String createdtimeStamp;
  String lasttimeStamp;
  int isDeleted;
  String archiveOn;

  factory CounterInfo.fromJson(String str) =>
      CounterInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CounterInfo.fromMap(Map<String, dynamic> json) => CounterInfo(
      counterId: json["counterId"],
      counterName: json["counterName"],
      counter: json["counter"],
      createdtimeStamp: json["createdtimeStamp"],
      lasttimeStamp: json["lasttimeStamp"],
      isDeleted: json["isDeleted"],
      archiveOn: json["archiveOn"]);

  Map<String, dynamic> toMap() => {
        "counterId": counterId,
        "counterName": counterName,
        "counter": counter,
        "createdtimeStamp": createdtimeStamp,
        "lasttimeStamp": lasttimeStamp,
        "isDeleted": isDeleted,
        "archiveOn": archiveOn
      };
}
