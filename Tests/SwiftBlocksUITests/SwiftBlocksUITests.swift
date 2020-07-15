//
//  SwiftBlocksUITests.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import XCTest
@testable import SwiftBlocksUI
@testable import SlackBlocksModel
@testable import Blocks

final class SwiftBlocksUITests: XCTestCase {
  
  // MARK: - Modals

  func testTextFieldInModal() throws {
    struct Test: Blocks {
      var body: some Blocks {
        TextField("Title", text: "Hello")
      }
    }

    let ctx = BlocksContext()
    ctx.surface = .modal
    
    try ctx.render(Test())
    XCTAssertTrue(ctx.blocks.isEmpty) // should be in view!
    XCTAssertNotNil(ctx.view)
    
    let result = ctx.view?.blocks ?? []
    defer { dump(result) }
    
    XCTAssertEqual(result.count, 1)
    guard result.count >= 1 else { return }
    
    guard case .input(let input) = result[0] else {
      XCTAssert(false, "first element is not an Input!")
      return
    }
    
    XCTAssertFalse(input.id.id.isEmpty)
    XCTAssertEqual(input.label, "Title")
    XCTAssertNil  (input.hint)
    XCTAssertFalse(input.optional)
    
    guard case .plainText(let plainText) = input.element else {
      XCTAssert(false, "first Input doesn't have a plain text!")
      return
    }
    XCTAssertFalse(plainText.actionID.id.isEmpty)
    XCTAssertEqual(plainText.initialValue, "Hello")
    XCTAssertNil  (plainText.placeholder)
    XCTAssertNil  (plainText.minLength)
    XCTAssertNil  (plainText.maxLength)
    XCTAssertFalse(plainText.multiline)
  }

  func testTextFieldInNonModal() throws {
    // Those used to render a plain text, not anymore
    struct Test: Blocks {
      var body: some Blocks {
        TextField("Title", text: "Hello")
      }
    }

    let ctx = BlocksContext()
    ctx.surface = .message
    
    // Same like testTextFieldInModal, auto-embed
    
    try ctx.render(Test())
    XCTAssertTrue(ctx.blocks.isEmpty) // should be in view!
    XCTAssertNotNil(ctx.view)
    
    let result = ctx.view?.blocks ?? []
    defer { dump(result) }
    
    XCTAssertEqual(result.count, 1)
    guard result.count >= 1 else { return }
    
    guard case .input(let input) = result[0] else {
      XCTAssert(false, "first element is not an Input!")
      return
    }
    
    XCTAssertFalse(input.id.id.isEmpty)
    XCTAssertEqual(input.label, "Title")
    XCTAssertNil  (input.hint)
    XCTAssertFalse(input.optional)
    
    guard case .plainText(let plainText) = input.element else {
      XCTAssert(false, "first Input doesn't have a plain text!")
      return
    }
    XCTAssertFalse(plainText.actionID.id.isEmpty)
    XCTAssertEqual(plainText.initialValue, "Hello")
    XCTAssertNil  (plainText.placeholder)
    XCTAssertNil  (plainText.minLength)
    XCTAssertNil  (plainText.maxLength)
    XCTAssertFalse(plainText.multiline)
  }
  
  func testSimpleForEach() throws {
    struct ListStuff: Blocks {

      let list = [ "Hello", "World", "!" ]
      
      var body: some Blocks {
        ForEach(list, id: \.self) { value in
          Text("Yo \(value)")
        }
      }
    }
    
    let ctx = BlocksContext()
    try ctx.render(ListStuff())
    
    let result = ctx.blocks
    defer { dump(result) }
    
    XCTAssertEqual(result.count, 3)
    guard result.count >= 3 else { return }
    
    try XCTAssertBlock(result[0], againstSingleRichTextRun: "Yo Hello")
    try XCTAssertBlock(result[1], againstSingleRichTextRun: "Yo World")
    try XCTAssertBlock(result[2], againstSingleRichTextRun: "Yo !")
  }

  func testApprovalFormExample() throws {
    struct ApprovalForm: Blocks {
      
      var body: some Blocks {
        Group { // or mark `body` as @BlocksBuilder
          Section {
            Text("You have a new request:\n")
            Link("Fred Enriquez - New device request",
                 destination:
                   URL(string: "http://fakeLink.toEmployeeProfile.com")!)
              .bold()
          }
          Section { // TODO: make it a foreach loop over an array
            Field {
              Text("Type").bold()
              Text("\nComputer (laptop)")
            }
            Field {
              Text("When").bold()
              Text("\nSubmitted Aut 10")
            }
            Field {
              Text("Last Update").bold()
              Text("\nMar 10, 2015 (3 years, 5 months)")
            }
            Field {
              Text("Reason").bold()
              Text("\nAll vowel keys aren't working.")
            }
            Field {
              Text("Specs").bold()
              Text("\n\"Cheetah Pro 15\" - Fast, really fast\"")
            }
          }
          Actions {
            Button("Approve", .primary, value: "click_me_123")
            Button("Deny",    .danger,  value: "click_me_123")
          }
        }
      }
    }

    let ctx = BlocksContext()
    try ctx.render(ApprovalForm())
    
    let result = ctx.blocks
    defer { dump(result) }
    
    XCTAssertEqual(result.count, 3)
    guard result.count >= 3 else { return }
    
    dump(result)
  }
  
  
  // MARK: - Helpers
  
  func XCTAssertBlock(_ block: Block, againstSingleRichTextRun string: String)
         throws
  {
    // TBD: Is there a better way to avoid the case?
    if case .richText(let richText) = block {
      XCTAssertFalse(richText.elements.isEmpty)
      XCTAssertEqual(richText.elements.count, 1)
      guard richText.elements.count > 0 else { return }
      
      if case .section(let runs) = richText.elements[0] {
        XCTAssertEqual(runs.count, 1)
        if case .text(let textString, let style) = runs[0] {
          XCTAssertTrue(style.isEmpty)
          XCTAssertEqual(textString, string)
        }
        else {
          XCTAssert(false, "run is not a text?!")
        }
      }
      else {
        XCTAssert(false, "rich-element is not a section")
      }
    }
    else {
      XCTAssert(false, "element is not a rich text!")
    }
  }
  
  private func dump(_ blocks: [ Block ]) {
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
    ( "testSimpleForEach"       , testSimpleForEach       ),
    ( "testApprovalFormExample" , testApprovalFormExample ),
    ( "testTextFieldInModal"    , testTextFieldInModal    ),
    ( "testTextFieldInNonModal" , testTextFieldInNonModal ),
  ]
}
