import Foundation

extension Sequence {
  func sorted<Value>(
    by keyPath: KeyPath<Element, Value>,
    using isIncrease: (Value, Value) throws -> Bool) rethrows -> [Element] {
    try self.sorted{try isIncrease($0[keyPath: keyPath], $1[keyPath: keyPath])}
  }
  
  func sorted<Value: Comparable>(
    by keyPath: KeyPath<Element, Value>) -> [Element] {
    self.sorted(by: keyPath, using: <)
  }
}
