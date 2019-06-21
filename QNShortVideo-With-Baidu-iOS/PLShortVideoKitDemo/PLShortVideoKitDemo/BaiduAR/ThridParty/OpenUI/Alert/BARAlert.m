//
//  BARAlert.m
//  ARSDK
//
//  Created by LiuQi on 15/8/18.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "BARAlert.h"
#import "BARFaceUtil.h"
#import "BARCustomAlertView.h"
#import "BARBaseTextIndicatingView.h"
//#define KISIphoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))

@interface BARAlert () <BARCustomAlertViewDelegate>

@property (nonatomic, copy) BARAlertOtherEventBlock otherBlock;
@property (nonatomic, copy) BARAlertCancelEventBlock cancelBlock;
@property (nonatomic, copy) BARAlertCompleteEventBlock completeBlock;

@property (nonatomic, strong) BARCustomAlertView *curCustomAlertView;
@property (nonatomic, strong) BARBaseTextIndicatingView *textIndicator;
@property (nonatomic, strong) UIAlertView *curAlertView;
@property (nonatomic, assign) UIDeviceOrientation direction;
@property (nonatomic, strong) NSTimer *timeoutAlertTimer;
@property (nonatomic, strong) UIView *replacedView;


@end

@implementation BARAlert

+ (BARAlert *)sharedInstance
{
    
    static BARAlert * sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate,^{
        sharedInstance = [[BARAlert alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    [self cleanBlock];
}

- (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             otherButtonTitles:(NSString *)otherButtonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  dismissOther:(BOOL) dismiss
{
    if (dismiss) {
        [self dismissNow];
    }
    
    if(cancelButtonTitle.length == 0){
        cancelButtonTitle = nil;
    }
    if(otherButtonTitles.length == 0){
        otherButtonTitles = nil;
    }
    BARCustomAlertView *recogFail = [[BARCustomAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitles];
    self.curCustomAlertView = recogFail;
    recogFail.delegate=self;
    recogFail.buttonHeight = 48;
    recogFail.titleTopPadding = 24;
    recogFail.titleHeight = 28;
    recogFail.titleBottomPadding = 23;
    recogFail.messageBottomPadding = 32;
    
    /*
    //由于Basic版本横屏效果不符合UE设计，所以2.3暂时屏蔽横竖屏需求
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        recogFail.width = [UIScreen mainScreen].bounds.size.height * 0.8f;
    }else {
        recogFail.width = [UIScreen mainScreen].bounds.size.width * 0.8f;
    }
    */
    recogFail.width = [UIScreen mainScreen].bounds.size.width * 0.8f;

    [recogFail show];
    
    [self setCurrentDeviceOrientation];
}

- (void)showAlertViewWithTitle:(NSString*)title
                       message:(NSString*)message
             otherButtonTitles:(NSString *)otherButtonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle
{
    [self dismissNow];
    [self showAlertViewWithTitle:title message:message otherButtonTitles:otherButtonTitles cancelButtonTitle:cancelButtonTitle dismissOther:YES];
}


- (void)showToastViewWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message dismissComplete:(BARAlertCompleteEventBlock)complete
{
     [self dismissNow];
    
    self.completeBlock = complete;
    BARCustomAlertView *recogFail = [[BARCustomAlertView alloc] initWithTitle:title message:message cancelButtonTitle:nil otherButtonTitle:nil];
    recogFail.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    recogFail.messageBottomPadding = 0;
    recogFail.titleHeight = 20;
    recogFail.messageLeftRightPadding = 10;
    recogFail.messageLabel.font = [UIFont systemFontOfSize:16];
    recogFail.messageLabel.textColor = [UIColor whiteColor];
    recogFail.shouldDimBackgroundWhenShowInWindow = false;
    
    recogFail.delegate=self;
    self.curCustomAlertView = recogFail;
    [recogFail show];
    [self updateFrame];
    self.timeoutAlertTimer = [NSTimer scheduledTimerWithTimeInterval:it
                                     target:self
                                   selector:@selector(dismiss)
                                   userInfo:nil
                                    repeats:NO];
    
    [self setCurrentDeviceOrientation];
}

- (void)showToastViewPortraitWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message dismissComplete:(BARAlertCompleteEventBlock)complete {
    
    [self dismissNow];
    
    self.completeBlock = complete;
    BARCustomAlertView *recogFail = [[BARCustomAlertView alloc] initWithTitle:title message:message cancelButtonTitle:nil otherButtonTitle:nil];
    recogFail.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    recogFail.messageBottomPadding = 0;
    recogFail.titleHeight = 20;
    recogFail.messageLeftRightPadding = 10;
    recogFail.messageLabel.font = [UIFont systemFontOfSize:16];
    recogFail.messageLabel.textColor = [UIColor whiteColor];
    recogFail.shouldDimBackgroundWhenShowInWindow = false;
    
    recogFail.delegate=self;
    self.curCustomAlertView = recogFail;
    [recogFail show];
    self.timeoutAlertTimer = [NSTimer scheduledTimerWithTimeInterval:it
                                                              target:self
                                                            selector:@selector(dismissNow)
                                                            userInfo:nil
                                                             repeats:NO];
    
    [self setCurrentDeviceOrientation];
}

- (void)showToastViewPortraitWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message frame:(CGRect)frame dismissComplete:(BARAlertCompleteEventBlock)complete {

    [self dismissNow];
    
    self.completeBlock = complete;
    BARCustomAlertView *recogFail = [[BARCustomAlertView alloc] initWithTitle:title message:message cancelButtonTitle:nil otherButtonTitle:nil];
    recogFail.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    recogFail.messageBottomPadding = 0;
    recogFail.titleHeight = 20;
    recogFail.messageLeftRightPadding = 10;
    recogFail.messageLabel.font = [UIFont systemFontOfSize:16];
    recogFail.messageLabel.textColor = [UIColor whiteColor];
    recogFail.shouldDimBackgroundWhenShowInWindow = false;
    
    recogFail.delegate=self;
    self.curCustomAlertView = recogFail;
    [recogFail setAlertCustomFrame: frame];

    [recogFail show];
    self.timeoutAlertTimer = [NSTimer scheduledTimerWithTimeInterval:it
                                                              target:self
                                                            selector:@selector(dismiss)
                                                            userInfo:nil
                                                             repeats:NO];
    
    [self setCurrentDeviceOrientation];
}

- (BARCustomAlertView *)createBARCustomAlertViewWithMessage:(NSString *)message{
    BARCustomAlertView *recogFail = [[BARCustomAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:nil otherButtonTitle:nil];
    recogFail.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    recogFail.messageBottomPadding = 0;
    recogFail.titleHeight = 20;
    recogFail.messageLeftRightPadding = 10;
    recogFail.messageLabel.font = [UIFont systemFontOfSize:16];
    recogFail.messageLabel.textColor = [UIColor whiteColor];
    recogFail.shouldDimBackgroundWhenShowInWindow = false;
    recogFail.delegate=self;
    return recogFail;
}

- (void)showToastOnlyDismissToastViewWithTime:(NSTimeInterval)it message:(NSString *)message{
    BARCustomAlertView *toast = [self createBARCustomAlertViewWithMessage:message];
    [toast show];
    self.curCustomAlertView = toast;
    [self updateFrame];
    [self setCurrentDeviceOrientation];
    self.timeoutAlertTimer = [NSTimer scheduledTimerWithTimeInterval:it
                                                              target:self
                                                            selector:@selector(onlyDismissToast)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)onlyDismissToast{
    
    if(self.timeoutAlertTimer) {
        [self.timeoutAlertTimer invalidate];
        self.timeoutAlertTimer = nil;
    }
    
    if(self.curCustomAlertView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.curCustomAlertView dismiss];
            self.curCustomAlertView = nil;
        });
    }
    
    [self cleanBlock];
    
}

- (void)showToastViewWithTime:(NSTimeInterval)it message:(NSString *)message dismissOthers:(BOOL)dissmiss {
    
    if (dissmiss) {
        [self dismissNow];
    }
    BARCustomAlertView *toast = [self createBARCustomAlertViewWithMessage:message];
    [toast show];
    self.curCustomAlertView = toast;
    self.curCustomAlertView.appearAnimationType = BARCustomAlertViewAnimationTypeNone;
    [self updateFrame];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismiss];
    });
    
    [self setCurrentDeviceOrientation];
    
}


- (void)dismissNow
{
  
    if(self.curCustomAlertView) {
        [self.curCustomAlertView dismissNow];
        self.curCustomAlertView = nil;
        if(self.completeBlock) {
            self.completeBlock();
            self.completeBlock = nil;
        }
    }
    [self dismiss];
}

- (void)dismiss
{
    if(self.timeoutAlertTimer) {
        [self.timeoutAlertTimer invalidate];
        self.timeoutAlertTimer = nil;
    }
    
    if(self.curCustomAlertView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.curCustomAlertView dismiss];
            self.curCustomAlertView = nil;
            if(self.completeBlock) {
                self.completeBlock();
                self.completeBlock = nil;
            }
        });
    }
    
    if(self.curAlertView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.curAlertView dismissWithClickedButtonIndex:0 animated:NO];
            self.curAlertView = nil;
            if(self.completeBlock) {
                self.completeBlock();
                self.completeBlock = nil;
            }
        });
    }
    
    if(self.textIndicator) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textIndicator removeFromSuperview];
            self.textIndicator = nil;
        });
    }
    
    
    [self cleanBlock];
}


- (void)setButtonOtherBlock:(BARAlertOtherEventBlock)block
{
    self.otherBlock = block;
}

- (void)setButtonCancelBlock:(BARAlertCancelEventBlock)block
{
    self.cancelBlock = block;
}

- (void)cleanBlock
{
    if(self.completeBlock) {
        self.completeBlock = nil;
    }
    [self setButtonOtherBlock:nil];
    [self setButtonCancelBlock:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if(self.otherBlock) {
           self.otherBlock();
        }
        
    }else{
        if(self.cancelBlock) {
            self.cancelBlock();
        }
    }
}

- (void)cancelButtonClickedOnAlertView:(BARCustomAlertView *)alertView{
    if(self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)otherButtonClickedOnAlertView:(BARCustomAlertView *)alertView{
    if(self.otherBlock) {
        self.otherBlock();
    }
}

- (void)setLandscapeMode:(UIDeviceOrientation)direction{
    self.direction = direction;
    [self updateFrame];
}


- (void)updateFrame {
    UIView* targetView = nil;
    if (self.curCustomAlertView) {
        targetView = self.curCustomAlertView;
    }
    if (self.curAlertView) {
        targetView = self.curAlertView;
    }
//    if (self.textIndicator) {
//        targetView = self.textIndicator;
//    }
    if (targetView) {
        if (self.direction == UIDeviceOrientationLandscapeLeft) {
            targetView.transform = CGAffineTransformMakeRotation(0.5 * M_PI);
        } else if (self.direction == UIDeviceOrientationLandscapeRight) {
            targetView.transform = CGAffineTransformMakeRotation(-0.5 * M_PI);
        }else {
            targetView.transform = CGAffineTransformIdentity;
        }
    }
}

#pragma - trackIndicator
- (void)showTrackIndicatorViewWithText:(NSString *)text {
    
    [self dismissIndicator];
    if (!text || [text length] == 0) {
        return;
    }
    
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    BARBaseTextIndicatingView *textIndicator = [[BARBaseTextIndicatingView alloc] initWithFrame:self.replacedView.frame];
    [textIndicator setLandscapeMode:UIDeviceOrientationPortrait];
//    [textIndicator setLandscapeMode:self.direction];
    self.textIndicator = textIndicator;
    
    [window addSubview:self.textIndicator];
    [self.textIndicator setText:text];
    [self.textIndicator show];
}

- (void)dismissIndicator {
    
    if (self.textIndicator) {
        [self.textIndicator removeFromSuperview];
        self.textIndicator = nil;
        //self.replacedView = nil;
    }
    //[self dismiss];
}


- (void)setCurrentDeviceOrientation{
#ifndef BAR_ARMV7_SHELL
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIDeviceOrientationUnknown == self.direction) {
            [self setLandscapeMode:UIDeviceOrientationPortrait];
        }else {
            [self setLandscapeMode:self.direction];
        }
    });
#endif
}

- (BOOL) isIPhoneX {
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(818, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2607), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    return NO;
    
}

- (UIView *)replacedView {
    if(!_replacedView){
        if ([self isIPhoneX]) {
            CGRect parentBound = [[[UIApplication sharedApplication] delegate] window].bounds;
            CGFloat topOffset;
            CGFloat bottomOffset;
            if (parentBound.size.height == 812) {//XR和XSMax的bound为414*896
                topOffset = 73;
                bottomOffset = 72;
            } else {
                topOffset = 80;
                bottomOffset = 80;
            }
            CGRect cropRect = CGRectMake(0,topOffset, parentBound.size.width, parentBound.size.height - topOffset - bottomOffset);
            _replacedView = [[UIView alloc] initWithFrame:cropRect];

        }else{
            _replacedView = [[[UIApplication sharedApplication] delegate] window];
        }
    }
    return _replacedView;
}

@end








