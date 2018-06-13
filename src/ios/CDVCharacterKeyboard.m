#import <WebKit/WebKit.h>

#import "CDVCharacterKeyboard.h"

@implementation CDVCharacterKeyboard

UIView* ui;
CGRect cgButton;
BOOL isDecimalKeyRequired=YES;
BOOL isDashKeyRequired=YES;
UIButton *decimalButton;
UIButton *dashButton;
BOOL isAppInBackground=NO;

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillAppear:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) appWillResignActive: (NSNotification*) n{
    isAppInBackground = YES;
    [self removeDecimalButton];
    [self removeDashButton];
}

- (void) appDidBecomeActive: (NSNotification*) n{
    if(isAppInBackground==YES){
        isAppInBackground = NO;
        [self processKeyboardShownEvent];
    }
}

- (void) keyboardWillDisappear: (NSNotification*) n{
    [self removeDecimalButton];
    [self removeDashButton];
}

BOOL isDifferentKeyboardShown=NO;

- (void) keyboardWillAppear: (NSNotification*) n{
    NSDictionary* info = [n userInfo];
    NSNumber* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double dValue = [value doubleValue];

    if(dValue <= 0.0){
        [self removeDecimalButton];
        [self removeDashButton];
        return;
    }

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * dValue);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self processKeyboardShownEvent];
    });


}
- (void) processKeyboardShownEvent{
    [self isTextOrNumberAndDecimal:^(BOOL isDecimalKeyRequired) {
        // create custom button
        if(decimalButton == nil){
            if(isDecimalKeyRequired){
                [self addDecimalButton];
            }
        }else{
            if(isDecimalKeyRequired){
                decimalButton.hidden=NO;
                [self setDecimalChar];
            }else{
                [self removeDecimalButton];
            }
        }
    }];

    [self isTextOrNumberAndDash:^(BOOL isDashKeyRequired) {
        // create custom button
        if(dashButton == nil){
            if(isDashKeyRequired){
                [self addDashButton];
            }
        }else{
            if(isDashKeyRequired){
                dashButton.hidden=NO;
                [self setDashChar];
            }else{
                [self removeDashButton];
            }
        }
    }];
}

BOOL stopSearching=NO;
- (void)listSubviewsOfView:(UIView *)view {

    // Get the subviews of the view
    NSArray *subviews = [view subviews];

    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE

    for (UIView *subview in subviews) {
        if(stopSearching==YES){
            break;
        }
        if([[subview description] hasPrefix:@"<UIKBKeyplaneView"] == YES){
            ui = subview;
            stopSearching = YES;
            CGFloat height= 0.0;
            CGFloat width=0.0;
            CGFloat x = 0;
            CGFloat y =ui.frame.size.height;
            for(UIView *nView in ui.subviews){

                if([[nView description] hasPrefix:@"<UIKBKeyView"] == YES){
                    //all keys of same size;
                    height = nView.frame.size.height;
                    width = nView.frame.size.width-1.5;
                    y = y-(height-1);
                    cgButton = CGRectMake(x, y, width, height);
                    break;

                }

            }
        }

        [self listSubviewsOfView:subview];
    }
}

- (void) evaluateJavaScript:(NSString *)script
          completionHandler:(void (^ _Nullable)(NSString * _Nullable response, NSError * _Nullable error))completionHandler {

    if ([self.webView isKindOfClass:UIWebView.class]) {
        UIWebView *webview = (UIWebView*)self.webView;
        NSString *response = [webview stringByEvaluatingJavaScriptFromString:script];
        if (completionHandler) completionHandler(response, nil);
    }

    else if ([self.webView isKindOfClass:WKWebView.class]) {
        WKWebView *webview = (WKWebView*)self.webView;
        [webview evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            if (completionHandler) {
                if (error) completionHandler(nil, error);
                else completionHandler([NSString stringWithFormat:@"%@", result], nil);
            }
        }];
    }

}

///// Decimal

-(void) setDecimalChar {
    [self evaluateJavaScript:@"CharacterKeyboard.getDecimalChar();"
        completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (response) {
                [decimalButton setTitle:response forState:UIControlStateNormal];
            }
        }];
}

- (void) addDecimalButton{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return ; /* Device is iPad and this code works only in iPhone*/
    }
    decimalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setDecimalChar];
    [decimalButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
    decimalButton.titleLabel.font = [UIFont systemFontOfSize:40.0];
    [decimalButton addTarget:self action:@selector(decimalButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    [decimalButton addTarget:self action:@selector(decimalButtonTapped:)
            forControlEvents:UIControlEventTouchDown];
    [decimalButton addTarget:self action:@selector(decimalButtonPressCancel:)
            forControlEvents:UIControlEventTouchUpOutside];

    decimalButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [decimalButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [decimalButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];

    // locate keyboard view
    UIWindow* tempWindow = nil;
    NSArray* openWindows = [[UIApplication sharedApplication] windows];

    for(UIWindow* object in openWindows){
        if([[object description] hasPrefix:@"<UIRemoteKeyboardWindow"] == YES){
            tempWindow = object;
        }
    }

    if(tempWindow ==nil){
        //for ios 8
        for(UIWindow* object in openWindows){
            if([[object description] hasPrefix:@"<UITextEffectsWindow"] == YES){
                tempWindow = object;
            }
        }
    }

    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        [self listSubviewsOfView: keyboard];
        decimalButton.frame = cgButton;
        [ui addSubview:decimalButton];
    }
}

- (void) removeDecimalButton{
    [decimalButton removeFromSuperview];
    decimalButton=nil;
    stopSearching=NO;
}

- (void) deleteDecimalButton{
    [decimalButton removeFromSuperview];
    decimalButton=nil;
    stopSearching=NO;
}

- (void)decimalButtonPressed:(UIButton *)button {
    [decimalButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
    [self evaluateJavaScript:@"CharacterKeyboard.addDecimal();" completionHandler:nil];
}

- (void)decimalButtonTapped:(UIButton *)button {
    [decimalButton setBackgroundColor: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
}
- (void)decimalButtonPressCancel:(UIButton *)button{
    [decimalButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
}

- (void) isTextOrNumberAndDecimal:(void (^)(BOOL isTextOrNumberAndDecimal))completionHandler {
    [self evaluateJavaScript:@"CharacterKeyboard.getActiveElementType();"
           completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
               BOOL isText = [response isEqual:@"text"];
               BOOL isNumber = [response isEqual:@"number"];
               BOOL isTelephone = [response isEqual:@"tel"];

               if (isText || isNumber || isTelephone) {
                   [self evaluateJavaScript:@"CharacterKeyboard.isDecimal();"
                          completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
                              BOOL isDecimal = [response isEqual:@"true"] || [response isEqual:@"1"];
                              BOOL isTextOrNumberAndDecimal = (isText || isNumber || isTelephone) && isDecimal;
                              completionHandler(isTextOrNumberAndDecimal);
                          }];
               } else {
                   completionHandler(NO);
               }
           }];
}

///// Dashes

-(void) setDashChar {
    [self evaluateJavaScript:@"CharacterKeyboard.getDashChar();"
        completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (response) {
                [dashButton setTitle:response forState:UIControlStateNormal];
            }
        }];
}

- (void) addDashButton{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return ; /* Device is iPad and this code works only in iPhone*/
    }
    dashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setDashChar];
    [dashButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
    dashButton.titleLabel.font = [UIFont systemFontOfSize:40.0];
    [dashButton addTarget:self action:@selector(dashButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    [dashButton addTarget:self action:@selector(dashButtonTapped:)
            forControlEvents:UIControlEventTouchDown];
    [dashButton addTarget:self action:@selector(dashButtonPressCancel:)
            forControlEvents:UIControlEventTouchUpOutside];

    dashButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [dashButton setTitleEdgeInsets:UIEdgeInsetsMake(-20.0f, 0.0f, 0.0f, 0.0f)];
    [dashButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];

    // locate keyboard view
    UIWindow* tempWindow = nil;
    NSArray* openWindows = [[UIApplication sharedApplication] windows];

    for(UIWindow* object in openWindows){
        if([[object description] hasPrefix:@"<UIRemoteKeyboardWindow"] == YES){
            tempWindow = object;
        }
    }

    if(tempWindow ==nil){
        //for ios 8
        for(UIWindow* object in openWindows){
            if([[object description] hasPrefix:@"<UITextEffectsWindow"] == YES){
                tempWindow = object;
            }
        }
    }

    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        [self listSubviewsOfView: keyboard];
        dashButton.frame = cgButton;
        [ui addSubview:dashButton];
    }
}

- (void) removeDashButton{
    [dashButton removeFromSuperview];
    dashButton=nil;
    stopSearching=NO;
}

- (void) deleteDashButton{
    [dashButton removeFromSuperview];
    dashButton=nil;
    stopSearching=NO;
}

- (void)dashButtonPressed:(UIButton *)button {
    [dashButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
    [self evaluateJavaScript:@"CharacterKeyboard.addDash();" completionHandler:nil];
}

- (void)dashButtonTapped:(UIButton *)button {
    [dashButton setBackgroundColor: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
}
- (void)dashButtonPressCancel:(UIButton *)button{
    [dashButton setBackgroundColor: [UIColor colorWithRed:210/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
}

- (void) isTextOrNumberAndDash:(void (^)(BOOL isTextOrNumberAndDash))completionHandler {
    [self evaluateJavaScript:@"CharacterKeyboard.getActiveElementType();"
           completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
               BOOL isText = [response isEqual:@"text"];
               BOOL isNumber = [response isEqual:@"number"];
               BOOL isTelephone = [response isEqual:@"tel"];

               if (isText || isNumber || isTelephone) {
                   [self evaluateJavaScript:@"CharacterKeyboard.isDash();"
                          completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
                              BOOL isDash = [response isEqual:@"true"] || [response isEqual:@"1"];
                              BOOL isTextOrNumberAndDash = (isText || isNumber || isTelephone) && isDash;
                              completionHandler(isTextOrNumberAndDash);
                          }];
               } else {
                   completionHandler(NO);
               }
           }];
}

@end
