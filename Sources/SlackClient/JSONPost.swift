//
//  JSONPost.swift
//  SlackClient
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import struct Foundation.URL
import class  Foundation.JSONEncoder
import class  Foundation.JSONSerialization

#if canImport(FoundationNetworking)
  import struct FoundationNetworking.URLRequest
  import class  FoundationNetworking.HTTPURLResponse
#else
  import struct Foundation.URLRequest
  import class  Foundation.HTTPURLResponse
#endif

#if DEBUG && false
  fileprivate let logOutgoingJSON = true
#else
  fileprivate let logOutgoingJSON = false
#endif


// HTTP Boilerplate
public extension SlackClient {
  
  enum APIError: Swift.Error {
    case couldNotEncodeJSON(Swift.Error)
    case transport(Swift.Error)
    case httpError(status: Int)
    case noValidJSONResponseContent(Data?)
    case slackError(String) // could type this out
  }
  
  typealias ResponseHandler = ( _ error   : APIError?,
                                _ payload : [ String : Any ]) -> Void
  
  /**
   * Post an Encodable object to the given Slack endpoint.
   *
   * It doesn't only check for HTTP errors, but also processes Slack errors
   * in the JSON returned.
   *
   * Example:
   *
   *     api.post(MyView(), to: "views.open") { error, jsonResponse in
   *         ...
   *     }
   */
  func post<E: Encodable>(_ jsonRequest: E, to endpoint: String,
                          yield: @escaping
                                 ( APIError?, [ String : Any ] ) -> Void)
  {
    post(jsonRequest, to: url.appendingPathComponent(endpoint), yield: yield)
  }
  
  /**
   * Post an Encodable object to the given Slack URL.
   *
   * It doesn't only check for HTTP errors, but also processes Slack errors
   * in the JSON returned.
   * 
   * Example:
   *
   *     api.post(MyView(), to: responseURL) { error, jsonResponse in
   *         ...
   *     }
   *
   */
  func post<E: Encodable>(_ jsonRequest: E, to url: URL,
                          yield: @escaping
                                 ( APIError?, [ String : Any ] ) -> Void)
  {
    // TODO: All the rate limiting etc :-)
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("Bearer " + token.value, forHTTPHeaderField: "Authorization")
    req.setValue("application/json; charset=utf-8",
                 forHTTPHeaderField: "Content-Type")

    do {
      let encoder = JSONEncoder()
      if logOutgoingJSON {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      }
      
      let jsonData = try encoder.encode(jsonRequest)
      req.httpBody = jsonData
      
      if logOutgoingJSON {
        let s = String(data: jsonData, encoding: .utf8)!
        print("JSON POST to \(url.absoluteString):\n", s)
      }
    }
    catch {
      return yield(.couldNotEncodeJSON(error), [:])
    }
    
    let task = session.dataTask(with: req) { data, response, error in
      if let error = error { return yield(.transport(error), [:]) }
      
      if let http = response as? HTTPURLResponse {
        guard http.statusCode >= 200 && http.statusCode < 300 else {
          return yield(.httpError(status: http.statusCode), [:])
        }
      }
      
      guard let data = data, !data.isEmpty else {
        return yield(.noValidJSONResponseContent(nil), [:])
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data)
        
        if let jsonDict = json as? [ String : Any] {
          if let ok = jsonDict["ok"] as? Bool, ok {
            return yield(nil, jsonDict)
          }
          else {
            let code = (jsonDict["error"] as? String) ?? "error"
            print("Slack error:", code)
            #if DEBUG
              if let s = String(data: data, encoding: .utf8) {
                print(s)
                print("---")
              }
            #endif
            return yield(.slackError(code), [:])
          }
        }
        else {
          return yield(.noValidJSONResponseContent(data), [:])
        }
      }
      catch {
        print("failed to parse response content JSON:",
              String(data: data, encoding: .utf8) ?? "-")
        return yield(.noValidJSONResponseContent(data), [:])
      }
    }
    task.resume()
  }
}
