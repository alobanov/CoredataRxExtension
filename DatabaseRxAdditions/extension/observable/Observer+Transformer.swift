import Moya
import RxSwift
import ObjectMapper
import SwiftyJSON

public extension Observable {
 func transformResponseToDictionary(nodePath: [JSONSubscriptType]? = nil) -> Observable<DictionaryAnyObject> {
    return map { representor in
      guard let response = representor as? Response else {
        throw NSError.define(description: "Can`t unwrap as 'Moya Responese', check response")
      }
      
      var json: DictionaryAnyObject?
      
      do {
        json = try response.data.toJSON()
      } catch let (error) {
        throw error
      }
      
      guard let unwrapJson = json else {
        throw NSError.define(description: "Server response is empty")
      }
      
      if let path = nodePath {
        do {
          return try unwrapJson.find(by: path)
        } catch let (error){
          throw error
        }
      }
      
      return unwrapJson
    }
  }
  
 func transformDictionaryToArray(nodePath: [JSONSubscriptType]? = nil) -> Observable<DictionaryArray> {
    return map { representor in
      
      if let path = nodePath {
        guard let object = representor as? DictionaryAnyObject else {
          throw NSError.define(description: "Can`t cast to dictionary")
        }
        
        var array: DictionaryArray?
        
        do {
          array = try object.find(by: path)
        } catch let (error) {
          throw error
        }
        
        if let unwrapArray = array {
          return unwrapArray
        } else {
          throw NSError.define(description: "Can`t cast to dictionary")
        }
      } else {
        guard let array = representor as? DictionaryArray else {
          throw NSError.define(description: "Can`t cast to array of dictionary")
        }
        
        return array
      }
    }
  }
}
