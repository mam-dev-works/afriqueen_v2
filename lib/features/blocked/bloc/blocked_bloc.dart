import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/model/home_model.dart';
import '../../home/repository/home_repository.dart';
import '../model/blocked_model.dart';
import '../repository/blocked_repository.dart';
import 'blocked_event.dart';
import 'blocked_state.dart';

class BlockedBloc extends Bloc<BlockedEvent, BlockedState> {
  final BlockedRepository _blockedRepository;
  final HomeRepository _homeRepository = HomeRepository();
  
  BlockedBloc({required BlockedRepository repository})
      : _blockedRepository = repository,
        super(BlockedInitial()) {
    on<BlockedUserAdded>(_onBlockedUserAdded);
    on<BlockedUserRemoved>(_onBlockedUserRemoved);
    on<BlockedUsersFetched>(_onBlockedUsersFetched);
  }

  //-------------------------Fetching data----------------------------
  FutureOr<void> _onBlockedUsersFetched(
      BlockedUsersFetched event, Emitter<BlockedState> emit) async {
    emit(BlockedUsersLoading());
    try {
      final BlockedModel? data = await _blockedRepository.fetchBlockedUsers();
      final List<HomeModel> homeModelData =
          await _homeRepository.fetchAllExceptCurrentUser();

      if (data != null) {
        final List<HomeModel> blockedUserData = homeModelData
            .where((e) => e.id.isNotEmpty && data.blockedUserId.contains(e.id))
            .toList();
        emit(BlockedState(blockedUserList: blockedUserData));
      } else {
        emit(BlockedDataEmpty());
      }
    } catch (e) {
      emit(BlockedUsersError.fromState(state, errorMessage: e.toString()));
    }
  }

  //-----------------------------Removing user from blocked list-------------------------------------------
  FutureOr<void> _onBlockedUserRemoved(
      BlockedUserRemoved event, Emitter<BlockedState> emit) async {
    await _blockedRepository.unblockUser(event.blockedUserId);
    add(BlockedUsersFetched());
  }

  //-------------------------------------Adding to blocked list----------------------------------
  FutureOr<void> _onBlockedUserAdded(
      BlockedUserAdded event, Emitter<BlockedState> emit) async {
    await _blockedRepository.blockUser(event.blockedUserId);
  }
} 