// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBDebugToolkit",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "DBDebugToolkit",
            targets: ["DBDebugToolkit"]),
        .library(
            name: "DBDebugToolkit-Dynamic",
            type: .dynamic,
            targets: ["DBDebugToolkit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DBDebugToolkit",
			dependencies: [],
			publicHeadersPath: "",
			cSettings: [
				.headerSearchPath("Classes")
			]
		)
    ]
)
