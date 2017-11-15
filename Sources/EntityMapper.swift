//
//  NSManagedObject+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import Sync

/// NSManagedObjectMappable

public protocol NSManagedObjectMappable where Self:NSManagedObject {
  static func map<T:NSManagedObjectMappable>(type:T.Type, object: JSONDictionary, context: NSManagedObjectContext) -> Observable<T>
}

/// EntityMapper, provide methods for parsing and saving entities and it relations
/// ```swift
/// let mapper = EntityMapper<T>(context: context, object: object)
///
/// let mapHero = mapper.mapRelationToMany(relation: Relations.hero, type: HeroEntity.self)
/// let mapAbilities = mapper.mapRelationToMany(relation: Relations.abilities, type: AbilityEntity.self)
/// let mapUniverse = mapper.mapRelationToOne(relation: Relations.universe, type: UniverseEntity.self)
/// let mapSelf = mapper.mapSelf().mapToType(type: self.self)
/// ```
public class EntityMapper<BaseType: NSManagedObjectMappable> {
  private var context: NSManagedObjectContext
  private var object: JSONDictionary = [:]
  private var objects: JSONArrayDictionary = []
  
  // MARK: Initialization
  
  /// Initialization of EntityMapper with Context and Dictionary
  ///
  /// - Parameters:
  ///   - context: NSManagedObjectContext
  ///   - object: JSONDictionary = [String: Any]
  public init(context: NSManagedObjectContext, object: JSONDictionary) {
    self.context = context
    self.object = object
  }
  
  // Initialization of EntityMapper with Context and  Array of Dictionary
  ///
  /// - Parameters:
  ///   - context: NSManagedObjectContext
  ///   - object: JSONArrayDictionary = [[String: Any]]
  public init(context: NSManagedObjectContext, objects: JSONArrayDictionary) {
    self.context = context
    self.objects = objects
  }
  
  // MARK: - Map relations
  
  /// Map self object relation by node name "to-One"
  ///
  /// - Parameters:
  ///   - relation: String: Node relation name
  ///   - type: Entity `NSManagedObjectMappable` type, for example: `PetEntity.self`
  /// - Returns: Optional observable of `T: NSManagedObjectMappable`
  public func mapRelationToOne<T: NSManagedObjectMappable>(relation: String, type: T.Type) -> Observable<T?>  {
    guard let relationKey = syncRelationKey(type: BaseType.self, relation: relation) else {
      return Observable.just(nil)
    }
    var mapping: Observable<T?>
    if let relationObj = object[relationKey] as? JSONDictionary {
      object[relationKey] = nil
      mapping = T.map(type: T.self, object: relationObj, context: context).mapToType(type: T?.self)
    } else {
      mapping = Observable.just(nil)
    }
    return mapping
  }
  
  /// Map self object relation by node name `to-Many`
  ///
  /// - Parameters:
  ///   - relation: String: Node relation name
  ///   - type: Entity `NSManagedObjectMappable` type, for example: `PetEntity.self`
  /// - Returns: Optional observable of `T: NSManagedObjectMappable`
  public func mapRelationToMany<T: NSManagedObjectMappable>(relation: String, type: T.Type) -> Observable<[T]?>  {
    var mapping: Observable<[T]?>
    guard let relationKey = syncRelationKey(type: BaseType.self, relation: relation) else {
      return Observable.just(nil)
    }
    if let relationArr = object[relationKey] as? JSONArrayDictionary {
      object[relationKey] = nil
      let mapper = EntityMapper<BaseType>(context: context, objects: relationArr)
      mapping = mapper.mapArray(type: T.self).mapToType(type: [T]?.self)
    } else {
      mapping = Observable.just(nil)
    }
    return mapping
  }
  
  // MARK: Self Mapping
  
  /// Save self object
  ///
  /// - Returns: Observable of self generic class type
  public func mapSelf() -> Observable<BaseType> {
    return Observable<BaseType>.create({ observer -> Disposable in
      let entityName = String(describing: BaseType.self)
      do {
        let result: BaseType? = try self.context.insertOrUpdate(self.object, inEntityNamed: entityName)
        if let result = result {
          observer.onNext(result)
          observer.onCompleted()
        } else {
          observer.onError(NSError(domain: "Error", code: 0, userInfo: nil))
        }
      } catch let error {
        observer.onError(error)
      }
      return Disposables.create()
    })
  }
  
  /// Save array
  ///
  /// - Returns: Observable of generic type
  public func mapArray<T: NSManagedObjectMappable>(type: T.Type) -> Observable<[T]> {
    var operations = [Observable<T>]()
    for obj in objects {
      let operation: Observable<T> = T.map(type: T.self, object: obj, context: context)
      operations.append(operation)
    }
    return Observable.merge(operations).toArray()
  }
  
  // MARK: - Private
  
  private func syncRelationKey<T: NSManagedObject>(type: T.Type, relation: String) -> String? {
    let entityName = String(describing: T.self)
    guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context),
      let relationDescription = entity.relationships().flatMap({ item -> NSRelationshipDescription? in
        return item.name == relation ? item : nil
      }).first
      else {
        return nil
    }
    let relationKey = relationDescription.customKey ?? relation.toSnakeCase()
    return relationKey
  }
  
  private func syncPropertyKey<T: NSManagedObject>(type: T.Type, property: String) -> String? {
    let entityName = String(describing: T.self)
    guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context),
      let propertyDescription = entity.attributes().flatMap({ item -> NSAttributeDescription? in
        return item.name == property ? item : nil
      }).first
      else {
        return nil
    }
    let relationKey = propertyDescription.customKey ?? property.toSnakeCase()
    return relationKey
  }
}
