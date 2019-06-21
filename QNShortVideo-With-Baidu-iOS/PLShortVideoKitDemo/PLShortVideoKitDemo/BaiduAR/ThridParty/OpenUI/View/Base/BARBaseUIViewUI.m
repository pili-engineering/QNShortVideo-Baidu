//
//  BARBaseUIViewUI.m
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARBaseUIViewUI.h"
#import "BARFaceUtil.h"
#import "BARBaseTextIndicatingView.h"
#import "BARBaseScanView.h"
#import "BARUserGuideWebView.h"
#import "BARBaseImageVideoSwitchView.h"
#import "BARCustomIndicator.h"
#import "UIImage+Load.h"
#import "BARBaseVoiceView.h"
#import "BARBeautyView.h"
#import "BARDecalsView.h"

//#define TOP_OFFSET_Y [[BaiduARSDK getDeviceName] isEqualToString:@"iPhone X"] ? 54.f : 10.f
#define TOP_OFFSET_Y 15.f
#define CameraSwitchBtn_TOP_OFFSET_Y 18.f
#define LightSwitchBtn_TOP_OFFSET_Y 17.f

@implementation BARBaseUIViewUI

#pragma mark - 关闭按钮
//关闭按钮
+ (UIButton*)createCloseBtn:(UIView *)parentView {
    
    UIImage* image = [[self class] closeBtnImage];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = [[self class] closeBtnFrame:image];
    closeBtn.exclusiveTouch = YES;
    [closeBtn setImage:image forState:UIControlStateNormal];
    
    return closeBtn;
}

+ (UIImage *)closeBtnImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_返回_默认"];
}

+ (CGRect)closeBtnFrame:(UIImage *)img {
    CGFloat offsetY = TOP_OFFSET_Y;
    CGFloat spacing = 15.f;
    CGSize size = [img size];
    return  CGRectMake(spacing, offsetY, size.width, size.height);
}

// 推荐按钮
+ (UIButton*)createRecommendBtn:(UIView *)parentView {
    UIImage* image = [[self class] recommendBtnImage];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = [[self class] recommendBtnFrame:parentView];
    closeBtn.exclusiveTouch = YES;
    [closeBtn setImage:image forState:UIControlStateNormal];
    return closeBtn;
}
+ (UIImage *)recommendBtnImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"];
}

+ (CGRect)recommendBtnFrame:(UIView *)parentView {
    CGSize size = CGSizeMake(36, 36);
    CGFloat offsetY = parentView.bounds.size.height - 52.f - size.height;
    CGFloat spacing = 18.f;
    return  CGRectMake(spacing, offsetY, size.width, size.height);
}

//// 推荐视图
//+ (BARRecommendView *)createRecommendView:(UIView *)parentView{
//    CGFloat height = 177 + 30;
//    CGRect frame = CGRectMake(0,
//                              parentView.bounds.size.height - height ,
//                              parentView.bounds.size.width,
//                              height);
//    BARRecommendView *view = [[BARRecommendView alloc] initWithFrame:frame];
//    return view;
//}

// 推荐tip
+ (UIButton *)createRecommendViewTip:(UIView *) parentView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [[self class] recommendViewTipImagePortrait];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
    button.frame = [[self class] recommendViewTipFramePortrait:parentView];
    return button;
}

+ (UIImage *)recommendViewTipImagePortrait {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_R"];
}

+ (CGRect) recommendViewTipFramePortrait:(UIView *)parentView{
    CGFloat width = 100;
    CGFloat height = 38;
    CGFloat left = 14 + 8;
    CGFloat top = parentView.bounds.size.height - height - 48 - 52;
    CGRect frame = CGRectMake(left, top, width, height);
    return frame;
}
+ (UIImage *) recommendViewTipImageLandscapeLeft {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop"];
}

+ (CGRect) recommendViewTipFrameLandscapeLeft:(UIView *)parentView{
    CGFloat width = 100;
    CGFloat height = 38;
    CGFloat left = 14 + 8+ 38 ;
    CGFloat top = parentView.bounds.size.height - height - 48 - 52- 24;
    CGRect frame = CGRectMake(left, top,height , width);
    return frame;
}

+ (UIImage *) recommendViewTipImageLandscapeRight {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_Left"];
}

+ (CGRect) recommendViewTipFrameLandscapeRight:(UIView *)parentView{
    CGFloat width = 100;
    CGFloat height = 38;
    CGFloat left = 14 + 8+ 38 ;
    CGFloat top = parentView.bounds.size.height - height - 48 - 52- 24;
    CGRect frame = CGRectMake(left, top,height , width);
    return frame;
}

#pragma mark - 切换相机按钮
+ (UIButton*)createCameraSwitchBtn:(UIView *)parentView{
    
    UIImage* cameraSwitchImage = [[self class] cameraSwitchBtnImage:@"normal"];
    UIButton *cameraSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraSwitchBtn.frame = [[self class] cameraSwitchBtnFrame:cameraSwitchImage parentView:parentView];
    [cameraSwitchBtn setImage:cameraSwitchImage forState:UIControlStateNormal];
    [cameraSwitchBtn setImage:cameraSwitchImage forState:UIControlStateDisabled];
    cameraSwitchBtn.exclusiveTouch = YES;
    return cameraSwitchBtn;
}

+ (UIImage *)cameraSwitchBtnImage:(NSString*)key {
    if([key isEqualToString:@"normal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_顶部工具条-切换换摄像头"];
    }
    return nil;
}

+ (CGRect)cameraSwitchBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat offsetY = CameraSwitchBtn_TOP_OFFSET_Y;
    CGSize cameraSwitchImageSize = [img size];
    CGFloat rightMargin = 31.0f;
    return CGRectMake(parentView.frame.size.width - cameraSwitchImageSize.width - rightMargin, offsetY, cameraSwitchImageSize.width, cameraSwitchImageSize.height);
}

#pragma mark - 闪光灯按钮
//闪光灯按钮
+ (UIButton*)createLightSwitchBtn:(UIView *)parentView {
    
    UIImage* lightSwitchImage = [[self class] lightSwitchBtnImage:@"close"];
    UIButton *lightSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lightSwitchBtn.frame = [[self class] lightSwitchBtnFrame:lightSwitchImage parentView:parentView];
    [lightSwitchBtn setImage:lightSwitchImage forState:UIControlStateNormal];
//    [lightSwitchBtn setImage:lightSwitchImage forState:UIControlStateDisabled];
    return lightSwitchBtn;
}

+ (UIImage *)lightSwitchBtnImage:(NSString*)key {
    if([key isEqualToString:@"open"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_顶部工具条-闪光灯开"];
    }else if([key isEqualToString:@"close"]){
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_顶部工具条-闪光灯关"];
    }
    return nil;
}

+ (CGRect)lightSwitchBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat offsetY = LightSwitchBtn_TOP_OFFSET_Y;
    CGFloat rightMargin = 88.0f;
    CGSize lightSwitchImageSize = [img size];
    return CGRectMake(parentView.frame.size.width - lightSwitchImageSize.width - rightMargin, offsetY, lightSwitchImageSize.width, lightSwitchImageSize.height);
}

#pragma mark - 截屏按钮
//截屏/录制按钮
+ (UIButton*)createScreenshotBtn:(UIView *)parentView {
    UIImage* screenshotImage = [[self class] screenshotBtnImage:@"videoNormal"];
    UIButton *screenshotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screenshotBtn.frame = [[self class] screenshotBtnFrame:screenshotImage parentView:parentView];
    screenshotBtn.exclusiveTouch = YES;
    [screenshotBtn setImage:screenshotImage forState:UIControlStateNormal];
    [screenshotBtn setImage:[[self class] screenshotBtnImage:@"disable"] forState:UIControlStateDisabled];
    [screenshotBtn setImage:[[self class] screenshotBtnImage:@"videoSelect"] forState:UIControlStateSelected];
    [screenshotBtn setImage:[[self class] screenshotBtnImage:@"click"] forState:UIControlStateHighlighted];
    [screenshotBtn setEnabled:NO];
    return screenshotBtn;
}

//截屏图片
+ (UIImage *)screenshotBtnImage:(NSString*)key {
    
    if([key isEqualToString:@"click"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_拍屏_点击"];
    }else if([key isEqualToString:@"disable"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_拍屏_默认"];
    }else if([key isEqualToString:@"normal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_拍屏_默认"];
    }else if([key isEqualToString:@"videoNormal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_录制_默认"];
    }else if([key isEqualToString:@"videoSelect"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_录制中_边缘"];
    }
    return nil;
}

// 截屏Frame
+ (CGRect)screenshotBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat bottomMargin = 45.f;
    CGSize size = [img size];
    return  CGRectMake((CGRectGetWidth(parentView.bounds) - size.width) / 2, CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
}

// 视频录制图片
+ (UIImage *)videoBtnImage:(NSString*)key {
    return [BARBaseUIViewUI screenshotBtnImage:key];
}

//// 视频录制中图片
//+ (UIImage *)shootingVideoBtnImage:(NSString*)key {
//    return [BARBaseUIViewUI screenshotBtnImage:key];
//}

//// 视频录制中frame
//+ (CGRect)screenshotShootingBtnFrame:(UIImage *)img parentView:(UIView *)parentView{
//    CGFloat bottomMargin = 44;
//    //  CGFloat spacing = 50.f;
//    CGSize size =  CGSizeMake(44.0, 44.0);//[img size];
//    return  CGRectMake((CGRectGetWidth(parentView.bounds) - size.width) / 2, CGRectGetHeight(parentView.bounds) - size.height - bottomMargin, size.width, size.height);
//}

#pragma mark - slam用户指引按钮
// slam用户指引按钮
+ (UIButton*)createUserGuideBtn:(UIView *)parentView {
    UIButton *userGuideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* userGuideImage = [[self class] userGuideImage:@"normal"];
    userGuideBtn.frame = [[self class] userGuideBtnFrame:userGuideImage parentView:parentView];
    [userGuideBtn setImage:userGuideImage forState:UIControlStateNormal];
    [userGuideBtn setImage:[self userGuideImage:@"click"] forState:UIControlStateHighlighted];
    return userGuideBtn;
}

+ (UIImage *)userGuideImage:(NSString*)key {
    if ([key isEqualToString:@"normal"]) {
        return  [UIImage imageWithContentOfFileForBAR:@"BaiduAR_帮助按钮"];
    }
    if ([key isEqualToString:@"click"]) {
        return  [UIImage imageWithContentOfFileForBAR:@"BaiduAR_帮助按钮点击"];
    }
    return nil;
}

+ (CGRect)userGuideBtnFrame:(UIImage*)img parentView:(UIView *)parentView {
    CGFloat offsetY = TOP_OFFSET_Y;
    CGFloat spacing = 15.f;
    CGSize size = [img size];
    return CGRectMake(CGRectGetWidth(parentView.bounds) - size.width - spacing, offsetY, size.width, size.height);
}

#pragma mark - slam重扫按钮
+ (UIButton *)createReplayBtn:(UIView *)parentView {
    UIButton *replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replayBtn.exclusiveTouch = YES;
    UIImage* normal = [[self class] replayBtnImage:@"normal"];
    CGRect frame = [[self class] replayBtnFrame:normal parentView:parentView];
    replayBtn.frame = frame;
    [replayBtn setImage:normal forState:UIControlStateNormal];
    //UIImage* click = [[self class] replayBtnImage:@"click"];
    //[replayBtn setImage:click forState:UIControlStateHighlighted];
    //UIImage* disable = [[self class] replayBtnImage:@"disable"];
    //[replayBtn setImage:disable forState:UIControlStateDisabled];
    return replayBtn;
}

+ (UIButton *)createResacnTip:(UIView *)relevantView{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    UIImage* normal = [[self class] resacnTipImage:@"|"];
    [btn setBackgroundImage:normal forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
    [btn setTitle:BARNSLocalizedString(@"bar_tip_rescan_tip") forState:UIControlStateNormal];
    CGRect frame = [[self class] resacnTipFrame:normal relevantView:relevantView direction:@"|"];
    btn.frame = frame;
    return btn;
}



+ (CGRect)replayBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGFloat leftMargin = 16.f;
    CGSize btnSize = img.size;
    CGFloat bottomMargin = 52.0f;
    CGFloat offsetY = parentView.bounds.size.height - btnSize.height - bottomMargin;
    //上下左右各自扩大15点
    //return CGRectMake(leftMargin-15, offsetY-15, btnSize.width+30, btnSize.height+30);
    
    return CGRectMake(leftMargin, offsetY, btnSize.width, btnSize.height);
}

+ (CGRect)resacnTipFrame:(UIImage *)img relevantView:(UIView *)relevantView direction:(NSString *)direction {
    CGSize btnSize = img.size;
    CGFloat tipy = relevantView.frame.origin.y - img.size.height + 12;
    
    if([direction isEqualToString:@"<-"]){
        return CGRectMake(CGRectGetMinX(relevantView.frame)+15+3, tipy, btnSize.width, btnSize.height);
    }else if([direction isEqualToString:@"->"]){
        return CGRectMake(CGRectGetMinX(relevantView.frame)+15+3, tipy, btnSize.width, btnSize.height);
    }
    else{
        return CGRectMake(CGRectGetMinX(relevantView.frame)+15+3, tipy, btnSize.width, btnSize.height);
    }
}

+ (UIImage *)resacnTipImage:(NSString *)name{
    if ([name isEqualToString:@"<-"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop"];
    }
    if ([name isEqualToString:@"->"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_Left"];
    }
    else{
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_R"];
    }
    return nil;
}

+ (UIImage *)replayBtnImage:(NSString *)name {
    if ([name isEqualToString:@"normal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_重玩_默认"];
    }
//    if ([name isEqualToString:@"click"]) {
//        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_重玩_点击"];
//    }
//    if ([name isEqualToString:@"disable"]) {
//        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_重玩_不可用"];
//    }
    return nil;
}

#pragma mark - 摄像头切换tips
+ (UIButton *)createSwitchCameraTip:(UIView *)relevantView {
    UIButton *switchCameraTip=[UIButton buttonWithType:UIButtonTypeCustom];
    switchCameraTip.userInteractionEnabled = NO;
    UIImage *normal = [[self class] switchCameraTipImage:@"|"];
    [switchCameraTip setBackgroundImage:normal forState:UIControlStateNormal];
    [switchCameraTip setTitle:@"点击切换前置摄像头" forState:UIControlStateNormal];
    [switchCameraTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchCameraTip setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, -5, 5)];
    switchCameraTip.titleLabel.font = [UIFont systemFontOfSize:14];
    switchCameraTip.titleLabel.textAlignment = NSTextAlignmentCenter;
    switchCameraTip.frame = [[self class] switchCameraTipFrame:normal relevantView:relevantView direction:@"|"];
    return switchCameraTip;
}

+ (UIImage *)switchCameraTipImage:(NSString *)name {
    if ([name isEqualToString:@"<"]){
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_横屏_左"];
    } else if ([name isEqualToString:@">"]){
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_横屏_右"];
    } else if ([name isEqualToString:@"|"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_竖屏气泡"];
    } else {
        return nil;
    }
}

+ (CGRect)switchCameraTipFrame:(UIImage *)image relevantView:(UIView *)relevantView direction:(NSString *)direction {
    CGSize btnSize = image.size;
    CGFloat tipy = 28 + (TOP_OFFSET_Y);
    CGFloat tipx = relevantView.center.x - (image.size.width/2);
    
    if ([direction isEqualToString:@"<"]) {
        return CGRectMake(CGRectGetMinX(relevantView.frame)+15+3, tipy, btnSize.width, btnSize.height);
    } else if ([direction isEqualToString:@">"]){
        return CGRectMake(CGRectGetMinX(relevantView.frame)+15+3, tipy, btnSize.width, btnSize.height);
    } else {
        return CGRectMake(tipx , tipy, btnSize.width, btnSize.height);
        
    }
}

#pragma mark - 文字Tip
+ (BARBaseTextIndicatingView *)createTextIndicator:(UIView *)parentView {
    
    BARBaseTextIndicatingView *view = [[BARBaseTextIndicatingView alloc] initWithFrame:parentView.bounds];
    [view setLandscapeMode:UIDeviceOrientationPortrait];
    return view;
}

#pragma mark - 扫描雷达
+ (BARBaseScanView *)createScanView:(UIView *)parentView {
    
    BARBaseScanView *view = [[BARBaseScanView alloc] initWithFrame:parentView.bounds];
    view.userInteractionEnabled = NO;
    return view;
}

#pragma mark - H5页面
#ifdef BAR_FOR_OPENSDK
+ (BARUserGuideWebView *)createUserGuideView:(UIView *)parentView{
    BARUserGuideWebView *view = [[BARUserGuideWebView alloc] initWithFrame:parentView.bounds];
    return view;
}
#endif

#pragma mark - 拍照/录制切换
+ (BARBaseImageVideoSwitchView *) createImageVideoSwitchView:(UIView *)parentView {
    
    BARBaseImageVideoSwitchView *view = [[BARBaseImageVideoSwitchView alloc] initWithFrame:[[self class] imageVideoSwitchViewFrame:parentView]];
    return view;
}

+ (CGRect) imageVideoSwitchViewFrame:(UIView *)parentView {
    CGFloat height = 52;
    CGRect frame = CGRectMake(0, parentView.bounds.size.height - height, parentView.bounds.size.width, height);
    return frame;
}

+ (BARCustomIndicator *)createCustomIndicator:(UIView *)parentView {
    BARCustomIndicator *indicator = [BARCustomIndicator generateIndicator];
    indicator.center = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    return indicator;
}

#pragma mark - 语音界面
+ (BARBaseVoiceView *)createVoiceView:(UIView *)parentView {
    BARBaseVoiceView *voiceView = [[BARBaseVoiceView alloc] init];
    [voiceView setContainer:parentView];
    return voiceView;
}

#pragma mark - 语音按钮

+ (UIButton *)createVoiceBtn:(UIView *)parentView {
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.exclusiveTouch = YES;
    UIImage* normal = [[self class] voiceBtnImage:@"normal"];
    CGRect frame = [[self class] voiceBtnFrame:normal parentView:parentView];
    voiceBtn.frame = frame;
    [voiceBtn setImage:normal forState:UIControlStateNormal];
    return voiceBtn;
}

+ (CGRect)voiceBtnFrame:(UIImage *)img parentView:(UIView *)parentView {
    CGSize btnSize = img.size;
    CGFloat rightMargin = 16.0f;
    CGFloat leftMargin = parentView.bounds.size.width - rightMargin - btnSize.width;
    CGFloat bottomMargin = 52.0f;
    CGFloat offsetY = parentView.bounds.size.height - btnSize.height - bottomMargin;
    //上下左右各自扩大15点
    //return CGRectMake(leftMargin, offsetY-15, btnSize.width+30, btnSize.height+30);
    
    return CGRectMake(leftMargin, offsetY, btnSize.width, btnSize.height);
}

+ (UIImage *)voiceBtnImage:(NSString *)name {
    if ([name isEqualToString:@"listening"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_语音_开启"];
    }
    if ([name isEqualToString:@"normal"]) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_语音_Normal"];
    }
    return nil;
}

+ (UIImage *)voiceTipsImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop"];
}

+ (UIImage *)voiceTipsImageLandscape:(UIDeviceOrientation)oritentation {
    UIImage *img = nil;
    if (UIDeviceOrientationLandscapeLeft == oritentation) {
        img = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_L"];
        return img;
    } else if (UIDeviceOrientationLandscapeRight == oritentation) {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop_Landscape_R"];
    } else {
        return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Pop"];
    }
}

#pragma mark - 上下图标区域背景渐变

//上图标区域背景渐变
+ (UIImageView *)createTopBackgroundShadow:(UIView *)parentView {
    UIImage* image = [[self class] topBackgroundShadowImage];
    UIImageView *topShadowView = [[UIImageView alloc]init];
    topShadowView.image = image;
    topShadowView.frame = [[self class] topBackgroundShadowFrame:image parentView:parentView];
    return topShadowView;
}

+ (UIImage *)topBackgroundShadowImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_渐变_顶部"];
}

+ (CGRect)topBackgroundShadowFrame:(UIImage *)img parentView:(UIView *)parentView{
    CGSize size = [img size];
    return CGRectMake(0, 0, parentView.frame.size.width, size.height);
}

//下图标区域背景渐变
+ (UIImageView *)createBottomBackgroundShadow:(UIView *)parentView {
    UIImage* image = [[self class] bottomBackgroundShadowImage];
    UIImageView *bottomShadowView = [[UIImageView alloc]init];
    bottomShadowView.image = image;
    bottomShadowView.frame = [[self class] bottomBackgroundShadowFrame:image parentView:parentView];
    return bottomShadowView;
}

+ (UIImage *)bottomBackgroundShadowImage {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_渐变_底部"];
}

+ (CGRect)bottomBackgroundShadowFrame:(UIImage *)img parentView:(UIView *)parentView{
    CGSize size = [img size];
    CGFloat offsetY = parentView.frame.size.height - size.height;
    return CGRectMake(0, offsetY, parentView.frame.size.width, size.height);
}

+ (BARBeautyView *)createBeautyView:(UIView *)parentView {
    CGFloat beautyViewH = 156;
    CGFloat beautyViewY = parentView.frame.size.height - beautyViewH;
    BARBeautyView *beautyView = [[BARBeautyView alloc] initWithFrame:CGRectMake(0, beautyViewY, parentView.frame.size.width, beautyViewH)];
    beautyView.hidden = YES;
    return beautyView;
}

+ (BARDecalsView *)createDecalsView:(UIView *)parentView {
    CGFloat decalsViewH = 246;
    CGFloat decalsViewY = parentView.frame.size.height - decalsViewH;
    BARDecalsView *decalsView = [[BARDecalsView alloc] initWithFrame:CGRectMake(0, decalsViewY, parentView.frame.size.width, decalsViewH)];
    decalsView.hidden = YES;
    return decalsView;
}

+ (UIButton *)createDecalsBtn:(UIView *)parentView {
    //以截屏按钮为参照物,以保证垂直居中
    UIImage* screenshotImage = [[self class] screenshotBtnImage:@"videoNormal"];
    CGSize screenshotImageSize = [screenshotImage size];
    CGFloat screenshotBottomMargin = 45.f;
    
    UIButton *decalsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backgroundImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_贴纸"];
    CGFloat leftMargin = 61.0f;
    CGSize decalsImageSize = [backgroundImage size];
    decalsBtn.frame = CGRectMake(leftMargin, parentView.bounds.size.height - screenshotBottomMargin + (screenshotImageSize.height - decalsImageSize.height)/2 - screenshotImageSize.height, decalsImageSize.width, decalsImageSize.height);
    [decalsBtn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    return decalsBtn;
}

+ (UIButton *)createBeautyBtn:(UIView *)parentView {
    //以截屏按钮为参照物,以保证垂直居中
    UIImage* screenshotImage = [[self class] screenshotBtnImage:@"videoNormal"];
    CGSize screenshotImageSize = [screenshotImage size];
    CGFloat screenshotBottomMargin = 45.f;
    
    UIButton * beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backgroundImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_美颜"];
    CGFloat rightMargin = 61.0f;
    CGSize beautyImageSize = [backgroundImage size];
    beautyBtn.frame = CGRectMake(parentView.bounds.size.width - rightMargin - beautyImageSize.width, parentView.bounds.size.height - screenshotBottomMargin + (screenshotImageSize.height - beautyImageSize.height)/2 - screenshotImageSize.height, beautyImageSize.width, beautyImageSize.height);
    [beautyBtn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    return beautyBtn;
}

+ (UIImageView *)createUndetectedFaceImageView:(UIView *)parentView {
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_Undetected"]];
    imgView.frame = CGRectMake((parentView.bounds.size.width - 180) / 2, 190, 180, 180);
    return imgView;
}

+ (UIImageView *)createFaceAlertImageView:(UIView *)parentView {
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.frame = CGRectMake((parentView.bounds.size.width - 180) / 2, 190, 180, 180);
    return imgView;
}

+ (UISwitch *)createResolutionSwitchView:(UIView *)parentView {
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.frame = CGRectMake((parentView.bounds.size.width - 60), 160, 50, 30);
    switchView.on = NO;
    return switchView;
}

@end
