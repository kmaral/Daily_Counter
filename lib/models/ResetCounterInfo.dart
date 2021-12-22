import 'dart:convert';

class ResetCounterInfo {
  ResetCounterInfo({
    this.resetId,
    this.counterId,
    this.resetCounter,
    this.isCounterreseted,
    this.endtimeStamp,
  });

  int resetId;
  int counterId;
  int resetCounter;
  int isCounterreseted;
  String endtimeStamp;

  factory ResetCounterInfo.fromJson(String str) =>
      ResetCounterInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResetCounterInfo.fromMap(Map<String, dynamic> json) =>
      ResetCounterInfo(
        counterId: json["counterId"],
        resetId: json["resetId"],
        resetCounter: json["resetCounter"],
        isCounterreseted: json["isCounterreseted"],
        endtimeStamp: json["endtimeStamp"],
      );

  Map<String, dynamic> toMap() => {
        "counterId": counterId,
        "resetId": resetId,
        "resetCounter": resetCounter,
        "isCounterreseted": isCounterreseted,
        "endtimeStamp": endtimeStamp,
      };
}
