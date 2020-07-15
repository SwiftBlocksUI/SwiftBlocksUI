//
//  BlockIDTests.swift
//  SwiftBlocksUITests
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import XCTest
@testable import SwiftBlocksUI
@testable import SlackBlocksModel
@testable import Blocks

final class BlockIDTests: XCTestCase {

  struct CowsBlocks: Blocks {
    @Environment(\.messageText) var q
    var cow : String? { return "Moo" }
    @BlocksBuilder var body : some Blocks {
      if cow != nil {
        RichText {
          Preformatted {
            Text(cow!)
          }
        }
      }
      else {
        RichText {
          Paragraph {
            Text("No such cow:")
              .bold()
            Text(q)
              .code()
          }
        }
        .id("error")
      }
    }
  }
  
  
  // MARK: - Tests
  
  // Note: type strings can change w/ Swift version, this is not guaranteed to
  //       be really unique or stable!
  //       I.e.: those tests can fail.
  
  func testGeneratedIDGenericBlocks() throws {
    let blocks = CowsBlocks()
    let id     = CallbackID.generatedBlockID(for: blocks)
    XCTAssertEqual(id, "wsoY/PgNguMCMbY1OHvDFBvmq3I=")
  }
  
  func testGeneratedIDForNoIDView() throws {
    let blocks = View { CowsBlocks() }
    let id     = CallbackID.generatedBlockID(for: blocks)
    XCTAssertEqual(id, "rV1ux+wf4Ey+pxPrh8rEAFVRBDk=")
  }
  
  func testIDForIDView() throws {
    let blocks = View { CowsBlocks() }.id("MyView")
    let id = CallbackID.blockID(for: blocks)
    XCTAssertEqual(id, "MyView")
  }

  // MARK: - Registry

  static var allTests = [
    ( "testGeneratedIDGenericBlocks" , testGeneratedIDGenericBlocks ),
    ( "testGeneratedIDForNoIDView"   , testGeneratedIDForNoIDView   ),
    ( "testIDForIDView"              , testIDForIDView              ),
  ]
}
