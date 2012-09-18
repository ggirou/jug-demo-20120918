#import('dart:html');
#import('dart:isolate');
#import('../shared/dartry.dart');

WebSocket webSocket;

var buttonIds = const ["counterButton", "ggirouGplus", "ggirouTwitter", "nfrancoisGplus", "nfrancoisTwitter"];

void main() {
  //var date = new DateFormat("d MMMM yyyy", "fr_Fr").format(new Date.now());
  String hello = "Hello Jug!";
  query("#jugTitle").innerHTML = hello;
  print(hello);

  int port = 12345;
  String url = "ws://127.0.0.1:$port";
  
  init(url);
  
  // Register buttons
  buttonIds.forEach((id) => new CounterElement(id));
}

init(String url) {
  webSocket = new WebSocket(url);
  
  webSocket.on.open.add((e) => print("Connected"));
  webSocket.on.close.add((e) => print("Disconnected"));
  webSocket.on.message.add((MessageEvent e) {
    print('Message received: ${e.data}');
    CounterData count = new CounterData.parse(e.data);
    var counter = new CounterElement(count.id);
    counter.active = true;
    counter.value = count.value.toString();
  });
}

send(CounterData message){
  print("Send message: $message");
  webSocket.send(message.toString());
}

class CounterElement {
  static Map<String, CounterElement> _instances;
  static List<String> _activeStyles = const ["btn-inverse", "btn-info"];

  Element button;
  
  factory CounterElement(String id) {
    if(_instances == null) {
      _instances = new Map();
    }
    
    _instances.putIfAbsent(id, () => new CounterElement._internal(query("#$id")));
    return _instances[id];
  }

  CounterElement._internal(this.button) {
    button.on.click.add((e) => toggle());
  }
  
  toggle() {
    active = !active;
    send(new CounterData(id, active));
  }

  get id => button.id;
  
  get counter => button.query("#counter"); 
  set value(String value) => counter.innerHTML = value;
  
  get active => button.classes.contains(_activeStyles[1]);
  set active(bool _active) {
    button.classes
      ..removeAll(_activeStyles)
      ..add(_activeStyles[_active ? 1 : 0]);
  }
}
