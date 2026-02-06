// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:equatable/equatable.dart';


//-----------------------------Fav State-----------------------------
class ArchiveState extends Equatable {
  final List<HomeModel> archiveUserList;
  const ArchiveState({
    required this.archiveUserList,
  });

  @override
  List<Object> get props => [archiveUserList];
}

final class ArchiveInitial extends ArchiveState {
  ArchiveInitial() : super(archiveUserList: []);
}

final class ArchiveUsersLoading extends ArchiveState {
  ArchiveUsersLoading() : super(archiveUserList: []);
}

final class ArchiveUsersError extends ArchiveState {
  final String errorMessage;

  ArchiveUsersError.fromState(ArchiveState state,
      {required this.errorMessage})
      : super(archiveUserList: state.archiveUserList);

  @override
  List<Object> get props => [errorMessage];
}

final class ArchiveDataEmpty extends ArchiveState {
  ArchiveDataEmpty() : super(archiveUserList: []);
}
