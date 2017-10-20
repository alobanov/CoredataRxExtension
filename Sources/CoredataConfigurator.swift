//
//  CoredataConfigurator.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import Sync
import RxDBSync

public class CoredataConfigurator {
  private var coredataStack: DataStack
  
  // MARK: - Initialization
  public init(name: String, inMemory: Bool = false) {
    let dataStackStoreType: DataStackStoreType = inMemory ? .inMemory : .sqLite
    self.coredataStack = DataStack(modelName: name, storeType: dataStackStoreType)
  }
  
  public lazy var queryProvider: CoredataProvider = {
    return CoredataProvider(dataStack: self.coredataStack)
  }()
  
  public func drop(completion: @escaping (NSError?) -> Void) {
    self.coredataStack.drop { error in
      completion(error)
    }
  }
}
