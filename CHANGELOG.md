# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Major Contributors
- **Alex Krzywicki** - Major improvements, bug fixes, and new features implementation

### Added
- **Response Body Copy Functionality**: Full ability to copy response and request body from network requests
- **Search Functionality**: Added search bar in body preview with text highlighting and navigation
- **Navigation Bar Background**: Fixed transparent navigation bar issues across all view controllers
- **Enhanced User Experience**: Improved UI consistency and visual feedback

### Enhanced
- **DBBodyPreviewViewController**: Added copy button and search functionality
- **DBRequestDetailsViewController**: Added copy body option in body section
- **DBNetworkViewController**: Added long press gesture for quick body copying
- **DBNetworkSettingsTableViewController**: Improved navigation bar appearance

### Fixed
- **iOS Compatibility**: Updated minimum deployment target from iOS 8.0 to iOS 12.0
- **Navigation Bar Issues**: Resolved transparent background problems
- **Bundle Loading**: Fixed resource bundle loading issues
- **ARC Compatibility**: Resolved libarclite dependency issues

### Technical Improvements
- **Modern iOS Support**: Added iOS 13+ UINavigationBarAppearance support
- **Resource Management**: Improved storyboard and XIB handling
- **Code Organization**: Better separation of concerns and error handling
- **Performance**: Optimized search functionality with debouncing

### Breaking Changes
- **Minimum iOS Version**: Now requires iOS 12.0 or later (was iOS 8.0)

## [0.6.1] - 2016-XX-XX

### Original Release
- Initial release with basic debugging functionality
- Network request monitoring
- Core Data inspection
- Performance monitoring tools
- User interface debugging features
