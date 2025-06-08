import 'dart:async';

import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_state.dart';
import 'package:afriqueen/features/favorite/model/favorite_model.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favouriteRepository;
  final HomeRepository _homeRepository = HomeRepository();
  FavoriteBloc({required FavoriteRepository repository})
      : _favouriteRepository = repository,
        super(FavoriteInitial()) {
    on<FavoriteUserAdded>(_onFavoriteUserAdded);

    on<FavoriteUserRemoved>(_onFavoriteUserRemoved);

    on<FavoriteUsersFetched>(_onFavoriteUsersFetched);
  }
//-------------------------Fetching data----------------------------
  FutureOr<void> _onFavoriteUsersFetched(
      FavoriteUsersFetched event, Emitter<FavoriteState> emit) async {
    emit(FavoriteUsersLoading());
    try {
      final FavoriteModel? data = await _favouriteRepository.fetchFavorites();
      final List<HomeModel> homeModelData =
          await _homeRepository.fetchAllExceptCurrentUser();

      if (data != null) {
        final List<HomeModel> favUserData = homeModelData
            .where((e) => e.id.isNotEmpty && data.favId.contains(e.id))
            .toList();
        emit(FavoriteState(favUserList: favUserData));
      } else {
        emit(FavoriteDataEmpty());
      }
    } catch (e) {
      emit(FavoriteUsersError.fromState(state, errorMessage: e.toString()));
    }
  }

//-----------------------------Removing user from fav list-------------------------------------------
  FutureOr<void> _onFavoriteUserRemoved(
      FavoriteUserRemoved event, Emitter<FavoriteState> emit) async {
    await _favouriteRepository.removeFavorite(event.favId);

    add(FavoriteUsersFetched());
  }

//-------------------------------------Adding to fav list----------------------------------
  FutureOr<void> _onFavoriteUserAdded(
      FavoriteUserAdded event, Emitter<FavoriteState> emit) async {
    await _favouriteRepository.addFavorite(event.favId);
  }
}
