import 'package:afriqueen/features/event/model/event_message_model.dart';
import 'package:afriqueen/features/event/repository/event_message_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class EventMessageEvent extends Equatable {
  const EventMessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventMessages extends EventMessageEvent {}

class LoadEventMessagesByEvent extends EventMessageEvent {
  final String eventId;

  const LoadEventMessagesByEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class LoadUserEventMessages extends EventMessageEvent {}

class SendEventMessage extends EventMessageEvent {
  final String eventId;
  final String content;
  final String eventTitle;
  final String eventImageUrl;
  final bool isEventFinished;
  final String eventStatus;

  const SendEventMessage({
    required this.eventId,
    required this.content,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.isEventFinished,
    required this.eventStatus,
  });

  @override
  List<Object?> get props => [
        eventId,
        content,
        eventTitle,
        eventImageUrl,
        isEventFinished,
        eventStatus,
      ];
}

class DeleteFinishedEventDiscussions extends EventMessageEvent {}

class LoadParticipatedEvents extends EventMessageEvent {}

// States
abstract class EventMessageState extends Equatable {
  const EventMessageState();

  @override
  List<Object?> get props => [];
}

class EventMessageInitial extends EventMessageState {}

class EventMessageLoading extends EventMessageState {}

class EventMessageLoaded extends EventMessageState {
  final List<EventMessageModel> messages;
  final Map<String, List<EventMessageModel>> groupedMessages;

  const EventMessageLoaded({
    required this.messages,
    required this.groupedMessages,
  });

  @override
  List<Object?> get props => [messages, groupedMessages];
}

class EventMessageByEventLoaded extends EventMessageState {
  final List<EventMessageModel> messages;

  const EventMessageByEventLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ParticipatedEventsLoaded extends EventMessageState {
  final List<String> eventIds;

  const ParticipatedEventsLoaded(this.eventIds);

  @override
  List<Object?> get props => [eventIds];
}

class EventMessageError extends EventMessageState {
  final String message;

  const EventMessageError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventMessageSent extends EventMessageState {}

class FinishedEventDiscussionsDeleted extends EventMessageState {}

// Bloc
class EventMessageBloc extends Bloc<EventMessageEvent, EventMessageState> {
  final EventMessageRepository _repository;

  EventMessageBloc(this._repository) : super(EventMessageInitial()) {
    on<LoadEventMessages>(_onLoadEventMessages);
    on<LoadEventMessagesByEvent>(_onLoadEventMessagesByEvent);
    on<LoadUserEventMessages>(_onLoadUserEventMessages);
    on<SendEventMessage>(_onSendEventMessage);
    on<DeleteFinishedEventDiscussions>(_onDeleteFinishedEventDiscussions);
    on<LoadParticipatedEvents>(_onLoadParticipatedEvents);
  }

  Future<void> _onLoadEventMessages(
    LoadEventMessages event,
    Emitter<EventMessageState> emit,
  ) async {
    emit(EventMessageLoading());
    try {
      await for (final messages in _repository.streamUserEventMessages()) {
        final groupedMessages = <String, List<EventMessageModel>>{};
        for (final message in messages) {
          if (!groupedMessages.containsKey(message.eventId)) {
            groupedMessages[message.eventId] = [];
          }
          groupedMessages[message.eventId]!.add(message);
        }
        emit(EventMessageLoaded(
          messages: messages,
          groupedMessages: groupedMessages,
        ));
      }
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }

  Future<void> _onLoadEventMessagesByEvent(
    LoadEventMessagesByEvent event,
    Emitter<EventMessageState> emit,
  ) async {
    emit(EventMessageLoading());
    try {
      await for (final messages in _repository.streamEventMessages(event.eventId)) {
        emit(EventMessageByEventLoaded(messages));
      }
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }

  Future<void> _onLoadUserEventMessages(
    LoadUserEventMessages event,
    Emitter<EventMessageState> emit,
  ) async {
    emit(EventMessageLoading());
    try {
      await for (final messages in _repository.streamUserEventMessages()) {
        final groupedMessages = <String, List<EventMessageModel>>{};
        for (final message in messages) {
          if (!groupedMessages.containsKey(message.eventId)) {
            groupedMessages[message.eventId] = [];
          }
          groupedMessages[message.eventId]!.add(message);
        }
        emit(EventMessageLoaded(
          messages: messages,
          groupedMessages: groupedMessages,
        ));
      }
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }

  Future<void> _onSendEventMessage(
    SendEventMessage event,
    Emitter<EventMessageState> emit,
  ) async {
    try {
      await _repository.sendEventMessage(
        eventId: event.eventId,
        content: event.content,
        eventTitle: event.eventTitle,
        eventImageUrl: event.eventImageUrl,
        isEventFinished: event.isEventFinished,
        eventStatus: event.eventStatus,
      );
      emit(EventMessageSent());
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }

  Future<void> _onDeleteFinishedEventDiscussions(
    DeleteFinishedEventDiscussions event,
    Emitter<EventMessageState> emit,
  ) async {
    try {
      await _repository.deleteFinishedEventDiscussions();
      emit(FinishedEventDiscussionsDeleted());
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }

  Future<void> _onLoadParticipatedEvents(
    LoadParticipatedEvents event,
    Emitter<EventMessageState> emit,
  ) async {
    try {
      await for (final eventIds in _repository.streamUserParticipatedEvents()) {
        emit(ParticipatedEventsLoaded(eventIds));
      }
    } catch (e) {
      emit(EventMessageError(e.toString()));
    }
  }
}
