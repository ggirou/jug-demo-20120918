#library('jug-demo');

#import('dart:io');
#import('dart:isolate');

class TickHandler {
  int counter = 0;
  Timer timer;

  TickHandler() {
    toggle();
  }

  toggle() {
    if(timer == null) {
      timer =  new Timer.repeating(1000, tick); 
    } else {
      timer.cancel();
      timer = null;
    }
  }
  
  tick(var _timer) {
    counter++;
    // TODO 5 Server side timer
  }
  
  send(String value) {
    if(timer != null) {
      print("Send: $value");
      connections.forEach((conn) => conn.send(value));
    }
  }
  
  Set<WebSocketConnection> connections = new Set<WebSocketConnection>();
  onOpen(WebSocketConnection conn) {
    conn.onMessage = (message) {
      print('Message received: $message');
      // TODO 6 : Stop server side timer on click
    };

    print('New WebSocket connection');
    connections.add(conn);
    conn.onClosed = (status, reason) => connections.remove(conn);
    conn.onError = (e) => connections.remove(conn);
  }
}

main() {
  // 14 Septembre 2012 ! :p
  var port = 14912;

  HttpServer server = new HttpServer();
  server.onError = (error) => print(error);
  
  var handler = new WebSocketHandler();
  handler.onOpen = new TickHandler().onOpen;
  // TODO set the default handler
  
  server.listen('127.0.0.1', port);
  print('listening for connections on http://127.0.0.1:$port');
}
