//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Corey Norford on 2/25/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwesomeFloatingToolbar;

@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>
    @optional
    - (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
@end

@interface BLCAwesomeFloatingToolbar : UIView

    - (instancetype) initWithFourTitles:(NSArray *)titles;

    - (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

    @property (nonatomic, weak) id <BLCAwesomeFloatingToolbarDelegate> delegate;

@end
