//
//  EnemyEntity+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import RxDatabaseSync

extension EnemyEntity {
  struct Fields {
    static let id = "id"
  }
  
  struct Relations {
    static let hero = "hero"
    static let abilities = "abilities"
    static let universe = "universe"
  }
}

extension EnemyEntity: NSManagedObjectMappable {
  public static func map<T:NSManagedObjectMappable>(type:T.Type, object: JSONDictionary, context: NSManagedObjectContext) -> Observable<T> {
    
    let mapper = EntityMapper<T>(context: context, object: object)
    
    let mapHero = mapper.mapRelationToMany(relation: Relations.hero, type: HeroEntity.self)
    let mapAbilities = mapper.mapRelationToMany(relation: Relations.abilities, type: AbilityEntity.self)
    let mapUniverse = mapper.mapRelationToOne(relation: Relations.universe, type: UniverseEntity.self)
    let mapSelf = mapper.mapObject(type: type).mapToType(type: self.self)
    
    return Observable.zip(mapSelf, mapHero, mapAbilities, mapUniverse)
      .map({ (enemy, mapHero, mapAbilities, mapUniverse) -> EnemyEntity in
        if let heroes = mapHero {
          enemy.heroes = NSSet(array: heroes)
        }
        
        if let abilities = mapAbilities {
          enemy.abilities = NSSet(array: abilities)
        }
        
        if let universe = mapUniverse {
          enemy.universe = universe
        }
        
        return enemy
      })
      .mapToType(type: T.self)
  }
}
