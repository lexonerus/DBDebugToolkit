// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBDebugToolkit",
    platforms: [.iOS(.v9)],
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
			cSettings: [
				.headerSearchPath("Classes"),
				.headerSearchPath("Classes/BuildInfo"),
				.headerSearchPath("Classes/Categories"),
				.headerSearchPath("Classes/Cells"),
				.headerSearchPath("Classes/Cells/ColorPicker"),
				.headerSearchPath("Classes/Cells/TitleValue"),
				.headerSearchPath("Classes/Chart"),
				.headerSearchPath("Classes/Console"),
				.headerSearchPath("Classes/CrashReports"),
				.headerSearchPath("Classes/CustomActions"),
				.headerSearchPath("Classes/CustomVariables"),
				.headerSearchPath("Classes/Device"),
				.headerSearchPath("Classes/Location"),
				.headerSearchPath("Classes/Menu"),
				.headerSearchPath("Classes/Network"),
				.headerSearchPath("Classes/Network/MainQueueOperation"),
				.headerSearchPath("Classes/Network/RequestModel"),
				.headerSearchPath("Classes/Network/URLProtocol"),
				.headerSearchPath("Classes/Performance"),
				.headerSearchPath("Classes/Performance/Widget"),
				.headerSearchPath("Classes/Resources"),
				.headerSearchPath("Classes/Resources/Cookies"),
				.headerSearchPath("Classes/Resources/CoreData"),
				.headerSearchPath("Classes/Resources/CoreData/Filters"),
				.headerSearchPath("Classes/Resources/Files"),
				.headerSearchPath("Classes/Resources/Keychain"),
				.headerSearchPath("Classes/Resources/UserDefaults"),
				.headerSearchPath("Classes/TopLevelViews"),
				.headerSearchPath("Classes/Triggers"),
				.headerSearchPath("Classes/Triggers/LongPressTrigger"),
				.headerSearchPath("Classes/Triggers/ShakeTrigger"),
				.headerSearchPath("Classes/Triggers/TapTrigger"),
				.headerSearchPath("Classes/UserInterface"),
				.headerSearchPath("Classes/UserInterface/GridOverlay"),
				.headerSearchPath("Classes/UserInterface/Categories")
			]
		)
    ]
)
