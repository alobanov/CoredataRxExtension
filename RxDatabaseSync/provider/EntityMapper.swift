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

public protocol NSManagedObjectMappable where Self:NSManagedObject {
  static func map<T:NSManagedObjectMappable>(type:T.Type, object: JSONDictionary, context: NSManagedObjectContext) -> Observable<T>
}

public class EntityMapper<Parent: NSManagedObjectMappable> {
  private var context: NSManagedObjectContext
  private var object: JSONDictionary = [:]
  private var objects: JSONArrayDictionary = []
  
  public init(context: NSManagedObjectContext, object: JSONDictionary) {
    self.context = context
    self.object = object
  }
  
  public init(context: NSManagedObjectContext, objects: JSONArrayDictionary) {
    self.context = context
    self.objects = objects
  }
  
 public func mapRelationToOne<T: NSManagedObjectMappable>(relation: String, type: T.Type) -> Observable<T?>  {
    guard let relationKey = syncRelationKey(type: Parent.self, relation: relation) else {
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
  
  public func mapRelationToMany<T: NSManagedObjectMappable>(relation: String, type: T.Type) -> Observable<[T]?>  {
    var mapping: Observable<[T]?>
    guard let relationKey = syncRelationKey(type: Parent.self, relation: relation) else {
      return Observable.just(nil)
    }
    if let relationArr = object[relationKey] as? JSONArrayDictionary {
      object[relationKey] = nil
      let mapper = EntityMapper<Parent>(context: context, objects: relationArr)
      mapping = mapper.mapArray(type: T.self).mapToType(type: [T]?.self) // T.mapArray(relationArr, type: T.self, context: context).mapToType(type: [T]?.self)
    } else {
      mapping = Observable.just(nil)
    }
    return mapping
  }
  
  public func mapObject<T:NSManagedObjectMappable>(type: T.Type) -> Observable<T> {
    return Observable<T>.create({ observer -> Disposable in
      let entityName = String(describing: T.self)
      do {
        let result: T? = try self.context.insertOrUpdate(self.object, inEntityNamed: entityName)
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
  
  public func mapArray<U: NSManagedObjectMappable>(type: U.Type) -> Observable<[U]> {
    var operations = [Observable<U>]()
    for obj in objects {
      let operation: Observable<U> = U.map(type: U.self, object: obj, context: context)
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
