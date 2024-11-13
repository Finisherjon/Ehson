import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Initialize the connection and register the user ID
  void connectToSocket(String userId) {
    socket = IO.io('ws://tezkor-ofitsant.uz:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect to the server
    socket.connect();

    // Register the user ID on connect
    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('registerUser', {'userId': userId});
    });

    // Listen for incoming messages
    socket.on('receiveMessage', (data) {
      String fromUserId = data['fromUserId'];
      String message = data['message'];
      print('Message from $fromUserId: $message');
    });

    // Handle disconnection
    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  // Function to send a message to a specific user ID
  void sendMessage(String fromUserId, String toUserId, String message) {
    socket.emit('sendMessage', {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message
    });
  }
}
