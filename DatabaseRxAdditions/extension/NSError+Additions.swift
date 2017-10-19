//
//  NSError+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 19/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

extension NSError {
  static func define(description: String, failureReason: String = "", code: Int = 1) -> NSError {
    let userInfo = [
      NSLocalizedDescriptionKey: description,
      NSLocalizedFailureReasonErrorKey: failureReason
    ]
    
    return NSError(domain: DatabaseRxConstant.domain, code: code, userInfo: userInfo)
  }
}
