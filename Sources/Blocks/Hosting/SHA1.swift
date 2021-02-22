//
//  SHA1.swift
//  Blocks
//
//  Created by Helge Heß.
//  Copyright © 2020-2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data

extension String {
  
  @usableFromInline
  func sha1Base64() -> String { // fixme, directly hash into Data
    return Data(sha1Hash()).base64EncodedString()
  }
}

#if false && canImport(CNIOSHA1) // not available anymore since NIO 2.26.0
  // NIO does not export this as a product, but we can still use it :->
  import CNIOSHA1
  #if canImport(Glibc)
    import func Glibc.strlen
  #elseif canImport(Darwin)
    import func Darwin.strlen
  #endif

  extension String {
    @usableFromInline
    func sha1Hash() -> [ UInt8 ] {
      var ctx = CNIOSHA1.SHA1_CTX()
      c_nio_sha1_init(&ctx)
      
      withCString { ( cstr: UnsafePointer<Int8> ) in
        let len = strlen(cstr)
        cstr.withMemoryRebound(to: UInt8.self, capacity: len) { cstrU in
          c_nio_sha1_loop(&ctx, cstrU, len)
        }
      }
      
      var hash = Array<UInt8>(repeating: 0, count: 20)
      hash.withUnsafeMutableBufferPointer { mbp in
        mbp.withMemoryRebound(to: Int8.self) { mbpU in
          c_nio_sha1_result(&ctx, mbpU.baseAddress!)
        }
      }
      return hash
    }
  }
#elseif canImport(CryptoKit)
  import CryptoKit

  extension String {
    @usableFromInline
    func sha1Hash() -> [ UInt8 ] {
      guard let utf8 = data(using: .utf8) else { return [] } // TBD
      let hash = Insecure.SHA1.hash(data: utf8)
      return Array(hash)
    }
  }
#elseif canImport(Crypto)
  // I don't really want to pull in BoringSSL unless required. We usually will
  // use NIO anyways.
  // Would be: "https://github.com/apple/swift-crypto.git", from: "1.0.2"
  import Crypto

  extension String {
    @usableFromInline
    func sha1Hash() -> [ UInt8 ] {
      guard let utf8 = data(using: .utf8) else { return [] } // TBD
      let hash = Insecure.SHA1.hash(data: utf8)
      return Array(hash)
    }
  }
#else
  #error("no SHA1 implementation available")
#endif // CNIOSHA1

