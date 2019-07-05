//
//  BARBaseUIViewUI.h
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BARBaseTextIndicatingView;
@class BARBaseScanView;
@class BARUserGuideWebView;
@class BARBaseImageVideoSwitchView;
@class BARCustomIndicator;
//@class BARRecommendView;
@class BARBaseVoiceView;
@class BARBeautyView,BARDecalsView;
@interface BARBaseUIViewUI : NSObject

+ (UIButton*)createCloseBtn:(UIView *)parentView;

+ (UIButton*)createRecommendBtn:(UIView *)parentView;

+ (UIButton*)createRecommendViewTip:(UIView *)parentView;

//+ (BARRecommendView *)createRecommendView:(UIView *)parentView;

+ (UIButton*)createLightSwitchBtn:(UIView *)parentView;

+ (UIButton*)createCameraSwitchBtn:(UIView *)parentView;

+ (UIButton*)createScreenshotBtn:(UIView *)parentView;

+ (UIButton*)createUserGuideBtn:(UIView *)parentView;

+ (UIButton*)createReplayBtn:(UIView *)parentView;

+ (UIButton *)createSwitchCameraTip:(UIView *)parentView;

+ (BARBaseVoiceView *)createVoiceView:(UIView *)parentView;
+ (UIButton *)createVoiceBtn:(UIView *)parentView;
+ (UIButton *)createResacnTip:(UIView *)relevantView;
+ (UIImage *)resacnTipImage:(NSString *)name;
+ (BARBaseTextIndicatingView *)createTextIndicator:(UIView *)parentView;
+ (CGRect)resacnTipFrame:(UIImage *)img relevantView:(UIView *)relevantView direction:(NSString *)direction;
+ (BARBaseScanView *)createScanView:(UIView *)parentView;

#ifdef BAR_FOR_OPENSDK
+ (BARUserGuideWebView *)createUserGuideView:(UIView *)parentView;
#endif
+ (BARBaseImageVideoSwitchView *) createImageVideoSwitchView:(UIView *)parentView;

+ (BARCustomIndicator *)createCustomIndicator:(UIView *)parentView;


//
//+ (UIImage *)shootingVideoBtnImage:(NSString*)key;
+ (UIImage *)screenshotBtnImage:(NSString*)key;
//+ (CGRect)screenshotShootingBtnFrame:(UIImage *)img parentView:(UIView *)parentView;
+ (CGRect)screenshotBtnFrame:(UIImage *)img parentView:(UIView *)parentView;
+ (UIImage *)videoBtnImage:(NSString*)key;
+ (UIImage *)lightSwitchBtnImage:(NSString*)key;
+ (UIImage *)voiceBtnImage:(NSString *)name ;
+ (UIImage *)voiceTipsImage;
+ (UIImage *)voiceTipsImageLandscape:(UIDeviceOrientation)oritentation;
+ (UIImage *)switchCameraTipImage:(NSString *)name;

+ (UIImage *) recommendViewTipImageLandscapeLeft;
+ (UIImage *) recommendViewTipImagePortrait;
+ (UIImage *) recommendViewTipImageLandscapeRight;
+ (CGRect) recommendViewTipFrameLandscapeLeft:(UIView *)parentView;
+ (CGRect) recommendViewTipFrameLandscapeRight:(UIView *)parentView;
+ (CGRect) recommendViewTipFramePortrait:(UIView *)parentView;
+ (UIImageView *)createTopBackgroundShadow:(UIView *)parentView;
+ (UIImageView *)createBottomBackgroundShadow:(UIView *)parentView;


//face
+ (BARBeautyView *)createBeautyView:(UIView *)parentView;
+ (BARDecalsView *)createDecalsView:(UIView *)parentView;
+ (UIButton *)createDecalsBtn:(UIView *)parentView;
+ (UIButton *)createBeautyBtn:(UIView *)parentView;
+ (UIImageView *)createUndetectedFaceImageView:(UIView *)parentView;
+ (UIImageView *)createFaceAlertImageView:(UIView *)parentView;


// 1080p
+ (UISwitch *)createResolutionSwitchView:(UIView *)parentView;
@end
