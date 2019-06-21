//
//  BARSlamViewUI.m
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK

#import "BARSlamViewUI.h"
#import "BARGestureGuideView.h"
#import "BARLightsView.h"
#import "BARFaceUtil.h"
#import "UIImage+BARLoad.h"


@implementation BARSlamViewUI

+ (UIButton *)createPlaceModelBtn:(UIView *)parentView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *placeModelBtnImg = [[self class] placeModelBtnImage:@"normal"];
    btn.frame = [[self class] placeModelBtnFrame:placeModelBtnImg parentView:parentView];
    [btn setImage:placeModelBtnImg forState:UIControlStateNormal];
    [btn setImage:[[self class] placeModelBtnImage:@"click"] forState:UIControlStateHighlighted];
    [btn setImage:[[self class] placeModelBtnImage:@"disable"] forState:UIControlStateDisabled];
    return btn;
}

+ (UIImage *)placeModelBtnImage:(NSString *)key {
    if([key isEqualToString:@"click"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_放置按钮点击"];
    }else if([key isEqualToString:@"disable"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_放置按钮不可点击"];
    }else if([key isEqualToString:@"normal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_放置按钮"];
    }
    return nil;
}

+ (CGRect)placeModelBtnFrame:(UIImage *)img parentView:(UIView *)parentView{
    CGFloat bottomMargin = 37.f;
    CGSize size = [img size];
    return  CGRectMake((CGRectGetWidth(parentView.bounds) - size.width) / 2, CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
}

+ (BARLightsView *)createLightsView:(UIView *)parentView {
    BARLightsView *view = [[BARLightsView alloc] init:3];
    view.layer.position = [[self class] lightsViewPosition:parentView];
    return view;
}

+ (UIImageView *)createRotateDeviceTipView:(UIView *)parentView {
    
    UIImage* img = [[self class] rotateDeviceTipImage];
    CGSize size = [img size];
    CGRect frame = CGRectMake(CGRectGetWidth(parentView.bounds)/2 - size.width/2, CGRectGetHeight(parentView.bounds)/2 - size.height/2, size.width, size.height);
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.image = img;
    
    return view;
}

+ (UIImage *)rotateDeviceTipImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_旋转提示"];
}

+ (CGPoint)lightsViewPosition:(UIView *)parentView {
    CGFloat offsetX = 24.f;
    return CGPointMake(offsetX, CGRectGetHeight(parentView.bounds)/2);
}


+ (BARGestureGuideView *)createGestureGuideView:(UIView *)parentView {
    BARGestureGuideView *view = [[BARGestureGuideView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(parentView.frame), CGRectGetWidth(parentView.frame))];
    view.layer.position = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    return view;
}


@end

#endif
