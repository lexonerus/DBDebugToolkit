# DBDebugToolkit

[![Version](https://img.shields.io/cocoapods/v/DBDebugToolkit.svg?style=flat)](https://cocoapods.org/pods/DBDebugToolkit)
[![License](https://img.shields.io/cocoapods/l/DBDebugToolkit.svg?style=flat)](https://cocoapods.org/pods/DBDebugToolkit)
[![Platform](https://img.shields.io/cocoapods/p/DBDebugToolkit.svg?style=flat)](https://cocoapods.org/pods/DBDebugToolkit)
[![iOS Version](https://img.shields.io/badge/iOS-12.0+-blue.svg)](https://cocoapods.org/pods/DBDebugToolkit)

## Overview

**DBDebugToolkit 1.0.0** is a comprehensive debugging toolkit for iOS developers and QA engineers. It provides an extensive set of debugging tools that can be easily integrated into any iOS project, making development and testing more efficient and productive.

## ✨ New in 1.0.0

- **🔍 Advanced Search**: Full-text search in response/request bodies with highlighting
- **📋 Copy Functionality**: Copy complete response and request bodies to clipboard
- **🎨 UI Improvements**: Fixed navigation bar transparency issues
- **📱 Modern iOS Support**: iOS 12.0+ compatibility with iOS 13+ enhancements
- **⚡ Performance**: Optimized search and improved resource management

## Features

### Network Debugging
- **Request Monitoring**: Track all network requests in real-time
- **Response Inspection**: View complete response bodies with formatting
- **Body Copying**: Copy request/response bodies to clipboard
- **Search & Highlight**: Find specific text in response bodies
- **Error Tracking**: Monitor failed requests and error details

### Performance Tools
- **FPS Monitoring**: Real-time frame rate tracking
- **Memory Usage**: Monitor application memory consumption
- **CPU Usage**: Track CPU performance metrics
- **Performance Widgets**: In-app performance indicators

### User Interface Debugging
- **View Hierarchy**: Inspect view controller structure
- **Frame Visualization**: Show view frames and boundaries
- **Touch Indicators**: Visualize user touch points
- **Slow Animations**: Debug animation timing issues
- **Grid Overlay**: Layout assistance with grid lines

### Data Inspection
- **Core Data Browser**: Explore managed objects and relationships
- **User Defaults**: View and modify app preferences
- **Keychain Access**: Inspect stored credentials
- **File Browser**: Navigate app's file system
- **Console Output**: Capture and display NSLog messages

### Location & System
- **Location Simulation**: Test location-based features
- **Device Information**: Access device and app details
- **Build Information**: Version and build number display
- **Crash Reports**: View and analyze crash logs

## Requirements

- **iOS 12.0+** (was iOS 8.0+)
- **Xcode 12.0+**
- **Swift 5.3+** (for Swift Package Manager)

## Installation

### CocoaPods

DBDebugToolkit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DBDebugToolkit', '~> 1.0.0'
```

### Swift Package Manager

DBDebugToolkit also supports Swift Package Manager. Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dbukowski/DBDebugToolkit.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/dbukowski/DBDebugToolkit.git`
3. Select version **1.0.0** or higher
4. Click **Add Package**

**Note**: For SPM support, iOS 12.0+ is required.

## Quick Start

### 1. Import the Framework

```objc
#import <DBDebugToolkit/DBDebugToolkit.h>
```

### 2. Enable in AppDelegate

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DBDebugToolkit enable];
    return YES;
}
```

### 3. Activate the Toolkit

- **Shake Device** (simulator: ⌘+⌃+Z)
- **Long Press** on any screen
- **Programmatically**: `[DBDebugToolkit show]`

## Usage Examples

### Copy Response Body

```objc
// Long press on network request cell
// Or use the copy button in body preview
// Or select "Copy body to clipboard" in request details
```

### Search in Body Content

```objc
// Open body preview
// Use search bar to find specific text
// Navigate between results with ↑↓ buttons
```

### Monitor Network Requests

```objc
// View all network requests in real-time
// Inspect request/response headers and bodies
// Copy complete request/response data
```

## Migration from 0.6.1

### Breaking Changes
- **Minimum iOS**: Update from iOS 8.0 to iOS 12.0
- **Deployment Target**: Update project settings accordingly

### New Features
- Search functionality in body preview
- Copy buttons throughout the interface
- Improved navigation bar appearance
- Enhanced error handling

## Documentation

- [Features Overview](Features.md)
- [Authors & Contributors](AUTHORS.md)
- [API Reference](https://github.com/dbukowski/DBDebugToolkit/wiki)
- [Migration Guide](CHANGELOG.md)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

DBDebugToolkit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

**Dariusz Bukowski** - [@darekbukowski](https://twitter.com/darekbukowski)  
**Alex Krzywicki** - Major contributor for version 1.0.0 root@lexone.ru

## Acknowledgments

- Original concept and development by Dariusz Bukowski
- Major improvements and bug fixes by Alex Krzywicki
- Community contributions and feedback
- iOS development community for inspiration

---

**DBDebugToolkit 1.0.0** - Making iOS debugging easier, one tool at a time! 🚀
