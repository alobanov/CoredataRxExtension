//
//  AbilityEntity+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import RxDBSync

extension AbilityEntity: NSManagedObjectMappable {
  
  struct Fields {
    static let id = "id"
  }
  
  struct Relations {
    static let heroes = "characters"
  }
  
  public static func map<T:NSManagedObjectMappable>(type:T.Type, object: JSONDictionary, context: NSManagedObjectContext) -> Observable<T> {
    let mapper = EntityMapper<T>(context: context, object: object)
    return mapper.mapSelf().mapToType(type: T.self)
  }
}
