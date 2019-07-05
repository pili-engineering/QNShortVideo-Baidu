//
//  BARGestureView.m
//  ARAPP-OpenStandard
//
//  Created by Asa on 2019/3/25.
//  Copyright © 2019 Asa. All rights reserved.
//

#import "BARGestureView.h"

@implementation BARGestureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        if (self.isMultipleTouchEnabled == NO) {
            self.multipleTouchEnabled = YES;
        }
        self.userInteractionEnabled = YES;
        self.opaque = YES;
        self.hidden = NO;
        
        [self addGesture];
        
        if ([self respondsToSelector:@selector(setContentScaleFactor:)])
        {
            self.contentScaleFactor = [[UIScreen mainScreen] nativeScale];
        }
    }
    return self;
}

- (void)handleGesture:(UIGestureRecognizer *)gesture{
    [self.gesturedelegate onViewGesture:gesture];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (self.gesturedelegate && [self.gesturedelegate respondsToSelector:@selector(ar_touchesBegan:scale:)]) {
        [self.gesturedelegate ar_touchesBegan:touches scale:scale];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (self.gesturedelegate && [self.gesturedelegate respondsToSelector:@selector(ar_touchesMoved:scale:)]) {
        [self.gesturedelegate ar_touchesMoved:touches scale:scale];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (self.gesturedelegate && [self.gesturedelegate respondsToSelector:@selector(ar_touchesEnded:scale:)]) {
        [self.gesturedelegate ar_touchesEnded:touches scale:scale];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (self.gesturedelegate && [self.gesturedelegate respondsToSelector:@selector(ar_touchesCancelled:scale:)]) {
        [self.gesturedelegate ar_touchesCancelled:touches scale:scale];
    }
}


- (void)addGesture{
    //单击
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    singleTapRecognizer.delaysTouchesBegan = NO;
    singleTapRecognizer.delaysTouchesEnded = NO;
    [self addGestureRecognizer:singleTapRecognizer];
    
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 2;
    panGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pinchGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pinchGestureRecognizer];
    
    //双击
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.cancelsTouchesInView = NO;
    doubleTapRecognizer.delaysTouchesBegan = NO;
    doubleTapRecognizer.delaysTouchesEnded = NO;
    [self addGestureRecognizer:doubleTapRecognizer];
    
    if(doubleTapRecognizer && singleTapRecognizer){
        //双击发生之后忽略单击
        //[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    }
    
    //swipe
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeRightRecognizer.numberOfTouchesRequired = 1;
    swipeRightRecognizer.cancelsTouchesInView = NO;
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeLeftRecognizer.numberOfTouchesRequired = 1;
    swipeLeftRecognizer.cancelsTouchesInView = NO;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeUpRecognizer.numberOfTouchesRequired = 1;
    swipeUpRecognizer.cancelsTouchesInView = NO;
    swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpRecognizer];
    
    UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeDownRecognizer.numberOfTouchesRequired = 1;
    swipeDownRecognizer.cancelsTouchesInView = NO;
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownRecognizer];
    
    //long press
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    longPressRecognizer.numberOfTouchesRequired = 1;
    //    longPressRecognizer.minimumPressDuration = 0.5;
    longPressRecognizer.allowableMovement = 10;
    longPressRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:longPressRecognizer];
    
    //rotate
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:rotateRecognizer];
}

@end
