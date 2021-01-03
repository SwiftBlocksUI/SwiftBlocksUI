//
//  PickerTests.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import XCTest
@testable import SwiftBlocksUI
@testable import SlackBlocksModel
@testable import Blocks

final class PickerTests: XCTestCase {

  struct ClipItView: Blocks {

    var body: some Blocks {
      View {
        Picker("Importance", placeholder: "Select importance") {
          "High 💎💎✨".id("high")
        }
        .actionID("importance_id")
        
        Submit()
      }
      .title("Save it to ClipIt!")
    }
  }

  func testModalPickerGeneration() throws {
    let ctx = BlocksContext()
    ctx.surface = .modal
    
    try ctx.render(ClipItView())
    XCTAssertTrue(ctx.blocks.isEmpty) // should be in view!
    XCTAssertNotNil(ctx.view)
    
    let result = ctx.view?.blocks ?? []
    defer { dump(result) }
    
    print("RESULT:", ctx)

    XCTAssertEqual(result.count, 1)
    guard result.count >= 1 else { return }
    
    guard case .input(let input) = result[0] else {
      XCTAssert(false, "first element is not an Input!")
      return
    }
    guard case .staticSelect(let select) = input.element else {
      XCTAssert(false, "Input element is not a static select!")
      return
    }
    
    XCTAssertFalse(select.actionID.id.isEmpty)
    XCTAssertEqual(select.placeholder, "Select importance")
    XCTAssertNil(select.initialOptions)
    XCTAssertNil(select.optionGroups)
    XCTAssertNil(select.maxSelectedItems)
    XCTAssertNil(select.confirm)
    
    XCTAssertNotNil(select.options)
    XCTAssertEqual(select.options.count, 1)
    guard let option = select.options.first else { return }
    
    XCTAssertNil(option.infoText)
    XCTAssertNil(option.url)
    
    XCTAssertEqual(option.value, "high") // TBD
    XCTAssertEqual(option.text.type, .plain(encodeEmoji: false))
    XCTAssertEqual(option.text.value, "High 💎💎✨")
  }
  
  
  // MARK: - Helpers

  private func dump(_ blocks: [ Block ]) {
    // there actually is a good default dump() global func ...
    print("RESULT:", blocks)
    
    do {
      let data = try JSONEncoder().encode(blocks)
      if let s = String(data: data, encoding: .utf8) {
        print("JSON:", s)
      }
      else {
        XCTAssert(false)
      }
    }
    catch {
      XCTAssertNil(error)
    }
  }

  // MARK: - Registry

  static var allTests = [
    ( "testModalPickerGeneration" , testModalPickerGeneration )
  ]
}
