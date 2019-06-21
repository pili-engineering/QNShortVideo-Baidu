//
//  BARCustomIndicator.h
//  CustomIndicator
//
//  Created by 雪岑申 on 15/9/30.
//  Copyright © 2015年 雪岑申. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARCustomIndicator : UIView
+ (BARCustomIndicator *)generateIndicator;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)setIndicatorText:(NSString *)text;
- (void)setLandscapeMode:(UIDeviceOrientation)orientation;
- (void)setLandscapeMode:(UIDeviceOrientation)orientation withDuration:(CGFloat)duration;
//- (void)setCustomIndicatorText:(NSString *)text;
@end
