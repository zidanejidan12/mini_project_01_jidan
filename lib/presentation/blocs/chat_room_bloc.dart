
import 'package:flutter_bloc/flutter_bloc.dart';

// Define the events for the chat room bloc
abstract class ChatRoomEvent {}

class SendMessageEvent extends ChatRoomEvent {
  final String message;

  SendMessageEvent(this.message);
}

// Define the states for the chat room bloc
abstract class ChatRoomState {}

class InitialChatRoomState extends ChatRoomState {}

class MessageSentState extends ChatRoomState {
  final String message;

  MessageSentState(this.message);
}

// Define the chat room bloc
class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  ChatRoomBloc() : super(InitialChatRoomState());

  @override
  Stream<ChatRoomState> mapEventToState(ChatRoomEvent event) async* {
    if (event is SendMessageEvent) {
      yield MessageSentState(event.message);
    }
  }
}
