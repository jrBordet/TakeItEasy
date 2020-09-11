////
////  AlarmsDemoTests.swift
////  AlarmsDemoTests
////
////  Created by Jean Raphael Bordet on 17/05/2020.
////  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
////
//
//import XCTest
//@testable import AlarmsDemo
//import Alarms
//
//import RxSwift
//import RxCocoa
//import RxComposableArchitecture
//import RxComposableArchitectureTests
//import SnapshotTesting
//import SceneBuilder
//import Caprice
//
//import RxTest
//import RxBlocking
//
////extension Step {
////  static func send(_ action: Action, update: @escaping (inout Value) -> Void) -> Step {
////    Step(.send, action, update)
////  }
////
////  static func receive(_ action: Action, update: @escaping (inout Value) -> Void) -> Step {
////    Step(.receive, action, update)
////  }
////
////  static func sendSync(_ action: Action, update: @escaping (inout Value) -> Void) -> Step {
////    Step(.sendSync, action, update)
////  }
////}
//
//// https://en.wikipedia.org/wiki/Behavior-driven_development
//
///**
// Title: Returns and exchanges go to inventory.
//
// As a store owner,
// I want to add items back to inventory when they are returned or exchanged,
// so that I can track inventory.
//
// Scenario 1: Items returned for refund should be added to inventory.
// Given that a customer previously bought a black sweater from me
// and I have three black sweaters in inventory,
// when they return the black sweater for a refund,
// then I should have four black sweaters in inventory.
//
// Scenario 2: Exchanged items should be returned to inventory.
// Given that a customer previously bought a blue garment from me
// and I have two blue garments in inventory
// and three black garments in inventory,
// when they exchange the blue garment for a black garment,
// then I should have three blue garments in inventory
// and two black garments in inventory.
// */
//
///**
//
// Title
// An explicit title.
// Narrative
// A short introductory section with the following structure:
//
// As a: the person or role who will benefit from the feature;
// I want: the feature;
// so that: the benefit or value of the feature.
//
// Acceptance criteria
// A description of each specific scenario of the narrative with the following structure:
// Given: the initial context at the beginning of the scenario, in one or more clauses;
// When: the event that triggers the scenario;
// Then: the expected outcome, in one or more clauses.
//
// */
//
//class AlarmFormTitleTests: XCTestCase {
//  /**
//   As a: user
//   I want: update the title of the alarm;
//   so that: I can customize all my alarms
//   */
//
//  // Given
//  let initialAlarmsCollectionResponse: [Alarm] = [.morningStar, .noon, .empty]
//
//  let initialState = AlarmsCollectionViewState(
//    alarms: [.morningStar],
//    isLoading: false,
//    selectedAlarm: .morningStar
//  )
//
//  func test_demo_title_update() {
//    let detailEnvironment: AlarmFeatureEnvironment = (
//      update: { _ in .just(true) },
//      schedule: { _ in .just(true) },
//      removeSchedule: { _ in .just(true) }
//    )
//
//    let collectionEnvironment: AlarmsCollectionEnvironment = (
//      load: { .sync { self.initialAlarmsCollectionResponse } },
//      save: { _ in }
//    )
//    
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    // MARK: - Scene
//
//    let scene = Scene<AlarmDetailViewController>().render()
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: initialState,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    let detailStore = store.view(
//        value: { $0.alarmDetail },
//        action: { .alarmView($0) }
//    )
//
//    scene.store = detailStore
//
//    assert(
//      initialValue: initialState,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment,
//      steps:
//      Step(.send, .alarmsCollection(.load), { _ in }),
//      Step(.receive, .alarmsCollection(.loadAlarmsCollectionResponse(initialAlarmsCollectionResponse)), { state in
//        assertSnapshot(matching: scene, as: .image)
//
//        state.alarms = [.morningStar, .noon, .empty]
//      }),
//      Step(.send, .alarmsCollection(.select(.morningStar)), { state in
//        state.selectedAlarm = .morningStar
//
//        assertSnapshot(matching: scene, as: .image)
//      })
//    )
//
//  }
//}
//
//class AlarmsDemoTests: XCTestCase {
//  var scheduler: TestScheduler!
//  var disposeBag: DisposeBag!
//
//  let state = AlarmsCollectionViewState(
//    alarms: [],
//    isLoading: false,
//    selectedAlarm: nil
//  )
//
//  let selected = Alarm.noon
//
//  var  expectedResult = [Alarm.morningStar]
//
//  override func setUp() {
//    scheduler = TestScheduler(initialClock: 0)
//    disposeBag = DisposeBag()
//  }
//
//  override func tearDown() {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//  }
//
//  func test_form_title_update_success() {
//    let detailEnvironment: AlarmFeatureEnvironment = (
//      update: { _ in .just(true) },
//      schedule: { _ in .just(true) },
//      removeSchedule: { _ in .just(true) }
//    )
//
//    let collectionEnvironment: AlarmsCollectionEnvironment = (
//      load: { .sync { self.expectedResult } },
//      save: { _ in }
//    )
//
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    let initialState = AlarmsCollectionViewState(
//      alarms: [Alarm.morningStar],
//      isLoading: false,
//      selectedAlarm: Alarm.morningStar
//    )
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: initialState,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    let titleObserver = scheduler.createObserver(String.self)
//
//    store
//      .value
//      .map { state-> String in
//        guard let selectedAlarm = state.selectedAlarm else { return "" }
//
//        return selectedAlarm.title
//    }
//    .distinctUntilChanged()
//    .asDriver(onErrorJustReturn: "")
//    .drive(titleObserver)
//    .disposed(by: disposeBag)
//
//    scheduler
//      .createColdObservable([
//        .next(10, "new"),
//        .next(20, "title")
//      ]).subscribe(onNext: { value in
//        store.send(.alarmView(.alarmView(.title(value))))
//      }).disposed(by: disposeBag)
//
//    scheduler.start()
//
//    XCTAssertEqual(titleObserver.events, [
//      .next(0, "morning star"),
//      .next(10, "new"),
//      .next(20, "title")
//    ])
//  }
//
//  func test_form_update_enabled_success() {
//    let detailEnvironment: AlarmFeatureEnvironment = (
//      update: { _ in .just(true) },
//      schedule: { _ in .just(true) },
//      removeSchedule: { _ in .just(true) }
//    )
//
//    let collectionEnvironment: AlarmsCollectionEnvironment = (
//      load: { .sync { self.expectedResult } },
//      save: { _ in }
//    )
//
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    let initialState = AlarmsCollectionViewState(
//      alarms: [Alarm.morningStar],
//      isLoading: false,
//      selectedAlarm: Alarm.morningStar
//    )
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: initialState,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    let enabledObserver = scheduler.createObserver(Bool.self)
//
//    store
//      .value
//      .map { state-> Bool in
//        guard let selectedAlarm = state.selectedAlarm else { return false }
//
//        return selectedAlarm.enabled
//    }
//    .distinctUntilChanged()
//    .asDriver(onErrorJustReturn: false)
//    .drive(enabledObserver)
//    .disposed(by: disposeBag)
//
//    scheduler
//      .createColdObservable([
//        .next(10, false),
//        .next(20, true)
//      ]).subscribe(onNext: { value in
//        store.send(.alarmView(.alarmView(.enable(value))))
//      }).disposed(by: disposeBag)
//
//    scheduler.start()
//
//    XCTAssertEqual(enabledObserver.events, [
//      .next(0, true),
//      .next(10, false),
//      .next(20, true)
//    ])
//  }
//
//  func test_update_title_success() {
//    let scene = Scene<AlarmsCollectionViewController>().render()
//
//    let updated = selected |> Alarm.titleLens *~ "update noon"
//
//    expectedResult.append(selected)
//
//    let expectedResultUpdated = [
//      Alarm.morningStar,
//      updated
//    ]
//
//    let detailEnvironment: AlarmFeatureEnvironment =
//      (update: { _ in .just(true) },
//       schedule: { _ in .just(true) },
//       removeSchedule: { _ in .just(true) })
//
//    let collectionEnvironment: AlarmsCollectionEnvironment =
//      (load: { .sync { self.expectedResult } },
//       save: { _ in })
//
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    scene.store = store
//
//    assert(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment,
//      steps:
//      Step(.send, .alarmsCollection(.load), {
//        $0.isLoading = false
//        assert($0.alarms.isEmpty == true)
//      }),
//      Step(.receive, .alarmsCollection(.loadAlarmsCollectionResponse(expectedResult)), { result in
//        result.isLoading = false
//        result.alarms = self.expectedResult
//
//        //assertSnapshot(matching: scene, as: .image)
//      }),
//      Step(.send, .alarmsCollection(.select(selected)), { result in
//        result.selectedAlarm = self.selected
//      }),
//      Step(.send, .alarmView(.alarmView(.title("update noon"))), { result in
//        result.selectedAlarm?.title = "update noon"
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.saveResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      })
//    )
//  }
//
//  func test_update_enabled_success() {
//    let scene = Scene<AlarmsCollectionViewController>().render()
//
//    let updated = selected |> Alarm.enabledLens *~ false
//
//    expectedResult.append(selected)
//
//    let expectedResultUpdated = [
//      Alarm.morningStar,
//      updated
//    ]
//
//    let detailEnvironment: AlarmFeatureEnvironment = (
//      update: { _ in .just(true) },
//      schedule: { _ in .just(true) },
//      removeSchedule: { _ in .just(true) }
//    )
//
//    let collectionEnvironment: AlarmsCollectionEnvironment = (
//      load: { .sync { self.expectedResult } },
//      save: { _ in }
//    )
//
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    scene.store = store
//
//    assert(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment,
//      steps:
//      Step(.send, .alarmsCollection(.load), {
//        $0.isLoading = false
//        assert($0.alarms.isEmpty == true)
//      }),
//      Step(.receive, .alarmsCollection(.loadAlarmsCollectionResponse(expectedResult)), { result in
//        result.isLoading = false
//        result.alarms = self.expectedResult
//      }),
//      Step(.send, .alarmsCollection(.select(selected)), { result in
//        result.selectedAlarm = self.selected
//      }),
//      Step(.send, .alarmView(.alarmView(.enable(false))), { result in
//        result.selectedAlarm?.enabled = false
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.saveResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.removeResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      })
//    )
//  }
//
//  func test_update_day_success() {
//    let scene = Scene<AlarmsCollectionViewController>().render()
//
//    let updated = selected |> Alarm.daysLens *~ [0]
//
//    expectedResult.append(selected)
//
//    let expectedResultUpdated = [
//      Alarm.morningStar,
//      updated
//    ]
//
//    let detailEnvironment: AlarmFeatureEnvironment = (
//      update: { _ in .just(true) },
//      schedule: { _ in .just(true) },
//      removeSchedule: { _ in .just(true) }
//    )
//
//    let collectionEnvironment: AlarmsCollectionEnvironment = (
//      load: { .sync { self.expectedResult } },
//      save: { _ in }
//    )
//
//    let environment: AppEnvironment = (
//      collection: collectionEnvironment,
//      detail: detailEnvironment
//    )
//
//    let store: Store<AlarmsCollectionViewState, AlarmsCollectionViewAction> = Store(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment
//    )
//
//    scene.store = store
//
//    assert(
//      initialValue: state,
//      reducer: alarmsCollectionViewReducer,
//      environment: environment,
//      steps:
//      Step(.send, .alarmsCollection(.load), {
//        $0.isLoading = false
//        assert($0.alarms.isEmpty == true)
//      }),
//      Step(.receive, .alarmsCollection(.loadAlarmsCollectionResponse(expectedResult)), { result in
//        result.isLoading = false
//        result.alarms = self.expectedResult
//      }),
//      Step(.send, .alarmsCollection(.select(selected)), { result in
//        result.selectedAlarm = self.selected
//      }),
//      Step(.send, .alarmView(.alarmView(.toggleDay(1))), { result in
//        result.selectedAlarm = Alarm.noon |> Alarm.daysLens *~ [0]
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.saveResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.removeResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      }),
//      Step(.receive, .alarmView(.alarmView(.scheduleResponse(true))), { result in
//        result.alarms = expectedResultUpdated
//      })
//    )
//  }
//}
