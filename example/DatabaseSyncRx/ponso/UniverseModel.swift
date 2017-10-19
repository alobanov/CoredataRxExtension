//
//  UniverseModel.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 18/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import ObjectMapper

struct UniverseModel: Mappable {
  var id: Int = 0
  var name: String?
  
  init?(map: Map) {}
  
  // Mappable
  mutating func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
}
