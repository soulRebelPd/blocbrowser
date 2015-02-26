//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Corey Norford on 2/25/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()
    @property (nonatomic, strong) NSArray *currentTitles;
    @property (nonatomic, strong) NSArray *colors;
    @property (nonatomic, strong) NSArray *buttons;
    @property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
    @property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
    @property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end

@implementation BLCAwesomeFloatingToolbar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

    - (instancetype) initWithFourTitles:(NSArray *)titles {
        // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
        self = [super init];
        
        if (self) {
            
            // Save the titles, and set the 4 colors
            self.currentTitles = titles;
            self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                            [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
            
            NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
            
            // Make the 4 labels
            for (NSString *currentTitle in self.currentTitles) {
                UIButton *button = [[UIButton alloc] init];
                [button addTarget:self
                           action:@selector(buttonFired:)
                 forControlEvents:UIControlEventTouchUpInside];
                
                button.userInteractionEnabled = YES;
                button.alpha = 0.25;
                
                NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
                NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
                UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];

                [button setTitle:titleForThisLabel forState:UIControlStateNormal];
                [button setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
                
                button.titleLabel.textColor = [UIColor blackColor];
                button.backgroundColor = colorForThisLabel;
                
                [buttonsArray addObject:button];
            }
            
            self.buttons = buttonsArray;
            
            for (UIButton *thisButton in self.buttons) {
                [self addSubview:thisButton];
            }
            
            self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
            [self addGestureRecognizer:self.panGesture];
            self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
            [self addGestureRecognizer:self.pinchGesture];
            self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
            [self addGestureRecognizer:self.longPressGesture];
        }
        
        return self;
    }

    - (void) layoutSubviews {
        // set the frames for the 4 labels
        
        for (UIButton *thisButton in self.buttons) {
            NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisButton];
            
            CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
            CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
            CGFloat labelX = 0;
            CGFloat labelY = 0;
            
            // adjust labelX and labelY for each label
            if (currentLabelIndex < 2) {
                // 0 or 1, so on top
                labelY = 0;
            } else {
                // 2 or 3, so on bottom
                labelY = CGRectGetHeight(self.bounds) / 2;
            }
            
            if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
                // 0 or 2, so on the left
                labelX = 0;
            } else {
                // 1 or 3, so on the right
                labelX = CGRectGetWidth(self.bounds) / 2;
            }
            
            thisButton.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        }
    }

    #pragma mark - Touch Handling

    - (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        UIView *subview = [self hitTest:location withEvent:event];
        return (UILabel *)subview;
    }

    - (void)buttonFired:(UIButton *)sender {
        NSLog(@"%@ button clicked", sender.titleLabel.text);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:sender.titleLabel.text];
        }
    }

    - (void) panFired:(UIPanGestureRecognizer *)recognizer {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:self];
            
            NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
            
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
                [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
            }
            
            [recognizer setTranslation:CGPointZero inView:self];
        }
    }

    - (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            
            CGFloat scale = recognizer.scale;
            NSString *scaleString = [NSString stringWithFormat: @"%.2f", scale];
            
            CGAffineTransform transform = CGAffineTransformScale(self.transform, recognizer.scale, recognizer.scale);
            
            NSLog(@"New transform: %@", NSStringFromCGAffineTransform(transform));
            NSLog(@"New scale: %@", scaleString);
            
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinch:)]) {
                [self.delegate floatingToolbar:self didTryToPinch:transform];
            }
            
            recognizer.scale = 1.0;
        }
    }

    - (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didLongPress:)]) {
                [self.delegate floatingToolbar:self didLongPress:0];
            }
        }
    }


    #pragma mark - Button Enabling

    - (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
        NSUInteger index = [self.currentTitles indexOfObject:title];
        
        if (index != NSNotFound) {
            UIButton *button = [self.buttons objectAtIndex:index];
            button.userInteractionEnabled = enabled;
            button.alpha = enabled ? 1.0 : 0.25;
        }
    }

@end
