// swift-tools-version:5.1

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
             from: "0.5.5"),
    .package(url: "https://github.com/Macro-swift/MacroExpress.git",
             from: "0.5.4"),
    .package(url: "https://github.com/Macro-swift/MacroApp.git",
             from: "0.5.0"),
    .package(url: "https://github.com/apple/swift-nio.git",
             from: "2.20.2"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.1.1"),
    .package(url: "https://github.com/apple/swift-log.git",
             from: "1.4.0")
  ],
  
  targets: [
    .target(name: "SlackBlocksModel", dependencies: [] ),
    .target(name: "SlackClient",      dependencies: [ "SlackBlocksModel" ] ),
    .target(name: "Blocks",
            dependencies: [ "SlackBlocksModel", "Runtime", 
                            "NIO", // a hack to get access to CNIOSHA1
                            "Logging" ] ),
    
    .target(name: "BlocksExpress",    
            dependencies: [ "Blocks", "MacroExpress" ] ),

    .target(name: "SwiftBlocksUI",    
            dependencies: [ "SlackBlocksModel", "SlackClient",
                            "Blocks", "BlocksExpress",
                            "Macro",  "Runtime",
                            "MacroExpress", "MacroApp" ] ),

    .testTarget(name: "SwiftBlocksUITests",
                dependencies: [ "SwiftBlocksUI", "MacroTestUtilities" ])
  ]
)
