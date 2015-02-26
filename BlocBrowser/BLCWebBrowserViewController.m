//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Corey Norford on 2/25/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>
    @property (nonatomic, strong) UIWebView *webview;
    @property (nonatomic, strong) UITextField *textField;
    @property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;
    @property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
    @property (nonatomic, assign) NSUInteger frameCount;
    @property (nonatomic, strong) NSArray *backgroundColors;
    @property (nonatomic, strong) UIColor *activeBackgroundColor;
@end

@implementation BLCWebBrowserViewController

     #pragma mark - UIViewController

    - (void)loadView {
        UIView *mainView = [UIView new];
        self.webview = [[UIWebView alloc] init];
        self.webview.delegate = self;
        
        self.textField = [[UITextField alloc] init];
        self.textField.keyboardType = UIKeyboardTypeURL;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.placeholder = NSLocalizedString(@"Website URL or Search Text", @"Placeholder text for web browser URL field");
        self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
        self.textField.delegate = self;
        
        self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
        self.awesomeToolbar.delegate = self;
        
         for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
            [mainView addSubview:viewToAdd];
        }
        
        self.view = mainView;
    }

    - (void) viewWillLayoutSubviews {
        [super viewWillLayoutSubviews];
        
        //make the webview fill the main view
        //self.webview.frame = self.view.frame;
        
        // First, calculate some dimensions.
        static const CGFloat itemHeight = 50;
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
        
        // Now, assign the frames
        self.textField.frame = CGRectMake(0, 0, width, itemHeight);
        self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
        
        self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
        
        UIColor *gray = [UIColor grayColor];
        UIColor *red = [UIColor redColor];
        self.backgroundColors = @[gray, red];
        self.activeBackgroundColor = gray;
    }

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        
        // Do any additional setup after loading the view.
    }

     #pragma mark - UITextFieldDelegate

    - (BOOL)textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
        
        NSString *URLString = textField.text;
        
        NSURL *URL = [NSURL URLWithString:URLString];
        
        if (!URL.scheme) {
            if ([textField.text rangeOfString:@"."].location == NSNotFound) {
                NSString *textWithPluses = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                
                URLString = [NSString stringWithFormat:@"www.google.com/search?q=%@", textWithPluses];
            }
            else{
            }
            
            // The user didn't type http: or https:
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
        
        if (URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webview loadRequest:request];
        }
        
        return NO;
    }

     #pragma mark - UIWebViewDelegate

    - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
        if (error.code != -999) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [self updateButtonsAndTitle];
        self.frameCount--;
    }

    - (void)webViewDidStartLoad:(UIWebView *)webView {
        self.frameCount++;
        [self updateButtonsAndTitle];
    }

    - (void)webViewDidFinishLoad:(UIWebView *)webView {
        self.frameCount--;
        [self updateButtonsAndTitle];
    }

    #pragma mark - Miscellaneous

    - (void) updateButtonsAndTitle {
        NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        if (webpageTitle) {
            self.title = webpageTitle;
        } else {
            self.title = self.webview.request.URL.absoluteString;
        }
        
        if (self.frameCount > 0) {
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
        
        [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
        [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
        [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
        [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
    }

    - (void) resetWebView {
        [self.webview removeFromSuperview];
        
        UIWebView *newWebView = [[UIWebView alloc] init];
        newWebView.delegate = self;
        [self.view addSubview:newWebView];
        
        self.webview = newWebView;
        
        self.textField.text = nil;
        [self updateButtonsAndTitle];
    }

    #pragma mark - BLCAwesomeFloatingToolbarDelegate

    - (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
        if ([title isEqual:kBLCWebBrowserBackString]) {
            [self.webview goBack];
        } else if ([title isEqual:kBLCWebBrowserForwardString]) {
            [self.webview goForward];
        } else if ([title isEqual:kBLCWebBrowserStopString]) {
            [self.webview stopLoading];
        } else if ([title isEqual:kBLCWebBrowserRefreshString]) {
            [self.webview reload];
        }
    }

    - (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
        CGPoint startingPoint = toolbar.frame.origin;
        CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
        
        CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
        
        if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
            toolbar.frame = potentialNewFrame;
        }
    }

    - (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPinch:(CGAffineTransform)transform {
        toolbar.transform = transform;
    }


    - (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didLongPress:(NSNumber *)number {
    
        if(self.activeBackgroundColor == [UIColor grayColor]){
            self.activeBackgroundColor = [UIColor whiteColor];
            self.textField.backgroundColor = [UIColor whiteColor];
        }
        else{
            self.activeBackgroundColor = [UIColor grayColor];
            self.textField.backgroundColor = [UIColor grayColor];
        }
        
    }

@end
