import XCTest
@testable import Tree

class AssetTest: XCTestCase {
  func assertColor(_ color: String) {
    XCTAssertNotNil(UIColor(named: color),
                    "Failed to load color '\(color)' from asset catalog.")
  }
  
  func testTagColorsExist() {
    for color in Tag.colors {
      assertColor(color)
    }
  }
  
  func testUIColorsExist() {
    let uiColors = ["UIBackground", "UIBrown", "UIForeground", "UIGreen",
                    "UILightGreen", "UIOrange", "UIRed"]
    for color in uiColors {
      assertColor(color)
    }
  }
}
