import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileState {
  final bool isProfileLoading;
  final ProfileEntity? profile;
  final bool isEvListLoading;
  final List<SupportedEvEntity> supportedEvs;
  final String manualUrl;
  final String? errorMessage;

  const ProfileState({
    this.isProfileLoading = true,
    this.profile,
    this.isEvListLoading = false,
    this.supportedEvs = const [],
    this.manualUrl = 'https://coolors.co/',
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isProfileLoading,
    ProfileEntity? profile,
    bool? isEvListLoading,
    List<SupportedEvEntity>? supportedEvs,
    String? manualUrl,
    String? errorMessage,
  }) {
    return ProfileState(
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      profile: profile ?? this.profile,
      isEvListLoading: isEvListLoading ?? this.isEvListLoading,
      supportedEvs: supportedEvs ?? this.supportedEvs,
      manualUrl: manualUrl ?? this.manualUrl,
      errorMessage: errorMessage,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  final IProfileRepository _repository;
  StreamSubscription<ProfileEntity>? _profileSubscription;

  ProfileCubit(this._repository)
      : super(ProfileState(manualUrl: _repository.getUserManualUrl()));

  void startWatchingProfile() {
    _profileSubscription?.cancel();
    emit(state.copyWith(isProfileLoading: true, errorMessage: null));

    _profileSubscription = _repository.watchUserProfile().listen(
          (profileEntity) {
        emit(state.copyWith(
          isProfileLoading: false,
          profile: profileEntity,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          isProfileLoading: false,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> loadSupportedEvModels() async {
    if (state.supportedEvs.isNotEmpty) return;

    emit(state.copyWith(isEvListLoading: true, errorMessage: null));
    try {
      final models = await _repository.getSupportedEvModels();
      emit(state.copyWith(
        isEvListLoading: false,
        supportedEvs: models,
      ));
    } catch (e) {
      emit(state.copyWith(
        isEvListLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}