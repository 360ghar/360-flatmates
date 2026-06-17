import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flatmates_app/core/providers.dart';
import 'package:flatmates_app/features/onboarding/mode_selection_page.dart';
import 'package:flatmates_app/features/onboarding/basic_info_page.dart';
import 'package:flatmates_app/features/onboarding/onboarding_controller.dart';
import 'package:flatmates_app/features/shared/presentation/flatmates_ui.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('OnboardingController', () {
    test('completing splash moves a new user to mode selection', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await testAppPreferences;
      final container = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final controller = container.read(onboardingControllerProvider.notifier);
      await controller.completeSplash();

      final state = container.read(onboardingControllerProvider);
      expect(state.step, OnboardingStep.modeSelection);
      expect(state.mode, isNull);
    });

    test('previousStep maps the flow backwards and stops at modeSelection', () {
      expect(
        OnboardingController.previousStep(OnboardingStep.modeSelection),
        isNull,
      );
      expect(OnboardingController.previousStep(OnboardingStep.splash), isNull);
      expect(
        OnboardingController.previousStep(OnboardingStep.basicInfo),
        OnboardingStep.locationSelection,
      );
      expect(
        OnboardingController.previousStep(OnboardingStep.nonNegotiables),
        OnboardingStep.preferences,
      );
    });

    test(
      'goBack steps backwards while preserving collected draft data',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await testAppPreferences;
        final container = ProviderContainer(
          overrides: [appPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          onboardingControllerProvider.notifier,
        );
        await controller.setMode('co_hunter');
        await controller.setLocation({'city': 'Delhi', 'locality': null});
        await controller.setBasicInfo({
          'full_name': 'Jane Doe',
          'age': 25,
          'profession': 'Designer',
          'city': 'Delhi',
        });

        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.profilePhoto,
        );

        // Step back to basic info, then to location — data must survive.
        final moved = await controller.goBack();
        expect(moved, isTrue);
        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.basicInfo,
        );
        expect(
          container.read(onboardingControllerProvider).fullName,
          'Jane Doe',
        );

        await controller.goBack();
        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.locationSelection,
        );
        expect(container.read(onboardingControllerProvider).city, 'Delhi');
      },
    );

    test(
      'goBack at mode selection is a no-op and reports no transition',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await testAppPreferences;
        final container = ProviderContainer(
          overrides: [appPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          onboardingControllerProvider.notifier,
        );
        await controller.completeSplash();
        expect(controller.canGoBack, isFalse);

        final moved = await controller.goBack();
        expect(moved, isFalse);
        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.modeSelection,
        );
      },
    );

    test(
      'a saved in-progress draft is restored on a fresh controller',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await testAppPreferences;
        final container = ProviderContainer(
          overrides: [appPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          onboardingControllerProvider.notifier,
        );
        await controller.setMode('room_poster');
        await controller.setLocation({'city': 'Mumbai', 'locality': null});

        // Simulate an app restart: a brand new container reading the same prefs.
        final restarted = ProviderContainer(
          overrides: [appPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(restarted.dispose);

        final restored = restarted.read(onboardingControllerProvider);
        expect(restored.step, OnboardingStep.basicInfo);
        expect(restored.mode, 'room_poster');
        expect(restored.city, 'Mumbai');
        expect(restored.isHydrated, isTrue);
      },
    );
  });

  group('ModeSelectionPage', () {
    testWidgets('renders exactly three mode options', (tester) async {
      await tester.pumpWidget(
        testableWidget(child: ModeSelectionPage(onModeSelected: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('mode_room_poster')), findsOneWidget);
      expect(find.byKey(const Key('mode_co_hunter')), findsOneWidget);
      expect(find.byKey(const Key('mode_open_to_both')), findsOneWidget);
    });

    testWidgets('selecting a mode and pressing continue calls onModeSelected', (
      tester,
    ) async {
      String? selectedMode;
      await tester.pumpWidget(
        testableWidget(
          child: ModeSelectionPage(
            onModeSelected: (mode) => selectedMode = mode,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select a mode card
      await tester.tap(find.byKey(const Key('mode_co_hunter')));
      await tester.pumpAndSettle();

      // Continue button should now be enabled — tap it
      await tester.tap(find.byKey(const Key('mode_continue')));
      expect(selectedMode, 'co_hunter');
    });
  });

  group('BasicInfoPage', () {
    // BasicInfoPage now hydrates from the onboarding draft in initState, which
    // builds OnboardingController and therefore needs AppPreferences overridden.
    late List<Override> overrides;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      resetTestAppPreferences();
      final prefs = await testAppPreferences;
      overrides = [appPreferencesProvider.overrideWithValue(prefs)];
    });

    testWidgets('next button is disabled when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        testableWidget(
          overrides: overrides,
          child: BasicInfoPage(onNext: (_) {}),
        ),
      );
      await tester.pump();

      // Scroll to bottom to ensure the button is visible in ListView
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();

      final keyFinder = find.byKey(const Key('onboarding_basic_info_next'));
      expect(keyFinder, findsOneWidget);
      final button = tester.widget<FlatmatesButton>(keyFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('next button is disabled when age is under 18', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          overrides: overrides,
          child: BasicInfoPage(onNext: (_) {}),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('onboarding_name')),
        'John Doe',
      );
      await tester.enterText(find.byKey(const Key('onboarding_age')), '17');
      await tester.enterText(
        find.byKey(const Key('onboarding_profession')),
        'Engineer',
      );
      await tester.enterText(find.byKey(const Key('onboarding_city')), 'Delhi');
      await tester.pump();

      // Scroll to bottom
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();

      final button = tester.widget<FlatmatesButton>(
        find.byKey(const Key('onboarding_basic_info_next')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('next button is enabled when all fields valid and age >= 18', (
      tester,
    ) async {
      await tester.pumpWidget(
        testableWidget(
          overrides: overrides,
          child: BasicInfoPage(onNext: (_) {}),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('onboarding_name')),
        'Jane Doe',
      );
      await tester.enterText(find.byKey(const Key('onboarding_age')), '25');
      await tester.enterText(
        find.byKey(const Key('onboarding_profession')),
        'Designer',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_city')),
        'Mumbai',
      );
      await tester.pump();

      // Scroll to bottom
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();

      final button = tester.widget<FlatmatesButton>(
        find.byKey(const Key('onboarding_basic_info_next')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('age of exactly 18 is accepted', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          overrides: overrides,
          child: BasicInfoPage(onNext: (_) {}),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('onboarding_name')),
        'Test User',
      );
      await tester.enterText(find.byKey(const Key('onboarding_age')), '18');
      await tester.enterText(
        find.byKey(const Key('onboarding_profession')),
        'Student',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_city')),
        'Bangalore',
      );
      await tester.pump();

      // Scroll to bottom
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();

      final button = tester.widget<FlatmatesButton>(
        find.byKey(const Key('onboarding_basic_info_next')),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
