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

#import "DBBodyPreviewViewController.h"

typedef NS_ENUM(NSUInteger, DBBodyPreviewViewControllerViewState) {
    DBBodyPreviewViewControllerViewStateLoading,
    DBBodyPreviewViewControllerViewStateShowingText,
    DBBodyPreviewViewControllerViewStateShowingImage,
};

@interface DBBodyPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *currentBodyText;
@property (nonatomic, strong) NSData *currentBodyData;
@property (nonatomic, assign) DBRequestModelBodyType currentBodyType;

@end

@implementation DBBodyPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

@end
