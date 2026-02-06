import 'dart:async';
import 'dart:io';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/model/message_model.dart';
import 'package:afriqueen/features/chat/model/message_request_model.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String chatId;

  const LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends ChatEvent {
  final String chatId;
  final String receiverId;
  final String content;
  final MessageType type;
  final File? imageFile;
  final String? tempMessageId;

  const SendMessage({
    required this.chatId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.imageFile,
    this.tempMessageId,
  });

  @override
  List<Object?> get props => [chatId, receiverId, content, type, imageFile, tempMessageId];
}

class MarkMessagesAsRead extends ChatEvent {
  final String chatId;

  const MarkMessagesAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeleteMessage extends ChatEvent {
  final String chatId;
  final String messageId;

  DeleteMessage({
    required this.chatId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [chatId, messageId];
}

class UpdateMessageStatus extends ChatEvent {
  final String chatId;
  final String messageId;
  final bool isUploaded;

  UpdateMessageStatus({
    required this.chatId,
    required this.messageId,
    required this.isUploaded,
  });

  @override
  List<Object?> get props => [chatId, messageId, isUploaded];
}

class LoadMessageRequests extends ChatEvent {}

class LoadRequestChats extends ChatEvent {}

class LoadReceivedRequestChats extends ChatEvent {}

class LoadSentRequestChats extends ChatEvent {}

class SendMessageRequest extends ChatEvent {
  final String receiverId;
  final String content;
  final String receiverName;
  final String? receiverPhotoUrl;

  const SendMessageRequest({
    required this.receiverId,
    required this.content,
    required this.receiverName,
    this.receiverPhotoUrl,
  });

  @override
  List<Object?> get props => [receiverId, content, receiverName, receiverPhotoUrl];
}

class AcceptMessageRequest extends ChatEvent {
  final String requestId;

  const AcceptMessageRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectMessageRequest extends ChatEvent {
  final String requestId;

  const RejectMessageRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class AcceptRequestChat extends ChatEvent {
  final String chatId;

  const AcceptRequestChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeclineRequestChat extends ChatEvent {
  final String chatId;
  final String otherUserId;

  const DeclineRequestChat({
    required this.chatId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [chatId, otherUserId];
}

class ArchiveRejectedProfile extends ChatEvent {
  final String otherUserId;

  const ArchiveRejectedProfile(this.otherUserId);

  @override
  List<Object?> get props => [otherUserId];
}

class LoadArchivedChats extends ChatEvent {}

// Internal events for stream updates
class _ChatsUpdated extends ChatEvent {
  final List<ChatModel> chats;
  const _ChatsUpdated(this.chats);
  @override
  List<Object?> get props => [chats];
}

class _MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;
  const _MessagesUpdated(this.messages);
  @override
  List<Object?> get props => [messages];
}

class _ChatError extends ChatEvent {
  final String message;
  const _ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class _MessageRequestsUpdated extends ChatEvent {
  final List<MessageRequestModel> requests;
  const _MessageRequestsUpdated(this.requests);
  @override
  List<Object?> get props => [requests];
}

class _RequestChatsUpdated extends ChatEvent {
  final List<ChatModel> requestChats;
  final List<MessageRequestModel> requests;

  const _RequestChatsUpdated(this.requestChats, this.requests);

  @override
  List<Object?> get props => [requestChats, requests];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatListLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatListLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageRequestsLoaded extends ChatState {
  final List<MessageRequestModel> requests;

  const MessageRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestChatsLoaded extends ChatState {
  final List<ChatModel> requestChats;

  const RequestChatsLoaded(this.requestChats);

  @override
  List<Object?> get props => [requestChats];
}

class ReceivedRequestChatsLoaded extends ChatState {
  final List<ChatModel> receivedRequestChats;

  const ReceivedRequestChatsLoaded(this.receivedRequestChats);

  @override
  List<Object?> get props => [receivedRequestChats];
}

class SentRequestChatsLoaded extends ChatState {
  final List<ChatModel> sentRequestChats;

  const SentRequestChatsLoaded(this.sentRequestChats);

  @override
  List<Object?> get props => [sentRequestChats];
}

class RequestsAndRequestChatsLoaded extends ChatState {
  final List<MessageRequestModel> requests;
  final List<ChatModel> requestChats;

  const RequestsAndRequestChatsLoaded({
    required this.requests,
    required this.requestChats,
  });

  @override
  List<Object?> get props => [requests, requestChats];
}

class ChatListWithRequestsLoaded extends ChatState {
  final List<ChatModel> chats;
  final List<MessageRequestModel> requests;

  const ChatListWithRequestsLoaded({
    required this.chats,
    required this.requests,
  });

  @override
  List<Object?> get props => [chats, requests];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messagesSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<LoadMessageRequests>(_onLoadMessageRequests);
    on<LoadRequestChats>(_onLoadRequestChats);
    on<LoadReceivedRequestChats>(_onLoadReceivedRequestChats);
    on<LoadSentRequestChats>(_onLoadSentRequestChats);
    on<SendMessageRequest>(_onSendMessageRequest);
    on<AcceptMessageRequest>(_onAcceptMessageRequest);
    on<AcceptRequestChat>(_onAcceptRequestChat);
    on<DeclineRequestChat>(_onDeclineRequestChat);
    on<ArchiveRejectedProfile>(_onArchiveRejectedProfile);
    on<LoadArchivedChats>(_onLoadArchivedChats);
    on<_ChatsUpdated>(_onChatsUpdated);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<_MessageRequestsUpdated>(_onMessageRequestsUpdated);
    on<_ChatError>(_onChatError);
    on<DeleteMessage>(_onDeleteMessage);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<_RequestChatsUpdated>(_onRequestChatsUpdated);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getRegularChatsStream();
      await for (final chats in stream) {
        if (!isClosed && !emit.isDone) {
          add(_ChatsUpdated(chats));
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      await _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository
          .getMessagesStream(event.chatId)
          .listen((messages) {
        add(_MessagesUpdated(messages));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onChatsUpdated(_ChatsUpdated event, Emitter<ChatState> emit) {
    if (event.chats != null) {
      // If we have message requests loaded, emit combined state
      if (state is MessageRequestsLoaded) {
        final requestsState = state as MessageRequestsLoaded;
        emit(ChatListWithRequestsLoaded(
          chats: event.chats!,
          requests: requestsState.requests,
        ));
      } else {
        emit(ChatListLoaded(event.chats!));
      }
    }
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<ChatState> emit) {
    if (event.messages != null) {
      emit(MessagesLoaded(event.messages!));
    }
  }

  void _onChatError(_ChatError event, Emitter<ChatState> emit) {
    emit(ChatError(event.message));
  }

  Future<void> _onLoadMessageRequests(LoadMessageRequests event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getMessageRequestsStream();
      await for (final requests in stream) {
        if (!isClosed && !emit.isDone) {
          add(_MessageRequestsUpdated(requests));
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onLoadRequestChats(LoadRequestChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getRequestChatsStream();
      await for (final requestChats in stream) {
        if (!isClosed && !emit.isDone) {
          // If we have message requests loaded, emit combined state
          if (state is MessageRequestsLoaded) {
            final requestsState = state as MessageRequestsLoaded;
            add(_RequestChatsUpdated(requestChats, requestsState.requests));
          } else {
            add(_RequestChatsUpdated(requestChats, []));
          }
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onLoadReceivedRequestChats(LoadReceivedRequestChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getReceivedRequestChatsStream();
      await for (final receivedRequestChats in stream) {
        if (!isClosed && !emit.isDone) {
          emit(ReceivedRequestChatsLoaded(receivedRequestChats));
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onLoadSentRequestChats(LoadSentRequestChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getSentRequestChatsStream();
      await for (final sentRequestChats in stream) {
        if (!isClosed && !emit.isDone) {
          emit(SentRequestChatsLoaded(sentRequestChats));
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  void _onRequestChatsUpdated(_RequestChatsUpdated event, Emitter<ChatState> emit) {
    if (event.requestChats != null) {
      emit(RequestsAndRequestChatsLoaded(
        requests: event.requests,
        requestChats: event.requestChats!,
      ));
    }
  }

  Future<void> _onSendMessageRequest(SendMessageRequest event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.sendMessageRequest(
        receiverId: event.receiverId,
        content: event.content,
        receiverName: event.receiverName,
        receiverPhotoUrl: event.receiverPhotoUrl,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onAcceptMessageRequest(AcceptMessageRequest event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.acceptMessageRequest(event.requestId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onAcceptRequestChat(AcceptRequestChat event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.updateChatStatus(event.chatId, status: 'ACCEPTED');
      // Refresh request lists so UI moves item out of Pending immediately
      add(LoadReceivedRequestChats());
      add(LoadSentRequestChats());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onDeclineRequestChat(DeclineRequestChat event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.updateChatStatus(event.chatId, status: 'REJECTED');
      // Refresh request lists so UI moves item out of Pending immediately
      add(LoadReceivedRequestChats());
      add(LoadSentRequestChats());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onArchiveRejectedProfile(ArchiveRejectedProfile event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.archiveRejectedProfile(event.otherUserId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadArchivedChats(LoadArchivedChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Get the stream and await the first emission
      final stream = _chatRepository.getArchivedChatsStream();
      await for (final chats in stream) {
        if (!isClosed && !emit.isDone) {
          add(_ChatsUpdated(chats));
          break; // Only take the first emission
        }
      }
    } catch (e) {
      if (!isClosed && !emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  void _onMessageRequestsUpdated(_MessageRequestsUpdated event, Emitter<ChatState> emit) {
    if (event.requests != null) {
      // If we have chats loaded, emit combined state
      if (state is ChatListLoaded) {
        final chatsState = state as ChatListLoaded;
        emit(ChatListWithRequestsLoaded(
          chats: chatsState.chats,
          requests: event.requests!,
        ));
      } else {
        emit(MessageRequestsLoaded(event.requests!));
      }
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      if (event.type == MessageType.voice && event.imageFile != null) {
        // Handle voice message
        await _chatRepository.sendVoiceMessage(
          chatId: event.chatId,
          receiverId: event.receiverId,
          audioFile: event.imageFile!,
          duration: int.tryParse(event.content) ?? 0,
        );

        // Reload messages to get the updated state
        final messages = await _chatRepository.getMessages(event.chatId);
        emit(MessagesLoaded(messages));
      } else {
        // Handle other message types
      await _chatRepository.sendMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        content: event.content,
        type: event.type,
        imageFile: event.imageFile,
      );

        // Reload messages to get the updated state
      final messages = await _chatRepository.getMessages(event.chatId);
      emit(MessagesLoaded(messages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkMessagesAsRead(MarkMessagesAsRead event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.markMessagesAsRead(event.chatId);
    } catch (e) {
        emit(ChatError(e.toString()));
    }
  }

  void _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.deleteMessage(event.chatId, event.messageId);
      // After deletion, reload messages to update the UI
      final messages = await _chatRepository.getMessages(event.chatId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      debugPrint('Error deleting message: $e');
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onUpdateMessageStatus(UpdateMessageStatus event, Emitter<ChatState> emit) async {
    try {
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;
      final updatedMessages = currentState.messages.map((message) {
        if (message.id == event.messageId) {
          return message.copyWith(isUploaded: event.isUploaded);
        }
        return message;
      }).toList();
      emit(MessagesLoaded(updatedMessages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
} 