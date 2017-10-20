//
//  JSONReader.swift
//  Pulse
//
//  Created by MOPC on 27.07.16.
//  Copyright © 2016 MOPC Lab. All rights reserved.
//

import Foundation
import RxDBSync
import ObjectMapper

class JSONReader {

  class func readFromJSON<T: Mappable>(_ filename: String) -> T? {
    return Mapper<T>().map(JSONString: JSONReader.readJSONString(filename)!)
  }
  
  class func readFromJSON(_ filename: String) -> DictionaryAnyObject? {
    do {
      let data = JSONReader.readJSONData(filename)

      guard let result = try JSONSerialization
        .jsonObject(with: data, options: []) as? DictionaryAnyObject else {
          return nil
      }
    
      return result
    } catch {
      return nil
    }
  }

  class func readJSONString(_ filename: String) -> String? {
    return String(data: readJSONData(filename), encoding: String.Encoding.utf8)
  }

  class func readJSONData(_ filename: String) -> Data {
    return FileReader.readFileData(filename, fileExtension: "json")
  }

}
