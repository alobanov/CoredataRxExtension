//
//  DeleteOperation.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import Sync
import RxSwift
import CoreData

public class DeleteArrayOperation<T: NSManagedObject>: AsyncOperation {
  typealias ManageObject = T
  let dataStack: DataStack
  let ids: [Any]
  
  init(ids:[Any], dataStack: DataStack) {
    self.ids = ids
    self.dataStack = dataStack
    super.init()
  }
  
  override public func main() {
    run()
  }
  
  func run() {
    //    logger.info(" === Start save array: \(entetyName)")
    dataStack.performInNewBackgroundContext({ [weak self]  context in
      guard let sSelf = self else {
        return
      }
      do {
        let entityName = String(describing: ManageObject.self)
        for id in sSelf.ids {
          try Sync.delete(id, inEntityNamed: entityName, using: context)
        }
        if let block = sSelf.completion {
          block(nil)
        }
        sSelf.cancel()
      } catch let(err) {
        if let block = sSelf.completion {
          block(err as NSError)
        }
        sSelf.cancel()
      }
    })
  }
}
