import RxSwift
import RxCocoa

public extension Observable {
  func mapToVoid() -> Observable<Void> {
    return map({ _ -> Void in return })
  }
  
  func mapToType<T>(type: T.Type) -> Observable<T> {
    return map({ item -> T in
      if let item = item as? T {
        return item
      } else {
        throw NSError.define(description: "Can`t cast to \(T.self) type")
      }
    })
  }
}

