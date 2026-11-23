import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/src/feature/settings/data/repository/settings_repository.dart';
import 'package:flutter_starter/src/feature/settings/enum/theme_type.dart';
import 'package:flutter_starter/src/feature/settings/model/settings_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required ISettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(SettingsState.idle(data: settingsRepository.defaultData)) {
    on<_SettingsEventSetTheme>(_setTheme);
    on<_SettingsEventGetData>(_getData);
  }

  final ISettingsRepository _settingsRepository;

  Future<void> _setTheme(
    _SettingsEventSetTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final data = state.data.copyWith(themeType: event.themeType);
    await _settingsRepository.setTheme(event.themeType);
    emit(state.copyWith(data: data));
  }

  Future<void> _getData(
    _SettingsEventGetData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsState.loading(data: state.data));

    final data = await _settingsRepository.getData();

    emit(SettingsState.idle(data: data));
  }
}
