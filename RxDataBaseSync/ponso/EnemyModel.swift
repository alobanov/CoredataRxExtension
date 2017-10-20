//
//  EnemyEntity.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import ObjectMapper

struct EnemyModel: Mappable {
  var id: Int = 0
  var name: String?
  var realName: String?
  var heroes: [HeroModel]?
  var abilities: [AbilityModel]?
  var universe: UniverseModel?
  
  init?(map: Map) {}
  
  // Mappable
  mutating func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    realName <- map["real_name"]
    heroes <- map["heroes"]
    abilities <- map["abilities"]
    universe <- map["universe"]
  }
}
