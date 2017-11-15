//
//  ViewController.swift
//  RxDataBaseSync
//
//  Created by Lobanov Aleksey on 20/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

extension NSManagedObject {
  public func enCode(store: [String: Int]? = nil) -> [String: Any] {
    var rs = [String: Any]()
    var storeV = store ?? [:]
    
    for property in entity.properties {
      if let v = value(forKey: property.name) {
        
        // 1 - 1
        if let m = v as? NSManagedObject {
          
          
          
          
          
          rs[property.name] = m.enCode(store: storeV)
        } else
          // 1 - many
          if let m = v as? NSSet {
            
            if var count = storeV[property.name] {
              count+=1
              storeV[property.name] = count
            } else {
              storeV[property.name] = 1
            }
            
            if storeV[property.name] ?? 0 > 2 {
              return [:]
            }
            
            var rs1 = [[String: Any]]()
            for i in m {
              if let o = i as? NSManagedObject {
                rs1.append(o.enCode(store: storeV))
              }
            }
            rs[property.name] = rs1
        } else {
            // single
          rs[property.name] = value(forKey: property.name)
        }
      }
    }
    return rs
  }
}
