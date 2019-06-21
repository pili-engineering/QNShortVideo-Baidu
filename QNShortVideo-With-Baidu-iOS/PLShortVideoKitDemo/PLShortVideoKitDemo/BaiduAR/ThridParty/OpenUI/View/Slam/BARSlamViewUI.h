//
//  BARSlamViewUI.h
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#ifdef BAR_FOR_OPENSDK
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BARGestureGuideView;
@class BARLightsView;
@interface BARSlamViewUI : NSObject

+ (UIButton *)createPlaceModelBtn:(UIView *)parentView;
+ (BARLightsView *)createLightsView:(UIView *)parentView;
+ (UIImageView *)createRotateDeviceTipView:(UIView *)parentView;
+ (BARGestureGuideView *)createGestureGuideView:(UIView *)parentView;

@end
#endif
