//
//  ViewController.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 15/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import UIKit
import RxSwift

func delay(_ delay: Double, closure: @escaping () -> Void) {
  let when = DispatchTime.now() + delay
  DispatchQueue.main.asyncAfter(deadline: when){
    // Your code with delay
    closure()
  }
}

class ViewController: UIViewController {

  let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.test()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func test() {
    
    let marvel: [String: Any] = ["id": 1, "name": "marvel"]
    let dc: [String: Any] = ["id": 2, "name": "DC"]
    
    let rawAbiliti1: [String: Any] = ["id": 1, "name": "Гениальный уровень интеллекта"]
    let rawAbiliti2: [String: Any] = ["id": 2, "name": "Реактивная адаптация"]
    let rawAbiliti3: [String: Any] = ["id": 3, "name": "Поглощение радиации и темной магии"]
    let rawAbiliti4: [String: Any] = ["id": 4, "name": "Математическое видение мира"]
    let rawAbiliti5: [String: Any] = ["id": 5, "name": "Неизмеримая физическая сила"]
    
    let redSkull: [String: Any] = ["id": 1, "name": "Красный Череп", "real_name": "Иоганн Шмидт", "abilities": [rawAbiliti3], "universe": marvel]
    let venom: [String: Any] = ["id": 2, "name": "Веном", "real_name": "Ли Прайс", "abilities": [rawAbiliti1, rawAbiliti2], "universe": marvel]
    let tanos: [String: Any] = ["id": 3, "name": "Танос", "real_name": "Безумный Титан", "abilities": [rawAbiliti1, rawAbiliti5], "universe": marvel]
    let rawHarleyQuinn: [String: Any] = ["id": 4, "name": "Харли Квинн", "real_name": "Роберт Харлин Фрэнсис Квинзель", "abilities": [rawAbiliti1, rawAbiliti4], "universe": dc]
    
    let rawSpider: [String: Any] = ["id": 1, "name": "Spider-Man", "real_name": "Питер Бенджамин Паркер", "abilities": [rawAbiliti2], "universe": marvel,
                                    "enemies": [venom]]
    let rawCap: [String: Any] = ["id": 2, "name": "Captain America", "real_name": "Стивен Роджерс", "abilities": [rawAbiliti3, rawAbiliti5], "universe": marvel,
                                 "rnemies": [redSkull]]
    let rawHalk: [String: Any] = ["id": 3, "name": "Halk", "real_name": "Роберт Брюс Бэннер", "abilities": [rawAbiliti1, rawAbiliti4], "universe": marvel,
                                  "enemies": [tanos, rawHarleyQuinn]]
    
    let dataprovider = CoredataConfigurator.shared.queryProvider
    
    Observable.just([rawSpider, rawCap, rawHalk])
      .mapDictionaryToArrayEntities(HeroEntity.self, databaseMapper: dataprovider)
      .subscribe(
        onNext: { _ in
          print("success")
      },
        onError: { e in
          print("Fail")
      }).disposed(by: bag)
    
    Observable.just([redSkull, venom, tanos, rawHarleyQuinn])
      .mapDictionaryToArrayEntities(EnemyEntity.self, databaseMapper: dataprovider)
      .subscribe(
        onNext: { _ in
          print("success")
      },
        onError: { e in
          print("Fail")
      }).disposed(by: bag)
    
    let heroes: [HeroModel]? = dataprovider.models(type: HeroEntity.self, predicate: NSPredicate(value: true), sortBy: nil, asc: nil)
    print(heroes?.toJSON() ?? [:])
    
    print("\n\n")
    
    let enemies: [EnemyModel]? = dataprovider.models(type: EnemyEntity.self, predicate: NSPredicate(value: true), sortBy: nil, asc: nil)
    print(enemies?.toJSON() ?? [:])
    
    Observable.just(["id": 1, "name": "Лох 123"])
      .delay(2, scheduler: Schedulers.shared.mainScheduler)
      .mapDictionaryToEntity(HeroEntity.self, mappableType: HeroModel.self, databaseMapper: dataprovider, primaryKey: "id", primaryKeyType: Int.self)
      .subscribe(
        onNext: { hero in
          print("success \n\n")
          print(hero?.toJSON() ?? [:])
        },
        onError: { e in
          print("error")
      }).disposed(by: bag)
    
//    let hero: HeroModel? = dataprovider.firstModel(type: HeroEntity.self, predicate: NSPredicate(format: "id == \(1)"))
    
  }
}

