// swift-tools-version:5.3

import PackageDescription

let package = Package(
  
  name: "SwiftBlocksUI",

  platforms: [
    .macOS(.v10_15), .iOS(.v13)
  ],
  
  products: [
    .library(name: "SlackBlocksModel", targets: [ "SlackBlocksModel" ]),
    .library(name: "SlackClient",      targets: [ "SlackClient"      ]),
    .library(name: "Blocks",           targets: [ "Blocks"           ]),
    .library(name: "BlocksExpress",    targets: [ "BlocksExpress"    ]),
    .library(name: "SwiftBlocksUI",    targets: [ "SwiftBlocksUI"    ]),
  ],
  
  dependencies: [
    .package(url: "https://github.com/Macro-swift/Macro.git",
             from: "0.8.7"),
    .package(url: "https://github.com/Macro-swift/MacroExpress.git",
             from: "0.8.4"),
    .package(url: "https://github.com/Macro-swift/MacroApp.git",
             from: "0.5.8"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.2.2"),
    .package(url: "https://github.com/apple/swift-log.git",
             from: "1.4.1"),
    .package(url: "https://github.com/apple/swift-crypto.git",
             from: "1.1.4")
  ],
  
  targets: [
    .target(name: "SlackBlocksModel",
            exclude: [ "README.md", "Elements/README.md" ]),
    .target(name: "SlackClient", dependencies: [ "SlackBlocksModel", "Macro" ],
            exclude: [ "README.md" ]),
    .target(name: "Blocks", dependencies: [
      "SlackBlocksModel", "Runtime",
      .product(name: "Crypto",  package: "swift-crypto"),
      .product(name: "Logging", package: "swift-log")
    ], exclude: [ "README.md", "Rendering/README.md", "Blocks/README.md" ]),
    
    .target(name         : "BlocksExpress", 
            dependencies : [ "Blocks", "MacroExpress" ],
            exclude      : [ "README.md" ]),

    .target(name: "SwiftBlocksUI", dependencies: [ 
      "SlackBlocksModel", "SlackClient",
      "Blocks", "BlocksExpress",
      "Macro",  "Runtime", "MacroExpress", "MacroApp"
    ], exclude: [ "README.md", "EndpointActionResponse/README.md" ]),

    .testTarget(name: "SwiftBlocksUITests", dependencies: [
      "SwiftBlocksUI", 
      .product(name: "MacroTestUtilities", package: "Macro")
    ])
  ]
)
