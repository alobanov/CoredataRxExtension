//
//  EditOperation.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import Sync
import RxSwift
import CoreData

public class EditOperation: AsyncOperation {
  
  typealias ActionClosure = (_ context: NSManagedObjectContext) -> Observable<Void>
  
  let action: ActionClosure
  let dataStack: DataStack
  
  let bag = DisposeBag()
  
  init(action: @escaping ActionClosure, dataStack: DataStack) {
    self.action = action
    self.dataStack = dataStack
    super.init()
  }
  
  override public func main() {
    run()
  }
  
  func run() {
    dataStack.performBackgroundTask { [weak self] context in
      guard let sSelf = self else {
        return
      }
      sSelf.action(context).subscribe(onNext: { [weak self] in
        guard let sSelf = self else {
          return
        }
        if let block = sSelf.completion {
          do {
            try context.save()
            block(nil)
          } catch let saveError {
            block(saveError as NSError)
          }
        }
        sSelf.cancel()
        }, onError: {[weak self] error in
          guard let sSelf = self else {
            return
          }
          if let block = sSelf.completion {
            block(error as NSError)
          }
          sSelf.cancel()
      }).disposed(by: sSelf.bag)
    }
  }
}
