import Foundation
import RxSwift
import SwiftyJSON
import ObjectMapper

public struct DummyModel: Mappable {
  public init?(map: Map) {}
  
  // Mappable
  public mutating func mapping(map: Map) {}
}

public extension Observable {
  private func ids<K>(array: DictionaryArray, key: String, idType: K.Type) -> [K] {
    var ids: [K] = []
    for dict in array {
      if let value = dict[key] as? K {
        ids.append(value)
      }
    }
    
    return ids
  }
  
  func mapIdsFromDictionaryArray<K>(keyType: K.Type, primaryKey: String) -> Observable<[K]> {
    return map { representor in
      guard let json = representor as? DictionaryArray else {
        throw NSError.define(description: "Can`t cast to array of dictionary")
      }
      
      return self.ids(array: json, key: primaryKey, idType: keyType)
    }
  }
  
  func mapDictionaryToArrayEntities<U: NSManagedObjectMappable>(_ type: U.Type, nodePath: [JSONSubscriptType]? = nil, databaseMapper: CoredataMappable & CoredataFetcher) -> Observable <Void> {
    return mapDictionaryToArrayEntities(type, nodePath: nodePath, databaseMapper: databaseMapper, primaryKey: nil, primaryKeyType: Int.self).mapToVoid()
  }
  
  func mapDictionaryToArrayEntities<U: NSManagedObjectMappable, K>(_ type: U.Type, nodePath: [JSONSubscriptType]? = nil, databaseMapper: CoredataMappable & CoredataFetcher, primaryKey: String?, primaryKeyType: K.Type) -> Observable <[K]>
  {
    return
      observeOn(DBSchedulers.shared.backgroundScheduler)
      .transformDictionaryToArray(nodePath: nodePath)
      .flatMap { list -> Observable<[K]> in
        return
          databaseMapper
            .mapArray(type, jsonArray: list)
            .flatMap { _ -> Observable<[K]> in
            
              guard let key = primaryKey else {
                return Observable<[K]>.just([])
              }
              
              return Observable<DictionaryArray>.just(list).mapIdsFromDictionaryArray(keyType: primaryKeyType, primaryKey: key)
            }
      }.observeOn(DBSchedulers.shared.mainScheduler)
  }
  
  
  /// Save entity from dictionary by type
  ///
  /// - Parameters:
  ///   - type: Type of `NSManagedObjectMappable`, ex. `PetEntity.self`
  ///   - databaseMapper: Instance of CoredataProvider
  /// - Returns: Observable <Void>
  func mapDictionaryToEntity<U: NSManagedObjectMappable>(_ type: U.Type, databaseMapper: CoredataMappable & CoredataFetcher) -> Observable<Void> {
    return mapDictionaryToEntity(type, mappableType: DummyModel.self, databaseMapper: databaseMapper, primaryKey: nil, primaryKeyType: Int.self).mapToVoid()
  }
  
  func mapDictionaryToEntity<T: Mappable, U: NSManagedObjectMappable, K>(_ type: U.Type, mappableType: T.Type, databaseMapper: CoredataMappable & CoredataFetcher, primaryKey: String?, primaryKeyType: K.Type) -> Observable <T?>
  {
    return observeOn(DBSchedulers.shared.backgroundScheduler)
      .flatMap { json -> Observable<T?> in
        guard let json = json as? DictionaryAnyObject else {
          throw NSError.define(description: "Can`t unwrap dictionary")
        }
        
        return databaseMapper.mapObject(type, json: json)
          .flatMap { _ -> Observable <T?> in
              guard let key = primaryKey else {
                return Observable<T?>.just(nil)
              }
              
              return Observable<DictionaryArray>
                .just([json])
                .mapIdsFromDictionaryArray(keyType: primaryKeyType, primaryKey: key)
                .map({ ids -> T? in
                  guard !ids.isEmpty, let id = ids.first else {
                    return nil
                  }
                  
                  let predicate = NSPredicate(format: "\(key) = \(id)")
                  return databaseMapper.firstModel(type: U.self, predicate: predicate)
                })
            }
      }.observeOn(DBSchedulers.shared.mainScheduler)
  }
}
