//
//  SaveArrayOperation.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import Sync
import RxSwift
import CoreData

public class SaveArrayOperation<T: NSManagedObject>: AsyncOperation {
  typealias ManageObject = T
  let json: JSONArrayDictionary
  let dataStack: DataStack
  let options: Sync.OperationOptions
  
  init(jsonArray: JSONArrayDictionary, options: Sync.OperationOptions = .all, dataStack: DataStack) {
    self.json = jsonArray
    self.dataStack = dataStack
    self.options = options
    super.init()
  }
  
  override public func main() {
    save()
  }
  
  func save() {
    let entityName = String(describing: ManageObject.self)
    Sync.changes(json, inEntityNamed: entityName, dataStack: dataStack, operations: options, completion: { [weak self] error in
      if let err = error {
        if let block = self?.completion {
          block(err)
        }
        self?.cancel()
      } else {
        if let block = self?.completion {
          block(nil)
        }
        self?.cancel()
      }
    })
  }
  
}
