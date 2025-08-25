// The MIT License
//
// Copyright (c) 2016 Dariusz Bukowski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSBundle+DBDebugToolkit.h"
#import "DBDebugToolkit.h"

@implementation NSBundle (DBDebugToolkit)

+ (instancetype)debugToolkitBundle {
    // Try multiple approaches to find the bundle
    
    // Method 1: Try to find the resource bundle in main bundle
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *bundleURL = [mainBundle URLForResource:@"DBDebugToolkit_DBDebugToolkit" withExtension:@"bundle"];
    
    if (bundleURL) {
        NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
        if (resourceBundle) {
            return resourceBundle;
        }
    }
    
    // Method 2: Try to find the resource bundle in the pod bundle
    NSBundle *podBundle = [NSBundle bundleForClass:[DBDebugToolkit class]];
    if (podBundle) {
        bundleURL = [podBundle URLForResource:@"DBDebugToolkit_DBDebugToolkit" withExtension:@"bundle"];
        if (bundleURL) {
            NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
            if (resourceBundle) {
                return resourceBundle;
            }
        }
    }
    
    // Method 3: Try to find the resource bundle in the framework bundle
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[DBDebugToolkit class]];
    if (frameworkBundle) {
        bundleURL = [frameworkBundle URLForResource:@"DBDebugToolkit" withExtension:@"bundle"];
        if (bundleURL) {
            NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
            if (resourceBundle) {
                return resourceBundle;
            }
        }
    }
    
    // Method 4: Try to find storyboards directly in the pod bundle
    if (podBundle) {
        NSURL *storyboardURL = [podBundle URLForResource:@"DBBodyPreviewViewController" withExtension:@"storyboard"];
        if (storyboardURL) {
            return podBundle;
        }
    }
    
    // Method 5: Fallback to main bundle if nothing else works
    NSLog(@"DBDebugToolkit: Could not find resource bundle, falling back to main bundle");
    return mainBundle;
}

@end
