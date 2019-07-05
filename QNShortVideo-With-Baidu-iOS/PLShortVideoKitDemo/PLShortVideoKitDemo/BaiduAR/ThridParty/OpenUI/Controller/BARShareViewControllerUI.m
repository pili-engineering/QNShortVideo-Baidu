//
//  BARShareViewControllerUI.m
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARShareViewControllerUI.h"
#import "BARFaceUtil.h"
#import "UIImage+Load.h"


@implementation BARShareViewControllerUI


+ (UIButton *)createCloseBtn:(UIView *)parentView {
//    UIImage *imageHighLight = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_关闭按钮点击"];
    UIImage *imageNormal = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_关闭按钮"];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = [[self class] closeBtnFrame:imageNormal parentView:parentView];
    [closeBtn setImage:imageNormal forState:UIControlStateNormal];
//    [closeBtn setImage:imageNormal forState:UIControlStateDisabled];
    
    return closeBtn;

}

+ (UIButton *)createShareBtn:(UIView *)parentView {
//    UIImage *imageHighLight = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_分享点击"];
    //UIImage *imageNormal = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_分享默认"];
    UIImage *imageNormal = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_分享默认"];
    //UIImage *imageNormal = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_分享默认"];
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = [[self class ] shareBtnFrame:imageNormal parentView:parentView];
    [shareBtn setImage:imageNormal forState:UIControlStateNormal];
//    [shareBtn setImage:imageHighLight forState:UIControlStateHighlighted];
    return shareBtn;
}

+ (UIButton *)createSaveBtn:(UIView *)parentView {
//    UIImage *imageHighLight = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_保存按钮点击"];
    UIImage *imageNormal = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_保存按钮"];
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = [[self class ]saveBtnFrame:imageNormal parentView:parentView];
    [saveBtn setImage:imageNormal forState:UIControlStateNormal];
//    [saveBtn setImage:imageNormal forState:UIControlStateDisabled];
    
    return saveBtn;
}

//+ (CGRect)backBtnFrame:(UIImage *)img {
//    CGFloat offsetY = 10.f;
//    CGFloat spacing = 15.f;
//    CGSize backImageSize = [img size];
//    return CGRectMake(spacing, offsetY, backImageSize.width, backImageSize.height);
//}

+ (CGRect)shareBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat bottomMargin = 37.f;
    CGSize  size = [img size];
    return  CGRectMake((CGRectGetWidth(parentView.bounds) - size.width) / 2, CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
}

+ (CGRect)closeBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat leftMargin = 28.f;
    CGFloat bottomMargin = 28.f;
    CGSize size = [img size];
    return  CGRectMake(leftMargin, CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
}

+ (CGRect)saveBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat rightMargin = 28.f;
    CGFloat bottomMargin = 28.f;
    CGSize size = [img size];
    return  CGRectMake((CGRectGetWidth(parentView.bounds) - size.width -rightMargin), CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
}

@end
