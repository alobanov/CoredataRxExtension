//
//  HeroEntity+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import RxDBSync

extension HeroEntity {
  struct Fields {
    static let id = "id"
  }
  
  struct Relations {
    static let enemy = "enemies"
    static let abilities = "abilities"
    static let universe = "universe"
  }
}

extension HeroEntity: NSManagedObjectMappable {
  public static func map<T:NSManagedObjectMappable>(type:T.Type, object: JSONDictionary, context: NSManagedObjectContext) -> Observable<T> {    
    let mapper = EntityMapper<T>(context: context, object: object)
    
    let mapEnemies = mapper.mapRelationToMany(relation: Relations.enemy, type: EnemyEntity.self)
    let mapAbilities = mapper.mapRelationToMany(relation: Relations.abilities, type: AbilityEntity.self)
    let mapUniverse = mapper.mapRelationToOne(relation: Relations.universe, type: UniverseEntity.self)
    
    let mapSelf = mapper.mapObject().mapToType(type: self.self)
    
    return Observable.zip(mapSelf, mapEnemies, mapAbilities, mapUniverse)
      .map({ (hero, mapEnemies, mapAbilities, mapUniverse) -> HeroEntity in
        if let enemies = mapEnemies {
          hero.enemies = NSSet(array: enemies)
        }
        
        if let abilities = mapAbilities {
          hero.abilities = NSSet(array: abilities)
        }
        
        if let universe = mapUniverse {
          hero.universe = universe
        }
        
        return hero
      })
      .mapToType(type: T.self)
  }
}
