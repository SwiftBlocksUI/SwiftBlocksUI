//
//  SocketModeAppInit.swift
//  BlocksExpress
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Logging
import MacroExpress

public extension Express {
  
  /**
   * Initialize an Express instance w/ a receiver attached.
   *
   *
   *     let socketModeReceiver = SocketModeReceiver(
   *       token: process.env["SLACK_APP_TOKEN"] ?? ""
   *     )
   *     let app = Express(receiver: socketModeReceiver)
   *     app.use { req, res, next in
   *       ...
   *     }
   *     app.start()
   *
   */
  convenience
  init(receiver: SocketModeReceiver, log : Logger? = nil,
       invokingSourceFilePath: StaticString = #file)
  {
    self.init(id: nil, mount: nil, log: log ?? .init(label: "μ.express.app"),
              invokingSourceFilePath: invokingSourceFilePath)
    
    set("receiver", receiver)
    receiver.onRequest(execute: requestHandler)
  }
  
  func start(_ port: Int?, _ host: String = "0.0.0.0", backlog: Int = 512,
              onListening execute: @escaping () -> Void) -> Self
  {
    if let port = port {
      listen(port, host, backlog: backlog, onListening: execute)
    }
    else if let receiver = get("receiver") as? SocketModeReceiver {
      receiver.resume()
    }
    else {
      log.error("Could not start application, neither port nor receiver set/")
    }
    return self
  }
}

public extension ExpressModule {
  
  /**
   * Initialize an Express instance w/ a SocketModeReceiver attached.
   *
   *     let socketModeReceiver = SocketModeReceiver(
   *       token: process.env["SLACK_APP_TOKEN"] ?? ""
   *     )
   *     let app = express(receiver: socketModeReceiver)
   *     app.use { req, res, next in
   *       ...
   *     }
   *     app.start()
   *
   */
  @inlinable
  static func express(invokingSourceFilePath: StaticString = #file,
                      receiver: SocketModeReceiver,
                      middleware: Middleware...) -> Express
  {
    let app = Express(receiver: receiver,
                      invokingSourceFilePath: invokingSourceFilePath)
    middleware.forEach { app.use($0) }
    return app
  }
}
