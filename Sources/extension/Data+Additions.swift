//
//  Data+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Data {
  
  /// Transform Data to DictionaryAnyObject = [String: AnyObject]
  ///
  /// - Returns: DictionaryAnyObject = [String: AnyObject]
  /// - Throws: Error serialization failed
  func toJSON() throws -> DictionaryAnyObject? {
    guard let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? DictionaryAnyObject else {
      throw NSError.define(description: "Data could`t serialized to Dictionary")
    }
    
    return json
  }
}
