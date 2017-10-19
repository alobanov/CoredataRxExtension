//
//  CoredataFetcher.swift
//  DatabaseSyncRxTests
//
//  Created by Lobanov Aleksey on 19/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxDatabaseSync
@testable import DatabaseSyncRx

class CoredataFetcher: XCTestCase {
  
  let coredataConfigurator  = CoredataConfigurator(name: "DatabaseSyncRx")
  var provider: CoredataProvider!
  let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    provider = coredataConfigurator.queryProvider
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    provider.clean(doNotDeleteEntities: []).subscribe().disposed(by: bag)
  }
  
  func testFetch() {
    let expect = expectation(description: #function)
    
    // load josn
    let heroesDictionary: DictionaryAnyObject = JSONReader.readFromJSON("heroes") ?? [:]
    
    // parsing heroes
    Observable.just(heroesDictionary)
      .mapDictionaryToArrayEntities(HeroEntity.self, nodePath: ["data"], databaseMapper: provider)
      .subscribe(onNext: { _ in
        expect.fulfill()
      }, onError: { error in
        XCTFail(error.localizedDescription)
      }).addDisposableTo(bag)
    
    waitForExpectations(timeout: 1) { error in
      guard error == nil else {
        XCTFail(error!.localizedDescription)
        return
      }
      
      let pred = NSPredicate(format: "id == 3")
      
      guard let hero: HeroModel = self.provider.firstModel(type: HeroEntity.self, predicate: pred) else {
        XCTFail("No hero :(")
        return
      }
      
      // Запрос всех злодеев с которыми сражается найденый герой
      let pred1 = NSPredicate(format: "SUBQUERY(heroes, $m, ANY $m.id IN %@).@count > 0", [hero.id])
      if let enemies: [EnemyModel] = self.provider.models(type: EnemyEntity.self, predicate: pred1, sortBy: "name", asc: true) {
        let first = enemies[0]
        XCTAssertEqual(first.name ?? "", "Танос")
        XCTAssertEqual(first.id, 3)
        XCTAssertEqual(first.abilities?.count ?? 0, 2)
        
        let second = enemies[1]
        XCTAssertEqual(second.name ?? "", "Харли Квинн")
        XCTAssertEqual(second.id, 4)
        XCTAssertEqual(second.abilities?.count ?? 0, 2)
        XCTAssertEqual(second.universe?.name ?? "", "DC")
      } else {
        XCTFail("Cant find enemies for \(hero.name ?? "") :(")
      }
    }
  }
  
}

