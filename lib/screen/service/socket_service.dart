import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Initialize the connection and register the user ID
  void connectToSocket(String userId) {
    socket = IO.io('ws://178.250.156.99:4000', <String, dynamic>{
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
  void sendMessage(String chatId,String fromUserId, String toUserId, String message) {
    socket.emit('sendMessage', {
      'chatId': chatId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message
    });
  }
}
