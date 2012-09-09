#library('jug-demo');

#import('dart:io');
#import('dart:isolate');
#import('package:who_listen_me/who_listen_me.dart');
#import('../shared/dartry.dart');

typedef Future<int> callFollowers();

class TickHandler {
  num _count = 0;
  Set<WebSocketConnection> connections;
  Timer timer;
  CirclesApi circles = new CirclesApi();
  
  Map<String, callFollowers> cerclers = {
    "counterButton" : () {
      var completer = new Completer<int>();
      var request = new CirclesApi().whoCircleMe('115816334172157652403');
      request..onError = ((error) => print(error))
          ..onResponse = ((response) => completer.complete(response.totalCirclers));
      return completer.future;
    },
    "ggirouGplus" : () {
      var completer = new Completer<int>();
      var request = new CirclesApi().whoCircleMe('115049522200141162219');
      request..onError = ((error) => print(error))
          ..onResponse = ((response) => completer.complete(response.totalCirclers));
      return completer.future;
    },
    "nfrancoisGplus" : () {
      var completer = new Completer<int>();
      var request = new CirclesApi().whoCircleMe('106226789128312528511');
      request..onError = ((error) => print(error))
          ..onResponse = ((response) => completer.complete(response.totalCirclers));
      return completer.future;
    }                                  
  };
  
  Map<String, callFollowers> followers = {
    "ggirouTwitter" : () {
      var completer = new Completer<int>();
      var request = new FollowersApi().getFollowerNumberByNickname("girouguillaume");
      request..onError = ((error) => print(error))
          ..onResponse = ((FollowersNumberResponse response) => completer.complete(response.totalFollowers));
      return completer.future;
    },
    "nfrancoisTwitter" : () {
      var completer = new Completer<int>();
      var request = new FollowersApi().getFollowerNumberByNickname("nicofrancois");
      request..onError = ((error) => print(error))
          ..onResponse = ((FollowersNumberResponse response) => completer.complete(response.totalFollowers));
      return completer.future;
    },
  };

  TickHandler() : connections = new Set<WebSocketConnection>() {
    start();
  }
  
  bool get isRunning => timer != null;

  start() {
    timer = new Timer.repeating(1000, tick);
  }
  
  stop() {
    timer.cancel();
    timer = null;
  }
  
  toggle() {
    isRunning ? stop() : start();
  }
  
  tick(var _timer) {
    cerclers.forEach((key, callFollowers) => callFollowers().then((number) => send(new CounterData(key, number))));
    if(_count%10 == 0){
      followers.forEach((key, callFollowers) => callFollowers().then((number) => send(new CounterData(key, number))));
    }
    _count++;
  }
  
  send(CounterData message) {
    if(isRunning) {
      print("Send message: $message");
      connections.forEach((WebSocketConnection connection) => connection.send(message.toString()));
    }
  }
  
  // closures!
  onOpen(WebSocketConnection conn) {
    print('New WebSocket connection');
    connections.add(conn);
    
    conn.onClosed = (int status, String reason) {
      print('Connection is closed');
      connections.remove(conn);
    };
    
    conn.onMessage = (message) {
      print('Message received: $message');
      toggle();
    };
    
    conn.onError = (e) {
      print("Connection error");
      connections.remove(conn); // onClosed isn't being called ??
    };
  }
}

main() {
  // 14 Septembre 2012 ! :p
  var port = 12345;

  HttpServer server = new HttpServer();
  
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new TickHandler().onOpen;
  server.defaultRequestHandler = wsHandler.onRequest;
  
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', port);
  print('listening for connections on http://127.0.0.1:$port');
}
