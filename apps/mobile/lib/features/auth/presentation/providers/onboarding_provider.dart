import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/usecases/update_user_profile.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.selectedNeighborhood,
    this.selectedFrequency,
    this.selectedExperience,
    this.isSubmitting = false,
    this.submitError,
  });

  final int currentStep;
  final String? selectedNeighborhood;
  final CheckInFrequency? selectedFrequency;
  final PlantExperience? selectedExperience;
  final bool isSubmitting;
  final String? submitError;

  OnboardingState copyWith({
    int? currentStep,
    String? selectedNeighborhood,
    bool clearNeighborhood = false,
    CheckInFrequency? selectedFrequency,
    bool clearFrequency = false,
    PlantExperience? selectedExperience,
    bool clearExperience = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
  }) => OnboardingState(
    currentStep: currentStep ?? this.currentStep,
    selectedNeighborhood: clearNeighborhood
        ? null
        : selectedNeighborhood ?? this.selectedNeighborhood,
    selectedFrequency: clearFrequency
        ? null
        : selectedFrequency ?? this.selectedFrequency,
    selectedExperience: clearExperience
        ? null
        : selectedExperience ?? this.selectedExperience,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    submitError: clearSubmitError ? null : submitError ?? this.submitError,
  );
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);

  void previousStep() =>
      state = state.copyWith(currentStep: state.currentStep - 1);

  void selectNeighborhood(String neighborhood) =>
      state = state.copyWith(selectedNeighborhood: neighborhood);

  void selectFrequency(CheckInFrequency frequency) =>
      state = state.copyWith(selectedFrequency: frequency);

  void selectExperience(PlantExperience experience) =>
      state = state.copyWith(selectedExperience: experience);

  /// Writes the collected answers to Firestore in a single update() call.
  /// Sets onboardingComplete: true regardless of which fields were skipped.
  /// On success the router redirect re-evaluates and navigates to /grove.
  /// On failure sets [OnboardingState.submitError]; caller shows retry UI.
  Future<void> submit(String uid) async {
    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await UpdateUserProfile(repository).call(
        uid: uid,
        neighborhood: state.selectedNeighborhood,
        checkInFrequency: state.selectedFrequency,
        plantExperience: state.selectedExperience,
        onboardingComplete: true,
      );
      state = state.copyWith(isSubmitting: false);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Something went wrong. Please try again.',
      );
    }
  }
}
