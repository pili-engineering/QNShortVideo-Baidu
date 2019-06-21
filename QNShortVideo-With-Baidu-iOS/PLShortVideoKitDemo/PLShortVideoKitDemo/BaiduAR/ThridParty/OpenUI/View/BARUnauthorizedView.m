//
//  BARUnauthorizedView.m
//  ARSDK
//
//  Created by LiuQi on 15/8/20.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "BARUnauthorizedView.h"
#import "BARFaceUtil.h"
#import "BARBaseUIViewUI.h"
#import "UIImage+Load.h"

#define UNAUTHORIZEDVIEW_WIDTH        300
#define UNAUTHORIZEDVIEW_HEIGHT       188
#define UNAUTHORIZEDVIEW_RADIUS       6.0f
#define UNAUTHORIZEDVIEW_ALPHA        1.0f
#define UNAUTHORIZEDVIEW_TITLESIZE    18.0f
#define UNAUTHORIZEDVIEW_CONTETNTSIZE 16.0f

@implementation BARUnauthorizedView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame])
    {
        self.backgroundColor = [self RGBColorFromHexString:@"#000000" alpha:UNAUTHORIZEDVIEW_ALPHA];
        
        CGFloat leftMargin = (self.bounds.size.width - UNAUTHORIZEDVIEW_WIDTH)/2;
        CGFloat topMargin = (self.bounds.size.height - UNAUTHORIZEDVIEW_HEIGHT)/2;
        
        UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, topMargin, UNAUTHORIZEDVIEW_WIDTH, UNAUTHORIZEDVIEW_HEIGHT)];
        alertView.backgroundColor = [self RGBColorFromHexString:@"#FFFFFF" alpha:UNAUTHORIZEDVIEW_ALPHA];
        alertView.layer.cornerRadius = UNAUTHORIZEDVIEW_RADIUS;
        [self addSubview:alertView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [self RGBColorFromHexString:@"#333333" alpha:UNAUTHORIZEDVIEW_ALPHA];
        titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Light" size:UNAUTHORIZEDVIEW_TITLESIZE];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = BARNSLocalizedString(@"bar_tip_open_camera");
        [alertView addSubview:titleLabel];
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:300.0f].active = true;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0f].active = true;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = true;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0 constant:16.0f].active = true;
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [self RGBColorFromHexString:@"#666666" alpha:UNAUTHORIZEDVIEW_ALPHA];
        contentLabel.font = [UIFont fontWithName:@"PingFang-SC-Light" size:UNAUTHORIZEDVIEW_CONTETNTSIZE];
        contentLabel.numberOfLines = 3;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.text = BARNSLocalizedString(@"bar_tip_set_camera_authority");
        [contentLabel setContentMode:UIViewContentModeTop];
        [alertView addSubview:contentLabel];
        contentLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        [NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:25.0].active = true;
        [NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-25.0].active = true;
        [NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:12.0f].active = true;
        //         [NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-67.0f].active = true;
        
        UIButton * setButton = [UIButton buttonWithType:UIButtonTypeCustom];
        setButton.backgroundColor = [self RGBColorFromHexString:@"#3c76ff" alpha:UNAUTHORIZEDVIEW_ALPHA];
        [setButton setTitle:BARNSLocalizedString(@"bar_tip_goto_set") forState:UIControlStateNormal];
        setButton.layer.cornerRadius = UNAUTHORIZEDVIEW_RADIUS;
        [setButton addTarget:self action:@selector(gotoSetAuthor:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:setButton];
        
        setButton.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:setButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = true;
        [NSLayoutConstraint constraintWithItem:setButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-14.0].active = true;
        [NSLayoutConstraint constraintWithItem:setButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:272.0].active = true;
        [NSLayoutConstraint constraintWithItem:setButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0].active = true;
        
        UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* touchImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_权限_关闭按钮_按下态"];
        UIImage* normalImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_权限_关闭按钮_正常态"];
        
        [closeButton setBackgroundImage:touchImage forState:UIControlStateSelected];
        [closeButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        
        closeButton.layer.cornerRadius = UNAUTHORIZEDVIEW_RADIUS;
        [closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:closeButton];
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = true;
        [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0].active = true;
        [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:16.0].active = true;
        [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:16.0].active = true;
        
        [self createBackButton];
    }
    return self;
}

- (void)createBackButton {
    
    UIButton * backButton = [BARBaseUIViewUI createCloseBtn:self];
    backButton.userInteractionEnabled = NO;
    [self addSubview:backButton];
    
//    UIButton * lightSwitchButton = [BARBaseUIViewUI createLightSwitchBtn:self];
//    lightSwitchButton.userInteractionEnabled = NO;
//    [self addSubview:lightSwitchButton];
    
//    UIButton * moreButton = [BARBaseUIViewUI createMoreBtn:self parentView:self];
//    UIImage *moreImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_顶部工具条-更多"];
//    [moreButton setImage:moreImage forState:UIControlStateNormal];
//    moreButton.userInteractionEnabled = NO;
//    [self addSubview:moreButton];
}

- (void)closeButtonClick:(id)sender {
    if (self.closeEvent) {
        self.closeEvent();
    }
}

- (void)gotoSetAuthor:(id)sender {
    if (self.goSetEvent) {
        self.goSetEvent();  
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha {
    if ([aHexStr isKindOfClass:[NSString class]] && aHexStr
        && aHexStr.length > 6) // #rrggbb 大小写字母及数字
    {
        int nums[6] = {0};
        for (int i = 1; i < MIN(7, [aHexStr length]); i++) // 第一个字符是“＃”号
        {
            int asc = [aHexStr characterAtIndex:i];
            if (asc >= '0' && asc <= '9') // 数字
                nums[i - 1] = [aHexStr characterAtIndex:i] - '0';
            else if(asc >= 'A' && asc <= 'F') // 大写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'A' + 10;
            else if(asc >= 'a' && asc <= 'f') // 小写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'a' + 10;
            else
                return [UIColor whiteColor];
        }
        float rValue = (nums[0] * 16 + nums[1]) / 255.0f;
        float gValue = (nums[2] * 16 + nums[3]) / 255.0f;
        float bValue = (nums[4] * 16 + nums[5]) / 255.0f;
        UIColor *rgbColor = [UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aAlpha];
        return rgbColor;
    }
    
    return [UIColor blackColor]; // 默认黑色
}
@end

