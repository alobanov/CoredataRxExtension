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
import RxDBSync
@testable import RxDataBaseSync

class DatabaseSyncRxTests: XCTestCase {
  
  let coredataConfigurator  = CoredataConfigurator(name: "DatabaseSyncRx")
  var provider: CoredataProvider!
  let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    provider = coredataConfigurator.queryProvider
  }
  
  override func tearDown() {
    super.tearDown()
    self.provider.clean(doNotDeleteEntities: []).subscribe().disposed(by: bag)
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
      .map({ [weak self] _ in
        guard let heroes: [HeroModel] = self?.provider.models(type: HeroEntity.self,
                                                              predicate: all, sortBy: "id", asc: true) else {
          throw NSError.define(description: "Model not found in database")
        }
        
        guard let enemies: [EnemyModel] = self?.provider.models(type: EnemyEntity.self,
                                                                predicate: all, sortBy: "id", asc: true) else {
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
    
    waitForExpectations(timeout: 1.0) { error in
      guard error == nil else {
        XCTFail(error!.localizedDescription)
        return
      }
      
      if let ab: [AbilityModel] = self.provider.models(type: AbilityEntity.self, predicate: NSPredicate(value: true)) {
        XCTAssertEqual(5, ab.count)
      } else {
        XCTFail("Ability not founds")
      }
      
      XCTAssertEqual("Реактивная адаптация", result)
    }
  }
}

