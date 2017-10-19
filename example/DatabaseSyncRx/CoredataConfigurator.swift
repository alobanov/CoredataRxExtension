//
//  CoredataConfigurator.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import Sync
import RxDatabaseSync

class CoredataConfigurator {
  
  // Singletone
  static let shared = CoredataConfigurator()
  private lazy var coredataStack = DataStack(modelName: "DatabaseSyncRx")
  
  // MARK: - Initialization
  private init() {
    
  }
  
  lazy var queryProvider: CoredataProvider = {
    return CoredataProvider(dataStack: self.coredataStack)
  }()
  
  func deleteRealm() {
    self.coredataStack.drop()
  }
}
