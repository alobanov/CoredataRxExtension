//
//  DatabaseSyncRxTests.swift
//  DatabaseSyncRxTests
//
//  Created by Lobanov Aleksey on 15/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import DatabaseSyncRx

class DatabaseSyncRxTests: XCTestCase {
  
  let provider = CoredataConfigurator.shared.queryProvider
  let bag = DisposeBag()
  
  var scheduler: TestScheduler!
  var subscription: Disposable!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    scheduler = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    scheduler.scheduleAt(1000) {
      self.subscription.dispose()
    }
    super.tearDown()
  }
  
  func testNestedMapping() {
    // load josn
    let enemiesDictionary: DictionaryAnyObject = JSONReader.readFromJSON("enemies") ?? [:]
    let heroesDictionary: DictionaryAnyObject = JSONReader.readFromJSON("heroes") ?? [:]
    
    // parsing enemies
    let enemies = Observable.just(enemiesDictionary)
      .mapDictionaryToArrayEntities(EnemyEntity.self, nodePath: ["data"], databaseMapper: provider)
    
    // parsing heroes
    let heroes = Observable.just(heroesDictionary)
      .mapDictionaryToArrayEntities(HeroEntity.self, nodePath: ["data"], databaseMapper: provider)
    
    // common predicate
    let all = NSPredicate(value: true)
    
    // perform both parsing signals
    Observable.zip(enemies, heroes)
      .map({ (_, _) in
        guard let heroes: [HeroModel] = self.provider.models(type: HeroEntity.self, predicate: all, sortBy: "id", asc: true) else {
          throw NSError.define(description: "Model not found in database")
        }
        
        guard let enemies: [EnemyModel] = self.provider.models(type: EnemyEntity.self, predicate: all, sortBy: "id", asc: true) else {
          throw NSError.define(description: "Model not found in database")
        }
        
        // check
        XCTAssertEqual(3, heroes.count)
        XCTAssertEqual(4, enemies.count)
      })
      .subscribe(onError: { error in
        XCTFail(error.localizedDescription)
      }).addDisposableTo(bag)
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    let expect = expectation(description: #function)
    var result = ""
    
    let abilitiesDictionary: DictionaryAnyObject = JSONReader.readFromJSON("abilities") ?? [:]
    
    let pred = NSPredicate(format: "id == \(2)")
    
    Observable.just(abilitiesDictionary)
      .mapDictionaryToArrayEntities(AbilityEntity.self, nodePath: ["data"], databaseMapper: provider)
      .map({ _ in
        guard let model: AbilityModel = self.provider.firstModel(type: AbilityEntity.self, predicate: pred) else {
          throw NSError.define(description: "Model not found in database")
        }
        
        result = model.name ?? ""
        expect.fulfill()
      }).subscribe(onError: { error in
        XCTFail(error.localizedDescription)
      }).disposed(by: bag)
    
    provider.clean(doNotDeleteEntities: []).subscribe(onError: { error in
      XCTFail("Fail clean database")
    }).disposed(by: bag)
    
    waitForExpectations(timeout: 1.0) { error in
      guard error == nil else {
        XCTFail(error!.localizedDescription)
        return
      }
      
      // 5
      XCTAssertEqual("Реактивная адаптация", result)
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}

