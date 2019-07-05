//
//  BARBaseView.h
//  ARSDK
//
//  Created by LiuQi on 16/10/21.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BARBaseTextIndicatingView.h"
#import "BARBaseScanView.h"
#import "BARBaseImageVideoSwitchView.h"
#import "BARAlert.h"
#import "BARCustomIndicator.h"
#import "BARUnauthorizedView.h"
#import "BARBaseVoiceView.h"
#import "BARBeautyView.h"
#import "BARDecalsView.h"

typedef enum{
    BARClickActionClose,
    BARClickActionLightSwitch,
    BARClickActionCameraSwitch,
    BARClickActionScreenshot,
    BARClickActionURL,
    BARClickActionNativeURL,
    BARClickActionO2OURl,
    BARClickActionReScan,
    BARClickActionShootVideoStart,
    BARClickActionShootVideoStop,
    BARActionChangeCameraPreviewToBARImage,
    BARClickActionVoice,
    BARActionChangeCameraPreviewToGPUImage,
    BARClickRecommendBgView,
    BARClickActionSwitchToSameSearch,
    BARClickActionDecals,
    BARClickActionBeauty,
    BARClickActionTypeFilterSwitch,
    BARClickActionTypeBeautySwitch,
    BARClickActionTypeFilterAdjust,
    BARClickActionTypeCancelFilter,
    BARClickActionTypeDecalsSwitch,
    BARClickActionTypeCancelDecals,
    BARClickActionTypeCloseFace,
    BARClickActionTypeResetBeauty,
    BARClickActionTypeCancelBeauty,
    BARClickActionTypeSwitchResolution
} BARClickActionType;


@interface BARBaseView : UIView

typedef void (^BARBaseUIViewClickEventHandler)(BARClickActionType action,NSDictionary* data);

typedef void (^ShootVideoCompletionHandler)(void);

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, copy) BARBaseUIViewClickEventHandler clickEventHandler;
@property (nonatomic, assign) UIDeviceOrientation currentActualOrientation;
@property (nonatomic, strong) BARCustomIndicator* customLoadingView;
@property (nonatomic, assign) BOOL shootingVideo;
@property (nonatomic, assign) BOOL videoSwitchViewIsSwitching;//正在切换录制or截屏
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong, readonly) UIButton *cameraSwitchBtn;
@property (nonatomic, strong, readonly) UIButton *lightSwitchBtn;
@property (nonatomic, strong) UIButton* moreBtn;
@property (nonatomic, strong, readonly) UIButton* screenshotBtn;
@property (nonatomic, strong) UIImageView *screenshotRedImageView;
@property (nonatomic, strong) UIView* screenshotBlur;
//@property (nonatomic, strong, readonly) UIButton* userGuideBtn;
@property (nonatomic, strong, readonly) UIButton* replayBtn;
@property (nonatomic, strong, readonly) UIButton* replayTips;
@property (nonatomic, strong) UIButton *switchCameraTip;
@property (nonatomic, strong) UIImageView *topShadowBg;
@property (nonatomic, strong) UIImageView *bottomShadowBg;

@property (nonatomic, strong) UIButton* voiceBtn;
@property (nonatomic, strong) UIButton* voiceTipsView;
@property (nonatomic, strong) BARBaseVoiceView *voiceView;
@property (nonatomic, strong, readonly) BARBaseTextIndicatingView* textIndicator;
@property (nonatomic, strong) BARBaseScanView* scanView;
//@property (nonatomic, strong, readonly) BARUserGuideWebView* userGuideView;
@property (nonatomic, strong, readonly) BARBaseImageVideoSwitchView *imageVideoSwitchView;

@property (nonatomic, copy)  ShootVideoCompletionHandler shootVideoCompletionHandler;
@property (nonatomic, strong) CAShapeLayer *shootVideoPercentLayer;
@property (nonatomic, strong) CAShapeLayer *shootVideoAllPercentLayer;//白色圆环
@property (nonatomic, strong) CAShapeLayer *shootScaleLayer;

@property (nonatomic, strong) NSMutableArray *hiddenViews;
@property (nonatomic, strong) NSMutableArray *alphaViews;

@property (nonatomic, strong) NSMutableArray *topHiddenButtons;
@property (nonatomic, strong) NSMutableArray *topAlphaButtons;

@property (nonatomic, assign) NSTimeInterval userGuideTimeInterval;
@property (nonatomic, assign) NSTimeInterval screenShotTimeInterval;
@property (nonatomic, assign) NSTimeInterval cameraSwitchTimeInterval;

@property (nonatomic, strong) UIView *recommendBgView;
@property (strong, nonatomic) UIImageView* alphaImageView;
@property (strong, nonatomic) UIImage* alphaImage;

//Face
@property (nonatomic, strong) BARDecalsView *decalsView;
@property (nonatomic, strong) BARBeautyView *beautyView;
@property (nonatomic, strong) UIButton *decalsBtn;
@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) UIImageView *undetectedFaceImgView;
@property (nonatomic, strong) UIImageView *faceAlertImgView;

//1080P
@property (nonatomic, strong) UISwitch *resolutionSwitch;

@property (nonatomic, strong) UILabel *triggerLabel;

- (id)initWithFrame:(CGRect)frame;

- (void)addFaceUI;

/*camer设置前置*/
- (void)setCameraFront:(BOOL)front;

- (void)showCameraSwitch;
- (void)hideCameraSwitch;

/*设置闪光灯按钮状态*/
- (void)setLightSwitchBtnOn:(BOOL)turnOn;
/*弹出菜单选中事件*/
- (void)menuPopoverSelectItemAtIndex:(NSInteger)selectedIndex;

/*按钮点击事件*/
- (void)lightSwitchBtnClick:(UIButton *)sender;
- (void)closeViewBtnClick:(UIButton *)sender;
- (void)cameraSwitchBtnClick:(UIButton *)sender;
- (void)screenshotBtnClick:(UIButton *)sender;
/*设置横竖屏*/
- (void)setLandscapeMode:(UIDeviceOrientation)direction;

- (void)setLandscapeModeNoAnimation:(UIDeviceOrientation)direction;

/*旋转UI界面*/
- (void)rotationUI:(float)angle;

/*截屏*/
- (UIImage*)screenshot;

/*显示正在加载*/
- (void)showIndicator;

/*隐藏正在加载*/
- (void)hideIndicator;

/*显示webview引导页面*/
//- (void)showUserGuide;

/*隐藏webview引导页面*/
//- (void)hideUserGuide;

/*显示扫描页面*/
- (void)startScanAnimation;

/*隐藏扫描页面*/
- (void)stopScanAnimation;

/*实际朝向*/
- (void)setActuallyOrientation:(UIDeviceOrientation)direction;

/*退到后台*/
- (void)willEnterBackground;

/*旋转子视图*/
- (void)rotateSubView:(UIView *)subView to:(UIInterfaceOrientation)orientation;

/*弹出提示框*/
- (void)showAlert:(NSString *)msg cancelBtnTitle:(NSString *)cancel otherBtnTitle:(NSString *)other cancelBtnBlock:(BARAlertCancelEventBlock) cancelBlock   otherBtnBlock:(BARAlertOtherEventBlock)otherBlock;

/*开始录屏*/
- (void)startShootVideoWithComplitionHandler:(void (^)(void))handler;

/*结束录屏*/
- (void)stopShootVideo;

/*应该被隐藏的views*/
- (NSArray *)shouldHiddenViews;

/*顶部的views*/
- (NSArray *)topButtons;

/*底部的views*/
- (NSArray *)bottomButtons;

/*隐藏所有的按钮*/
- (void)hideAllViews;

/*显示所有的按钮*/
- (void)showAllViews;

/*隐藏拍摄按钮*/
- (void)hideShotButton;

/*显示拍摄按钮*/
- (void)showShotButton;

/*隐藏顶部按钮*/
- (void)hideTopButtons;

/*显示顶部按钮*/
- (void)showTopButtons;

/*设置语音按钮状态*/
- (void)voiceBtnTurnOn:(BOOL)on ;
- (BOOL)isVoiceBtnOpened ;
- (void)openHelpURL:(id)url;

- (void)clearTips;

- (BOOL)canStartRecord;

- (void)setRecordButtonAndSwitchViewEnable:(BOOL)enable;

+ (BARUnauthorizedView *)createUnauthorizedView:(UIView *)parentView;
@end

