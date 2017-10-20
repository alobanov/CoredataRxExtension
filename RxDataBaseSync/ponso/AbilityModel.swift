//
//  AbilityModel.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import ObjectMapper

struct AbilityModel: Mappable {
  var id: Int = 0
  var name: String?
  var heroes: [HeroModel]?
  
  init?(map: Map) {}
  
  // Mappable
  mutating func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    heroes <- map["heroes"]
  }
}
