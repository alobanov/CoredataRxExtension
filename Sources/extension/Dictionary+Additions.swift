//
//  Dictionary+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Dictionary {
  func find<T>(by path: [JSONSubscriptType]) throws -> T {
    let json = JSON(self)
    if let d = json[path].object as? T {
      return d
    } else {
      throw NSError.define(description: "Can`t find \(path). It`s empty or is not an Object")
    }
  }
}
