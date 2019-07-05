//
//  BARCustomIndicator.m
//  CustomIndicator
//
//  Created by 雪岑申 on 15/9/30.
//  Copyright © 2015年 雪岑申. All rights reserved.
//

#import "BARCustomIndicator.h"
#import "BARLoadingButton.h"
#import "BARFaceUtil.h"


@interface BARCustomIndicator ()
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) BARLoadingButton* indicator;
@property (assign, nonatomic) BOOL animating;
@end

@implementation BARCustomIndicator

+ (BARCustomIndicator *)generateIndicator{
    BARCustomIndicator *customIndicator = [[BARCustomIndicator alloc] init];
    return customIndicator;
}

- (id)init{
    self = [super init];
    if (self) {
        self.indicator = [[BARLoadingButton alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
        self.indicator.rotatorColor = [UIColor whiteColor];
        self.label = [[UILabel alloc] init];
        self.label.text = BARNSLocalizedString(@"bar_tip_loading");
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.frame = CGRectMake(55, 15, 85, 20.5);
        [self.label sizeToFit];
        self.backgroundColor = [UIColor colorWithWhite:57.0/255.0 alpha:0.8];

        [self addSubview:self.indicator];
        [self addSubview:self.label];
        
        //Hard Coding Frame
        self.frame = CGRectMake(0, 0, 157, 50);
        
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.animating = NO;
        
        [self setLandscapeMode:UIDeviceOrientationPortrait];
        
    }
    return self;
}

//- (void)setCustomIndicatorText:(NSString *)text{
//    self.label.text = text;
//}

- (void)setIndicatorText:(NSString *)text {
    self.label.text = text;
}

- (void)startAnimating{
    [self.indicator startActivity];
    self.animating = YES;
}

- (void)stopAnimating{
    [self.indicator stopActivity];
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.animating = NO;
}

- (BOOL)isAnimating{
    return self.animating;
}

- (void)setLandscapeMode:(UIDeviceOrientation)orientation {
    [self setLandscapeMode:orientation withDuration:0.01];
}

- (void)setPortraitModeWithDuration:(CGFloat)duration
{
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.transform = CGAffineTransformIdentity;
    }];
}

- (void)setLandscapeMode:(UIDeviceOrientation)orientation withDuration:(CGFloat)duration
{
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        __weak typeof (self) weakSelf = self;
        [UIView animateWithDuration:duration animations:^{
            //weakSelf.transform = CGAffineTransformIdentity;
            weakSelf.transform = CGAffineTransformMakeRotation(0.5 * M_PI);
        }];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        __weak typeof (self) weakSelf = self;
        [UIView animateWithDuration:duration animations:^{
            //weakSelf.transform = CGAffineTransformIdentity;
            weakSelf.transform = CGAffineTransformMakeRotation(-0.5 * M_PI);
        }];
    } else {
        [self setPortraitModeWithDuration:duration];
    }
}

@end
