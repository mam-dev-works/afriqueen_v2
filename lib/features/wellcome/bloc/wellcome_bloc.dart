import 'package:afriqueen/features/wellcome/bloc/wellcome_event.dart';
import 'package:afriqueen/features/wellcome/bloc/wellcome_state.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

//-----------------------------Bloc for wellcome page-----------------------------------
class WellcomeBloc extends HydratedBloc<WellcomeEvent, WellcomeState> {
  WellcomeBloc() : super(WellcomeInitial()) {
    on<ChangeLanguageEvent>((event, emit) {
      emit(state.copyWith(languageCode: event.languageCode));
    });
  }

  @override
  WellcomeState? fromJson(Map<String, dynamic> json) {
    try {
      final languageCode = json['languageCode'] as String?;

      return WellcomeState(languageCode: languageCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(WellcomeState state) {
    try {
      return {'languageCode': state.languageCode};
    } catch (_) {
      return null;
    }
  }
}
