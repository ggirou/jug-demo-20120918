class CounterData {
  String id;
  var value;
  
  CounterData(this.id, this.value);
  
  CounterData.parse(String json) {
    var obj = JSON.parse(json);
    id = obj["id"];
    value = obj["value"];
  }
  
  toString() => JSON.stringify({"id": id, "value": value});
}
