import XCTest
import SwiftUI
@testable import Tree

class ExtensionTest: XCTestCase {
  func testSequenceKeyPathSortingSelf() {
    let items = [1, 4, 3, 2, 5]
    let sortedItems = items.sorted(by: \.self)
    XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5],
                   "The sorted numbers must be ascending.")
  }
  
  func testSequenceKeyPathSortingCustom() {
    struct S: Equatable {
      let value: String
    }
    
    let a = S(value: "a")
    let b = S(value: "b")
    let c = S(value: "c")
    let items = [c, a, b]
    
    let sortedItems = items.sorted(by: \.value, using: >)
    XCTAssertEqual(sortedItems, [c, b, a],
                   "The reverse sorted characters must be descending.")
  }
  
  func testBindingOnChangeCallsCallback() {
    // Given
    var onChangeCallbackCalled = false
    
    func exampleFunctionToCall() {
      onChangeCallbackCalled = true
    }
    
    var storedValue = ""
    let binding = Binding(
      get: { storedValue },
      set: { storedValue = $0 }
    )
    
    let changedBinding = binding.onChange(exampleFunctionToCall)
    
    // When
    changedBinding.wrappedValue = "test"
    
    // Then
    XCTAssertTrue(onChangeCallbackCalled,
                  "The callback must be run when the binding is changed.")
  }
}
