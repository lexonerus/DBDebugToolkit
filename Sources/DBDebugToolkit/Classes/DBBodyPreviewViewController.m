// The MIT License
//
// Copyright (c) 2016 Dariusz Bukowski
// Copyright (c) 2025 Alex Krzywicki
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

#import "DBBodyPreviewViewController.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, DBBodyPreviewViewControllerViewState) {
    DBBodyPreviewViewControllerViewStateLoading,
    DBBodyPreviewViewControllerViewStateShowingText,
    DBBodyPreviewViewControllerViewStateShowingImage,
};

@interface DBBodyPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *currentBodyText;
@property (nonatomic, strong) NSData *currentBodyData;
@property (nonatomic, assign) DBRequestModelBodyType currentBodyType;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) NSInteger currentSearchIndex;
@property (nonatomic, strong) NSAttributedString *originalAttributedText;

@end

@implementation DBBodyPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add background color to navigation bar without changing transparency
    if (self.navigationController) {
        if (@available(iOS 13.0, *)) {
            // For iOS 13+, set background color while keeping current appearance
            UINavigationBarAppearance *appearance = self.navigationController.navigationBar.standardAppearance;
            if (!appearance) {
                appearance = [[UINavigationBarAppearance alloc] init];
            }
            appearance.backgroundColor = [UIColor systemBackgroundColor];
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            // For iOS 12 and earlier, set background color
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
    
    // Configure search bar
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search in body...";
    self.searchBar.showsCancelButton = NO;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Initialize search properties
    self.searchResults = @[];
    self.currentSearchIndex = -1;
    
    // Add Copy button to navigation bar
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithTitle:@"Copy" 
                                                                    style:UIBarButtonItemStylePlain 
                                                                   target:self 
                                                                   action:@selector(copyButtonTapped:)];
    
    // Add search navigation buttons
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:@"↑" 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(previousSearchResult)];
    previousButton.enabled = NO;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"↓" 
                                                                    style:UIBarButtonItemStylePlain 
                                                                   target:self 
                                                                   action:@selector(nextSearchResult)];
    nextButton.enabled = NO;
    
    // Store references to enable/disable buttons
    objc_setAssociatedObject(self, "previousButton", previousButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "nextButton", nextButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.navigationItem.rightBarButtonItems = @[copyButton, nextButton, previousButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Ensure navigation bar has background color
    if (self.navigationController) {
        if (@available(iOS 13.0, *)) {
            UINavigationBarAppearance *appearance = self.navigationController.navigationBar.standardAppearance;
            if (!appearance) {
                appearance = [[UINavigationBarAppearance alloc] init];
            }
            appearance.backgroundColor = [UIColor systemBackgroundColor];
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
}

- (void)configureWithRequestModel:(DBRequestModel *)requestModel mode:(DBBodyPreviewViewControllerMode)mode {
    self.title = mode == DBBodyPreviewViewControllerModeRequest ? @"Request body" : @"Response body";
    [self setViewState:DBBodyPreviewViewControllerViewStateLoading animated:YES];
    DBRequestModelBodyType bodyType = mode == DBBodyPreviewViewControllerModeRequest ? requestModel.requestBodyType : requestModel.responseBodyType;
    self.currentBodyType = bodyType;
    
    void (^completion)(NSData *) = ^void(NSData *data) {
        self.currentBodyData = data;
        if (bodyType == DBRequestModelBodyTypeImage) {
            self.imageView.image = [UIImage imageWithData:data];
            [self setViewState:DBBodyPreviewViewControllerViewStateShowingImage animated:YES];
        } else {
            NSString *dataString;
            if (bodyType == DBRequestModelBodyTypeJSON) {
                NSError *error;
                NSJSONSerialization *jsonSerialization = [NSJSONSerialization JSONObjectWithData:data ?: [NSData data]
                                                                                         options:NSJSONReadingAllowFragments
                                                                                           error:&error];
                if (error) {
                    dataString = @"Unable to read the data.";
                } else {
                    data = [NSJSONSerialization dataWithJSONObject:jsonSerialization options:NSJSONWritingPrettyPrinted error:nil];
                    dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    dataString = [dataString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                }
            } else {
                NSString *UTF8DecodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (UTF8DecodedString == nil) {
                    NSMutableString *mutableDataString = [NSMutableString stringWithCapacity:data.length * 2];
                    const unsigned char *dataBytes = [data bytes];
                    for (NSInteger index = 0; index < data.length; index++) {
                        [mutableDataString appendFormat:@"%02x", dataBytes[index]];
                    }
                    dataString = [mutableDataString copy];
                } else {
                    dataString = UTF8DecodedString;
                }
            }
            self.currentBodyText = dataString;
            self.textView.text = dataString;
            
            // Store original attributed text for highlighting
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:dataString];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, attributedText.length)];
            self.originalAttributedText = [attributedText copy];
            
            [self setViewState:DBBodyPreviewViewControllerViewStateShowingText animated:YES];
        }
    };
    if (mode == DBBodyPreviewViewControllerModeRequest) {
        [requestModel readRequestBodyWithCompletion:completion];
    } else {
        [requestModel readResponseBodyWithCompletion:completion];
    }
}

- (void)setViewState:(DBBodyPreviewViewControllerViewState)state animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.35 : 0.0 animations:^{
        self.activityIndicator.alpha = 0.0;
        self.textView.alpha = 0.0;
        self.imageView.alpha = 0.0;
        switch (state) {
            case DBBodyPreviewViewControllerViewStateLoading: {
                [self.activityIndicator startAnimating];
                self.activityIndicator.alpha = 1.0;
                break;
            }
            case DBBodyPreviewViewControllerViewStateShowingText:
                self.textView.alpha = 1.0;
                break;
            case DBBodyPreviewViewControllerViewStateShowingImage:
                self.imageView.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        if (state != DBBodyPreviewViewControllerViewStateLoading) {
            [self.activityIndicator stopAnimating];
        }
    }];
}

#pragma mark - Copy functionality

- (IBAction)copyButtonTapped:(id)sender {
    [self copyBodyToClipboard];
}

- (void)copyBodyToClipboard {
    if (self.currentBodyType == DBRequestModelBodyTypeImage) {
        if (self.currentBodyData) {
            // For images, we can't copy the image directly to clipboard, but we can show a message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Image Body"
                                                                         message:@"Image data cannot be copied to clipboard. You can take a screenshot or save the image."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        if (self.currentBodyText && self.currentBodyText.length > 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.currentBodyText;
            
            // Show success feedback
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Copied!"
                                                                         message:@"Body content has been copied to clipboard."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // Show error message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Content"
                                                                         message:@"There is no content to copy."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Search functionality

- (void)performSearchWithText:(NSString *)searchText {
    if (!searchText || searchText.length == 0 || !self.currentBodyText) {
        self.searchResults = @[];
        self.currentSearchIndex = -1;
        [self updateSearchNavigationButtons];
        [self clearHighlighting];
        return;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSString *bodyText = [self.currentBodyText lowercaseString];
    NSString *searchLower = [searchText lowercaseString];
    
    NSRange searchRange = NSMakeRange(0, bodyText.length);
    NSRange foundRange;
    
    while ((foundRange = [bodyText rangeOfString:searchLower options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:@(foundRange.location)];
        searchRange = NSMakeRange(foundRange.location + 1, bodyText.length - foundRange.location - 1);
    }
    
    self.searchResults = [results copy];
    self.currentSearchIndex = results.count > 0 ? 0 : -1;
    
    [self updateSearchNavigationButtons];
    
    if (results.count > 0) {
        [self applyHighlighting];
        [self highlightCurrentSearchResult];
    } else {
        [self clearHighlighting];
    }
}

- (void)updateSearchNavigationButtons {
    UIBarButtonItem *previousButton = objc_getAssociatedObject(self, "previousButton");
    UIBarButtonItem *nextButton = objc_getAssociatedObject(self, "nextButton");
    
    BOOL hasResults = self.searchResults.count > 0;
    previousButton.enabled = hasResults;
    nextButton.enabled = hasResults;
    
    if (hasResults) {
        self.searchBar.placeholder = [NSString stringWithFormat:@"%ld of %lu", (long)(self.currentSearchIndex + 1), (unsigned long)self.searchResults.count];
    } else {
        self.searchBar.placeholder = @"Search in body...";
    }
}

- (void)applyHighlighting {
    if (!self.originalAttributedText || self.searchResults.count == 0) {
        return;
    }
    
    NSMutableAttributedString *highlightedText = [self.originalAttributedText mutableCopy];
    NSString *searchText = self.searchBar.text;
    
    // Apply highlighting to all search results
    for (NSNumber *location in self.searchResults) {
        NSRange range = NSMakeRange([location integerValue], searchText.length);
        if (range.location + range.length <= highlightedText.length) {
            [highlightedText addAttribute:NSBackgroundColorAttributeName 
                                   value:[UIColor yellowColor] 
                                   range:range];
        }
    }
    
    // Apply the highlighted text
    self.textView.attributedText = highlightedText;
}

- (void)clearHighlighting {
    if (self.originalAttributedText) {
        self.textView.attributedText = self.originalAttributedText;
    }
}

- (void)highlightCurrentSearchResult {
    if (self.currentSearchIndex < 0 || self.currentSearchIndex >= self.searchResults.count) {
        return;
    }
    
    NSInteger location = [self.searchResults[self.currentSearchIndex] integerValue];
    NSString *searchText = self.searchBar.text;
    
    // Scroll to the found text
    NSRange range = NSMakeRange(location, searchText.length);
    [self.textView scrollRangeToVisible:range];
    
    // Highlight the current result more prominently
    [self highlightCurrentResult];
}

- (void)highlightCurrentResult {
    if (!self.originalAttributedText || self.currentSearchIndex < 0 || self.currentSearchIndex >= self.searchResults.count) {
        return;
    }
    
    NSMutableAttributedString *highlightedText = [self.originalAttributedText mutableCopy];
    NSString *searchText = self.searchBar.text;
    
    // Apply highlighting to all search results
    for (NSNumber *location in self.searchResults) {
        NSRange range = NSMakeRange([location integerValue], searchText.length);
        if (range.location + range.length <= highlightedText.length) {
            [highlightedText addAttribute:NSBackgroundColorAttributeName 
                                   value:[UIColor yellowColor] 
                                   range:range];
        }
    }
    
    // Highlight current result more prominently
    NSInteger currentLocation = [self.searchResults[self.currentSearchIndex] integerValue];
    NSRange currentRange = NSMakeRange(currentLocation, searchText.length);
    if (currentRange.location + currentRange.length <= highlightedText.length) {
        [highlightedText addAttribute:NSBackgroundColorAttributeName 
                               value:[UIColor orangeColor] 
                               range:currentRange];
    }
    
    // Apply the highlighted text
    self.textView.attributedText = highlightedText;
}

- (void)nextSearchResult {
    if (self.searchResults.count == 0) return;
    
    self.currentSearchIndex = (self.currentSearchIndex + 1) % self.searchResults.count;
    [self updateSearchNavigationButtons];
    [self highlightCurrentSearchResult];
}

- (void)previousSearchResult {
    if (self.searchResults.count == 0) return;
    
    self.currentSearchIndex = (self.currentSearchIndex - 1 + self.searchResults.count) % self.searchResults.count;
    [self updateSearchNavigationButtons];
    [self highlightCurrentSearchResult];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Perform search with a slight delay to avoid excessive searching while typing
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearchWithText:) object:nil];
    [self performSelector:@selector(performSearchWithText:) withObject:searchText afterDelay:0.3];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self performSearchWithText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self performSearchWithText:@""];
    [self clearHighlighting];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}
@end

