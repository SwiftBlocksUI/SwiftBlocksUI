//
//  URLHelper.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.URLQueryItem
import struct Foundation.URLComponents

extension URL {
  
  func urlByAddingQueryParameters(_ items: [ URLQueryItem ]) -> URL? {
    guard !items.isEmpty else { return self }
    
    guard var uc = URLComponents(url: self, resolvingAgainstBaseURL:true) else {
      assertionFailure("could not parse URL: \(self)")
      return nil
    }
    
    if let oldqi = uc.queryItems { uc.queryItems = oldqi + items }
    else                         { uc.queryItems = items         }
    
    return uc.url
  }
}
