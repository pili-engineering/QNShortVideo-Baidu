//
//  BARBaseUIView.m
//  ARSDK
//
//  Created by LiuQi on 16/10/21.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BARBaseView.h"
//#import "BARSDKBasicConfig.h"
//#import "BARDeviceMotionManager.h"
//#import "BARGlobalMacroDefs.h"
//#import "BARStatsManager.h"
//#import "BARVibrateMgr.h"
//#import "BARUtils.h"
//#import "BARAudioInstance.h"
#import "BARBaseUIViewUI.h"
#import "UIImage+Load.h"
#import "BARBaseView+ARLogic.h"
@interface BARBaseView ()<BARBaseImageVideoSwitchViewDelegate, CAAnimationDelegate>

@property (nonatomic, copy) NSString *opensdkHelpUrl;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation BARBaseView

@synthesize lightSwitchBtn = _lightSwitchBtn;
@synthesize screenshotBtn = _screenshotBtn;
//@synthesize userGuideBtn = _userGuideBtn;
@synthesize replayBtn = _replayBtn;
@synthesize cameraSwitchBtn = _cameraSwitchBtn;
@synthesize textIndicator = _textIndicator;
//@synthesize userGuideView = _userGuideView;
@synthesize imageVideoSwitchView = _imageVideoSwitchView;
@synthesize replayTips = _replayTips;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        UIDeviceOrientation direction = [BaiduARSDK currentOrientation];
        [self setLandscapeMode:UIDeviceOrientationPortrait];
        [self loadUIView];
    }
    return self;
}

#pragma mark  - View Stack

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

- (void)loadUIView {
    [self addBasicUI];
}

- (void)addBasicUI{
    [self addSubview:[self closeBtn]];
    [self addSubview:[self lightSwitchBtn]];
//    [self addSubview:[self screenshotBlur]];
    [self addSubview:[self screenshotBtn]];
    [self addSubview:[self imageVideoSwitchView]];
    [self addSubview:[self cameraSwitchBtn]];
    [self addSubview:[self voiceBtn]];
    [self addSubview:[self topShadowBg]];
    [self addSubview:[self bottomShadowBg]];
    [self addSubview:[self resolutionSwitch]];
    
    self.screenshotBlur.hidden = YES;
    self.screenshotBtn.hidden = YES;
    self.imageVideoSwitchView.hidden = YES;
    self.cameraSwitchBtn.hidden = YES;

    self.textIndicator.hidden = true;
    [self addSubview:[self textIndicator]];
    [self insertSubview:[self scanView] atIndex:0];
}

- (void)addFaceUI {
    [self addSubview:[self decalsBtn]];
    [self addSubview:[self beautyBtn]];
    [self addSubview:[self beautyView]];
    [self addSubview:[self decalsView]];
    [self addSubview:[self undetectedFaceImgView]];
    [self addSubview:[self faceAlertImgView]];
    [self addSubview:[self triggerLabel]];
}

#pragma mark - UI控件

- (void)dealloc
{
    self.shootVideoCompletionHandler = nil;
    self.screenshotRedImageView  = nil;
    self.screenshotBlur = nil;
    self.voiceBtn = nil;
    self.voiceTipsView = nil;
    if(self.shootScaleLayer){
        self.shootScaleLayer = nil;
    }
    
}

- (void)setupDisplayLink {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateRender)];
        self.displayLink.frameInterval = 60 / 60;
        [self.displayLink  addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)releaseDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateRender {
    
}

- (void)setShootingVideo:(BOOL)shootingVideo {
    _shootingVideo = shootingVideo;
}

- (UIButton*)closeBtn
{
    if(nil == _closeBtn) {
        _closeBtn = [BARBaseUIViewUI createCloseBtn:self];
        [_closeBtn addTarget:self action:@selector(closeViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton*)lightSwitchBtn
{
    if(nil == _lightSwitchBtn)  {
        _lightSwitchBtn = [BARBaseUIViewUI createLightSwitchBtn:self];
        [_lightSwitchBtn addTarget:self action:@selector(lightSwitchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightSwitchBtn;
}

- (UIButton*)cameraSwitchBtn {
    if(nil == _cameraSwitchBtn) {
        _cameraSwitchBtn = [BARBaseUIViewUI createCameraSwitchBtn:self];
        [_cameraSwitchBtn addTarget:self action:@selector(cameraSwitchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraSwitchBtn;
}

- (UIButton *)switchCameraTip {
    if (_switchCameraTip == nil) {
        _switchCameraTip = [BARBaseUIViewUI createSwitchCameraTip:self.cameraSwitchBtn];
    }
    return _switchCameraTip;
}

- (UIButton*)screenshotBtn {
    if(nil == _screenshotBtn) {
        _screenshotBtn = [BARBaseUIViewUI createScreenshotBtn:self];
        [_screenshotBtn addTarget:self action:@selector(screenshotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addTranslucentScaleLayer:self.screenshotBtn];
        
        UIImageView *red = [self screenshotRedImageView];
        UIView *redContainer = [[UIView alloc] initWithFrame:_screenshotBtn.bounds];
        redContainer.clipsToBounds = YES;
        redContainer.userInteractionEnabled = NO;
        [redContainer addSubview:red];
        [_screenshotBtn addSubview:redContainer];
        self.screenshotRedImageView.hidden = YES;
        
    }
    return _screenshotBtn;
}

- (UIView *)screenshotBlur {
    if(!_screenshotBlur){
        //  创建需要的毛玻璃特效类型
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //  毛玻璃view 视图
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //添加到要有毛玻璃特效的控件中
        effectView.frame = CGRectMake((self.bounds.size.width - 58)/2, self.bounds.size.height - 58 - 41, 58, 58);
        effectView.layer.cornerRadius = 29;
        effectView.clipsToBounds = YES;
        //effectView.alpha = 0.4;
        _screenshotBlur = effectView;
        _screenshotBlur.hidden = YES;
    }
    return _screenshotBlur;
}

- (UIImageView *)screenshotRedImageView {
    if(_screenshotRedImageView  == nil){
        UIImage *redImage =[UIImage imageWithContentOfFileForBAR:@"BaiduAR_拍屏_录制红按钮"];
        UIImage *circleImage =[UIImage imageWithContentOfFileForBAR:@"BaiduAR_录制中_边缘"];
        CGSize redImageSize = [redImage size];
        CGSize parentSize = [circleImage size];
        CGFloat redWidth = redImageSize.width;
        CGFloat parentWidth = parentSize.width;
        CGFloat pareentHeight = parentSize.height;
        CGFloat bottomMargin = (pareentHeight - redWidth)/2;
        
        CGRect redFrame =   CGRectMake((parentWidth - redWidth) / 2, pareentHeight -redWidth - bottomMargin, redWidth, redWidth);
        
        _screenshotRedImageView = [[UIImageView alloc] initWithFrame:redFrame];
        _screenshotRedImageView.contentMode = UIViewContentModeScaleToFill;
        _screenshotRedImageView.clipsToBounds = YES;
        _screenshotRedImageView.image = redImage;
    }
    return _screenshotRedImageView;
}

- (UIButton *)replayBtn {
    if (_replayBtn == nil) {
        _replayBtn = [BARBaseUIViewUI createReplayBtn:self];
    }
    return _replayBtn;
}

- (UIButton *)replayTips{
    if(!_replayTips){
        _replayTips = [BARBaseUIViewUI createResacnTip:self.replayBtn];
    }
    return _replayTips;
}

- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [BARBaseUIViewUI createVoiceBtn:self];
        _voiceBtn.hidden = YES;
        [_voiceBtn addTarget:self action:@selector(voiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

- (BOOL)isVoiceBtnOpened {
    return _voiceBtn.selected;
}

- (void)voiceBtnTurnOn:(BOOL)on {
    if (on) {
        [_voiceBtn setImage:[BARBaseUIViewUI voiceBtnImage:@"listening"] forState:UIControlStateNormal];
    }else {
        [_voiceBtn setImage:[BARBaseUIViewUI voiceBtnImage:@"normal"] forState:UIControlStateNormal];
    }
    
    _voiceBtn.selected = on;
}

- (UIButton *)voiceTipsView {
    if (!_voiceTipsView) {
        
        _voiceTipsView = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [BARBaseUIViewUI voiceTipsImage];
        
        [_voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
        
        _voiceTipsView.titleLabel.font = [UIFont systemFontOfSize:14];
        [_voiceTipsView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
        
        CGRect frame = CGRectZero;
        frame.origin.y = self.voiceBtn.frame.origin.y - img.size.height - 2;
        frame.origin.x = self.bounds.size.width - 18 - img.size.width;
        frame.size = img.size;
        _voiceTipsView.frame = frame;
    }
    return _voiceTipsView;
}


- (BARBaseTextIndicatingView *)textIndicator {
    if (_textIndicator == nil) {
        _textIndicator = [BARBaseUIViewUI createTextIndicator:self];
    }
    return _textIndicator;
}

- (BARBaseScanView *)scanView {
    if (_scanView == nil) {
        _scanView = [BARBaseUIViewUI createScanView:self];
        _scanView.hidden = YES;
    }
    return _scanView;
}

- (BARBaseImageVideoSwitchView *) imageVideoSwitchView {
    if(_imageVideoSwitchView == nil){
        _imageVideoSwitchView = [BARBaseUIViewUI createImageVideoSwitchView:self];
        _imageVideoSwitchView.delegate = self;
    }
    return _imageVideoSwitchView;
}

- (BARBaseVoiceView *)voiceView {
    if (_voiceView == nil) {
        _voiceView = [BARBaseUIViewUI createVoiceView:self.superview];
    }
    return _voiceView;
}

- (BARDecalsView *)decalsView {
    if (!_decalsView) {
        _decalsView = [BARBaseUIViewUI createDecalsView:self.superview];
        __weak typeof(self)weakSelf = self;
        _decalsView.changeDecalsBlock = ^(NSInteger index) {
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeDecalsSwitch, @{@"index":@(index)});
            }
        };
        _decalsView.hideDecalsBlock = ^{
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeCloseFace, nil);
            }
        };
        _decalsView.cancelDecalsBlock = ^(NSInteger index){
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeCancelDecals, @{@"index":@(index)});
            }
        };
    }
    return _decalsView;
}

- (BARBeautyView *)beautyView {
    if (!_beautyView) {
        _beautyView = [BARBaseUIViewUI createBeautyView:self.superview];
        __weak typeof(self)weakSelf = self;
        _beautyView.changeFilterBlock = ^(NSInteger index) {
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeFilterSwitch, @{@"index":@(index)});
            }
        };
        _beautyView.changeBeautyBlock = ^(NSString *beauty) {
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeBeautySwitch, @{@"beauty":beauty});
            }
        };
        _beautyView.changeSliderValueBlock = ^(CGFloat value, NSString *title) {
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeFilterAdjust, @{@"value":@(value),@"title":title});
            }
        };
        _beautyView.hideBeautyBlock = ^{
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeCloseFace, nil);
            }
        };
        _beautyView.cancelFilterBlock = ^{
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeCancelFilter, nil);
            }
        };
        _beautyView.resetBeautyBlock = ^{
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeResetBeauty, nil);
            }
        };
        _beautyView.cancelBeautyBlock = ^{
            if (weakSelf.clickEventHandler) {
                weakSelf.clickEventHandler(BARClickActionTypeCancelBeauty, nil);
            }
        };
    }
    return _beautyView;
}

- (UIButton *)decalsBtn {
    if (!_decalsBtn) {
        _decalsBtn = [BARBaseUIViewUI createDecalsBtn:self.superview];
        [_decalsBtn addTarget:self action:@selector(showDeclas:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _decalsBtn;
}

- (UIButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [BARBaseUIViewUI createBeautyBtn:self.superview];
        [_beautyBtn addTarget:self action:@selector(showBeauty:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyBtn;
}

- (UIImageView *)undetectedFaceImgView {
    if (!_undetectedFaceImgView) {
        _undetectedFaceImgView = [BARBaseUIViewUI createUndetectedFaceImageView:self.superview];
        _undetectedFaceImgView.hidden = YES;
    }
    return _undetectedFaceImgView;
}

- (UIImageView *)faceAlertImgView {
    if (!_faceAlertImgView) {
        _faceAlertImgView = [BARBaseUIViewUI createFaceAlertImageView:self.superview];
        _faceAlertImgView.hidden = YES;
    }
    return _faceAlertImgView;
}

- (UILabel *)triggerLabel {
    if (!_triggerLabel) {
        _triggerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 40)];
        _triggerLabel.font = [UIFont systemFontOfSize:20];
        _triggerLabel.textColor = [UIColor whiteColor];
        _triggerLabel.textAlignment = NSTextAlignmentCenter;
        _triggerLabel.center = CGPointMake(self.center.x, self.center.y);
        _triggerLabel.hidden = YES;
    }
    return _triggerLabel;
}

//切换摄像头  目前没有用到
/*
 
 - (UIButton*)cameraSwitchBtn
 {
 if(nil == _cameraSwitchBtn) {
 _cameraSwitchBtn = [self createCameraSwitchBtn ];
 }
 return _cameraSwitchBtn;
 }
 
 - (UIButton*)createCameraSwitchBtn
 {
 UIImage* cameraSwitchImage = [self cameraSwitchImage];
 UIButton *cameraSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
 cameraSwitchBtn.exclusiveTouch = YES;
 [cameraSwitchBtn addTarget:self action:@selector(cameraSwitchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
 cameraSwitchBtn.frame = [self cameraSwitchBtnFrame:cameraSwitchImage];
 [cameraSwitchBtn setImage:cameraSwitchImage forState:UIControlStateNormal];
 [cameraSwitchBtn setImage:cameraSwitchImage forState:UIControlStateDisabled];
 
 return cameraSwitchBtn;
 }
 
 - (UIImage *)cameraSwitchImage {
 return  [UIImage imageWithContentOfFileForBAR:@"BaiduAR_顶部工具条-切换换摄像头"];
 }
 
 - (CGRect)cameraSwitchBtnFrame:(UIImage*)img {
 CGFloat offsetY = 10.f;
 CGSize cameraSwitchImageSize = [img size];
 return  CGRectMake(self.frame.size.width /2 + 17.5f,offsetY, cameraSwitchImageSize.width, cameraSwitchImageSize.height);
 }*/
//end 切换摄像头  目前没有用到

- (void)willEnterBackground {
    if(self.shootingVideo){
        [self stopShootVideo];
    }
}

#pragma mark - 控件点击事件


- (void)showCameraSwitch {
    if(self.hiddenViews){
        if(self.cameraSwitchBtn){
            [self.hiddenViews addObject:self.cameraSwitchBtn];
        }
    }else{
        self.cameraSwitchBtn.hidden = NO;
    }
    
}

- (void)hideCameraSwitch {
    self.cameraSwitchBtn.hidden = YES;
}

- (void)lightSwitchBtnClick:(UIButton *)sender {
    if(self.clickEventHandler) {
        self.clickEventHandler(BARClickActionLightSwitch,nil);
    }
}

- (void)closeViewBtnClick:(UIButton *)sender {
    if(self.clickEventHandler) {
        self.closeBtn.enabled = NO;
        self.clickEventHandler(BARClickActionClose,nil);
    }
}

- (void)cameraSwitchBtnClick:(UIButton *)sender {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval beforeTimeInterval = self.cameraSwitchTimeInterval;
    self.cameraSwitchTimeInterval = nowTimeInterval;
    if (self.clickEventHandler) {
        if ((nowTimeInterval - beforeTimeInterval) < 0.5) {
            
        }else{
            self.clickEventHandler(BARClickActionCameraSwitch,nil);
        }
    }
}

- (void)screenshotBtnClick:(UIButton *)sender {
    if(self.videoSwitchViewIsSwitching){
        return;
    }
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if ((nowTimeInterval - self.userGuideTimeInterval) < 0.5) {
        return;
    }
    NSTimeInterval beforeTimeInterval = self.screenShotTimeInterval;
    self.screenShotTimeInterval = nowTimeInterval;
    if(self.clickEventHandler) {
        if(self.imageVideoSwitchView.isForFirst){
            if( (nowTimeInterval - beforeTimeInterval) < 0.1 ) {
                
            }else{
                if(!self.shootingVideo) {
                   sender.selected = YES;
                    self.clickEventHandler(BARClickActionShootVideoStart,nil);
                    
                }else{
                    sender.selected = NO;
                    self.clickEventHandler(BARClickActionShootVideoStop,nil);
                }
                
            }
        }else{
            self.clickEventHandler(BARClickActionScreenshot,nil);
        }
    }
}

- (void)userGuideBtnClick:(UIButton *)sender {
    
}

- (void)voiceBtnClick:(UIButton *)sender {
    if(self.clickEventHandler) {
        self.clickEventHandler(BARClickActionVoice,nil);
    }
}

- (void)showDeclas:(UIButton *)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(BARClickActionDecals, nil);
    }
}
- (void)showBeauty:(UIButton *)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(BARClickActionBeauty, nil);
    }
}

- (void)switchResolution:(UISwitch *)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(BARClickActionTypeSwitchResolution, @{@"isOn": @(sender.isOn)});
    }
}

#pragma mark -  screenShotScaleLayer/videoButtonAnimation

- (void)dispatchAfterStartCompletion {
    if(self.shootingVideo) {
        [self setRecordButtonAndSwitchViewEnable:YES];
        
        //[self changeToShootingButton];
        [self startShootVideoAnimtion];
        self.screenshotRedImageView.hidden = NO;
    }else{
        [self setRecordButtonAndSwitchViewEnable:YES];
    }
}

//- (void) changeToShootingButton {
//    UIImage* screenshotImage = [BARBaseUIViewUI shootingVideoBtnImage:@"normal"];
//    self.screenshotBtn.frame = [BARBaseUIViewUI screenshotShootingBtnFrame:screenshotImage parentView:self];
//    [self.screenshotBtn setImage:screenshotImage forState:UIControlStateNormal];
//    [self.screenshotBtn setImage:[BARBaseUIViewUI shootingVideoBtnImage:@"disable"] forState:UIControlStateDisabled];
//    [self.screenshotBtn setImage:[BARBaseUIViewUI shootingVideoBtnImage:@"click"] forState:UIControlStateHighlighted];
//}

//- (void) changeToWaitinggButton {
//
//    UIImage* screenshotImage = [BARBaseUIViewUI videoBtnImage:@"normal"];
//    self.screenshotBtn.frame = [BARBaseUIViewUI screenshotBtnFrame:screenshotImage parentView:self];
//    [self.screenshotBtn setImage:screenshotImage forState:UIControlStateNormal];
//    [self.screenshotBtn setImage:[BARBaseUIViewUI videoBtnImage:@"disable"] forState:UIControlStateDisabled];
//    [self.screenshotBtn setImage:[BARBaseUIViewUI videoBtnImage:@"click"] forState:UIControlStateHighlighted];
//}


- (void)didStopShootVideo {
    _screenshotBtn.selected = NO;
    [self disableHideAllViewWhenShooting];
    self.shootingVideo = NO;
    
    if(self.shootVideoCompletionHandler){
        self.shootVideoCompletionHandler();
    }
    if(self.shootVideoAllPercentLayer) {
        [self.shootVideoAllPercentLayer removeFromSuperlayer];
        self.shootVideoAllPercentLayer = nil;
    }
    
    if(self.shootVideoPercentLayer) {
        [self.shootVideoPercentLayer removeFromSuperlayer];
        self.shootVideoPercentLayer = nil;
    }
    [self.screenshotRedImageView.layer removeAnimationForKey:@"redAnimation"];
    self.screenshotRedImageView.hidden = YES;
    
}

- (void)startShootVideoAnimtion {
    if(self.shootVideoPercentLayer)
    {
        [self.shootVideoPercentLayer removeFromSuperlayer];
        self.shootVideoPercentLayer = nil;
    }
    if(self.shootVideoAllPercentLayer)
    {
        [self.shootVideoAllPercentLayer removeFromSuperlayer];
        self.shootVideoAllPercentLayer = nil;
    }

    [self addShootVideoPercentLayer:self.screenshotBtn];
    
}

- (void) addTranslucentScaleLayer:(UIView *) parentView {
    CGFloat fromRadius = 44 /2.0;
    CGFloat toRadius = 58/2.0;


    CGFloat lineWidth = toRadius - fromRadius ;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGRect parentBounds = parentView.bounds;
    parentBounds = CGRectMake(-lineWidth, -lineWidth, toRadius*2, toRadius*2);
    shapeLayer.frame = parentBounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(parentBounds.size.width/2, parentBounds.size.height/2)
                                                        radius:parentBounds.size.width/2
                                                    startAngle:(-M_PI/2)
                                                      endAngle:(3*M_PI/2)
                                                     clockwise:YES];

    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4].CGColor;
    shapeLayer.lineWidth = lineWidth;

    [parentView.layer addSublayer:shapeLayer];

//    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    pathAnimation.duration = 0.25f;
//    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    pathAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    pathAnimation.toValue = [NSNumber numberWithFloat:(parentBounds.size.width/2 + lineWidth) / (parentBounds.size.width/2.0)];
//    pathAnimation.fillMode = kCAFillModeForwards;
//    pathAnimation.removedOnCompletion = NO;
//    pathAnimation.delegate = self;
//    [pathAnimation setValue:@"shootScaleAnimation"  forKey:@"shootScaleAnimation"];
//    [shapeLayer addAnimation:pathAnimation forKey:@"shootScaleAnimation"];

    self.shootScaleLayer = shapeLayer;
}

- (void)addShootVideoPercentLayer:(UIView *) parentView {
    //绘制白色边框
    CGFloat lineWidth = 3.0f;
    CAShapeLayer *whiteCircleShapeLayer = [CAShapeLayer layer];
    CGRect parentBounds = parentView.bounds;
    UIImage *image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_录制中_边缘"];
    CGSize size = [image size];
    CGFloat fromRadius = size.width /2.0;
    CGFloat toRadius = size.width /2.0;
    CGFloat rWidth = toRadius - fromRadius;
    parentBounds = CGRectMake(-rWidth, -rWidth, toRadius*2, toRadius*2);
    whiteCircleShapeLayer.frame = parentBounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(parentBounds.size.width/2, parentBounds.size.height/2)
                                                        radius:parentBounds.size.width/2 - lineWidth/2.0
                                                    startAngle:(-M_PI/2)
                                                      endAngle:(3*M_PI/2)
                                                     clockwise:YES];
    whiteCircleShapeLayer.path = path.CGPath;
    whiteCircleShapeLayer.fillColor = [UIColor clearColor].CGColor;
    whiteCircleShapeLayer.lineWidth = lineWidth;
    whiteCircleShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    [parentView.layer addSublayer:whiteCircleShapeLayer];
    self.shootVideoAllPercentLayer = whiteCircleShapeLayer;
    
    //绿色进度圆环
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = parentBounds;
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.strokeColor = [UIColor colorWithRed:9/255.0f green:251/255.0f blue:224/255.0f alpha:1.0].CGColor;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 15.0f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0];
    pathAnimation.toValue = [NSNumber numberWithFloat:(1.0f)];
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.delegate = self;
    [pathAnimation setValue:@"strokeEndAnimation"  forKey:@"strokeEndAnimation"];
    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    [parentView.layer addSublayer:shapeLayer];
    self.shootVideoPercentLayer = shapeLayer;
    
    //加入红点的动画
    CABasicAnimation *redAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    redAnimation.duration = 1.0f/2;
    redAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    redAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    redAnimation.toValue = [NSNumber numberWithFloat:0.3];
    redAnimation.removedOnCompletion = NO;
    redAnimation.autoreverses = YES;
    redAnimation.repeatCount = MAXFLOAT;
    [self.screenshotRedImageView.layer addAnimation:redAnimation forKey:@"redAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
        if( [[anim valueForKey:@"strokeEndAnimation"] isEqualToString: @"strokeEndAnimation" ] ){
            [self stopShootVideo];
        }
    }
    if ( [[anim valueForKey:@"shootScaleAnimation"] isEqualToString: @"shootScaleAnimation" ] ) {
        
    }
}

- (void)startShootVideoWithComplitionHandler:(void (^)(void))handler {
    _screenshotBtn.userInteractionEnabled = NO;
    [self setRecordButtonAndSwitchViewEnable:NO];
    self.shootVideoCompletionHandler = handler;
    self.shootingVideo = YES;
    
    [self hideAllViewWhenShooting];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf dispatchAfterStartCompletion];
        }
    });
}

- (NSArray *)shouldHiddenViews {
    NSMutableArray *shouldHiddenViews = [@[] mutableCopy];
    if (self.closeBtn) {
        [shouldHiddenViews addObject:self.closeBtn];
    }
    if (self.cameraSwitchBtn) {
        [shouldHiddenViews addObject:self.cameraSwitchBtn];
    }
    if (self.lightSwitchBtn) {
        [shouldHiddenViews addObject:self.lightSwitchBtn];
    }
    if (self.moreBtn) {
        [shouldHiddenViews addObject:self.moreBtn];
    }
//    if (self.userGuideBtn) {
//        [shouldHiddenViews addObject:self.userGuideBtn];
//    }
    if (self.replayBtn) {
        [shouldHiddenViews addObject:self.replayBtn];
    }
    if (self.imageVideoSwitchView) {
        [shouldHiddenViews addObject:self.imageVideoSwitchView];
    }
    if (self.decalsBtn) {
        [shouldHiddenViews addObject:self.decalsBtn];
    }
    if (self.beautyBtn) {
        [shouldHiddenViews addObject:self.beautyBtn];
    }
  
    
    return [shouldHiddenViews copy];
}

- (NSArray *)topButtons {
    
    NSMutableArray *topButtons = [@[] mutableCopy];
    if (self.closeBtn) {
        [topButtons addObject:self.closeBtn];
    }
    if (self.cameraSwitchBtn) {
        [topButtons addObject:self.cameraSwitchBtn];
    }
    if (self.lightSwitchBtn) {
        [topButtons addObject:self.lightSwitchBtn];
    }
    if (self.moreBtn) {
        [topButtons addObject:self.moreBtn];
    }
    
    return [topButtons copy];
}

- (NSArray *)bottomButtons {
    
    NSMutableArray *bottomButtons = [@[] mutableCopy];
    if (self.screenshotBtn) {
        [bottomButtons addObject:self.screenshotBtn];
    }
    if (self.screenshotBlur) {
        [bottomButtons addObject:self.screenshotBlur];
    }
    if (self.imageVideoSwitchView) {
        [bottomButtons addObject:self.imageVideoSwitchView];
    }
    
    return [bottomButtons copy];
}

#pragma clang diagnostic pop

- (void)hideAllViewWhenShooting {
    if(self.hiddenViews){
        
    }else{
        self.hiddenViews = [@[] mutableCopy];
    }
    if(self.alphaViews){
        [self.alphaViews removeAllObjects];
    }else{
        self.alphaViews = [@[] mutableCopy];
    }
    NSArray *hiddenViews = [self shouldHiddenViews];
    
    for (UIView *subView in hiddenViews) {
        if(subView  == self.screenshotBtn ||
//           [subView isKindOfClass:NSClassFromString(@"ARRenderView")] || subView  == self.cameraSwitchBtn || subView  == self.closeBtn){
           [subView isKindOfClass:NSClassFromString(@"ARRenderView")]){
           //只保留 视频按钮，渲染视图,返回按钮，切换摄像头按钮
        }
        else{
            if(!subView.hidden) {
                if( [self.hiddenViews indexOfObject:subView] == NSNotFound){
                    [self.hiddenViews addObject:subView];
                }
            }
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subView in self.hiddenViews ) {
            if(subView  == self.screenshotBtn ||
               [subView isKindOfClass:NSClassFromString(@"ARRenderView")]){
                //只保留 视频按钮，渲染视图
            }
            else{
                if(subView.alpha > 0.0 ){
                    subView.alpha = subView.alpha - 1.0 ;
                }
                [self.alphaViews addObject:subView];
            }
        }
    } completion:^(BOOL finished) {
        for (UIView *subView in self.hiddenViews) {
            subView.hidden = YES;
        }
        _screenshotBtn.userInteractionEnabled = YES;
    }];
}

- (void)disableHideAllViewWhenShooting {
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subView in self.alphaViews) {
            if(subView.alpha <= 0.0 ) {
                subView.alpha = subView.alpha + 1.0;
            }
        }
        [self.alphaViews removeAllObjects];
        
    } completion:^(BOOL finished) {
        _screenshotBtn.userInteractionEnabled = YES;
        for(UIView *subView in self.hiddenViews) {
            subView.hidden = NO;
        }
        [self.hiddenViews removeAllObjects];
        self.hiddenViews = nil;
        if(self.closeBtn.hidden){
            self.closeBtn.hidden = NO;
        }
        [self showShotButton];
    }];
}

- (void)hideAllViews {
    [self hideTopButtons];
    [self hideShotButton];
}

- (void)showAllViews {
    [self showTopButtons];
    [self showShotButton];
}

- (void)hideShotButton {
    
    //[UIView animateWithDuration:0.25 animations:^{
        self.screenshotBtn.alpha = 0;
        self.screenshotBlur.alpha = 0;
        self.imageVideoSwitchView.alpha = 0;
    //} completion:^(BOOL finished) {
        self.screenshotBtn.hidden = YES;
        self.screenshotBlur.hidden = YES;
        self.imageVideoSwitchView.hidden = YES;
    //}];
}

- (void)showShotButton {
    
    //[UIView animateWithDuration:0.25 animations:^{
        self.screenshotBtn.alpha = 1.0;
        self.screenshotBlur.alpha = 1.0;
        self.imageVideoSwitchView.alpha = 1.0;
        
    //} completion:^(BOOL finished) {
        self.screenshotBtn.hidden = NO;
        self.screenshotBlur.hidden = NO;
        self.imageVideoSwitchView.hidden = NO;
    //}];
}

- (void)hideTopButtons {
    
    NSArray *hiddenViews = [self topButtons];
    
    if (!self.topHiddenButtons) {
        self.topHiddenButtons = [@[] mutableCopy];
    }
    if (self.topAlphaButtons) {
        [self.topAlphaButtons removeAllObjects];
    } else {
        self.topAlphaButtons = [@[] mutableCopy];
    }
    
    for (UIView *subView in hiddenViews) {
        if (!subView.hidden) {
            if( [self.topHiddenButtons indexOfObject:subView] == NSNotFound){
                [self.topHiddenButtons addObject:subView];
            }
        }
    }
    
    //[UIView animateWithDuration:0.25 animations:^{
        for (UIView *subView in self.topHiddenButtons ) {
            
            if (subView.alpha > 0.0 ) {
                subView.alpha = 0;
            }
            [self.topAlphaButtons addObject:subView];
        }
    //} completion:^(BOOL finished) {
        for (UIView *subView in self.topHiddenButtons) {
            subView.hidden = YES;
        }
    //}];
    
}
- (void)showTopButtons {
    
    //[UIView animateWithDuration:0.25 animations:^{
        for (UIView *subView in self.topAlphaButtons) {
            if (subView.alpha <= 0.0 ) {
                subView.alpha = 1;
                subView.hidden = NO;
            }
        }
        [self.topAlphaButtons removeAllObjects];
        
    //} completion:^(BOOL finished) {
//        for (UIView *subView in self.topHiddenButtons) {
//            subView.hidden = NO;
//        }
//        [self.topHiddenButtons removeAllObjects];
    //}];
}

- (void)addSubview:(UIView *)view {
    if(self.shootingVideo){
        return;
    }
    [super addSubview:view];
}

/*结束录屏*/
- (void)stopShootVideo {
   _screenshotBtn.userInteractionEnabled = NO;
    //dispatch_async(dispatch_get_main_queue(), ^{
    [self didStopShootVideo];
    //});
    
}

- (void)setActuallyOrientation:(UIDeviceOrientation)direction {
    
}

- (void)rotateSubView:(UIView *)subView to:(UIInterfaceOrientation)orientation {
    CGFloat angle = 0;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            angle = 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = M_PI/2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = -M_PI/2;
            break;
        default:
            break;
    }
    subView.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setRecordButtonAndSwitchViewEnable:(BOOL)enable
{
    self.screenshotBtn.enabled = enable;
    self.imageVideoSwitchView.userInteractionEnabled = enable;
}


#pragma mark - BARBaseImageVideoSwtichViewDelegate

- (void)imageVideoSwitchDoingAnimation:(BOOL)doingAnimation{
    self.videoSwitchViewIsSwitching = doingAnimation;
}

- (void)imageVideoSwitchToFirst:(BOOL) toFirst {
    if(toFirst) {
        //录制
        [self.screenshotBtn setImage:[BARBaseUIViewUI videoBtnImage:@"videoNormal"] forState:UIControlStateNormal];
        [self.screenshotBtn setImage:[BARBaseUIViewUI videoBtnImage:@"disable"] forState:UIControlStateDisabled];
        [self.screenshotBtn setImage:[BARBaseUIViewUI videoBtnImage:@"click"] forState:UIControlStateHighlighted];
        
        //        self.screenshotRedImageView.alpha = 0.0;
        self.screenshotRedImageView.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            //            self.screenshotRedImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //            self.screenshotRedImageView.hidden = NO;
        }];
        
        //        self.screenshotRedImageView.frame = rectForImage;
        //        [UIView animateWithDuration:0.25 animations:^{
        //            self.screenshotRedImageView.frame = rectForVideo;
        //        }];
        
    }else{
        //拍摄
        [self.screenshotBtn setImage:[BARBaseUIViewUI screenshotBtnImage:@"normal"] forState:UIControlStateNormal];
        [self.screenshotBtn setImage:[BARBaseUIViewUI screenshotBtnImage:@"disable"] forState:UIControlStateDisabled];
        [self.screenshotBtn setImage:[BARBaseUIViewUI screenshotBtnImage:@"click"] forState:UIControlStateHighlighted];
        
        //        self.screenshotRedImageView.alpha = 0.0;
        self.screenshotRedImageView.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            //            self.screenshotRedImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //            self.screenshotRedImageView.alpha = 0.0;
            //            self.screenshotRedImageView.hidden = YES;
        }];
        
        //        self.screenshotRedImageView.hidden = NO;
        //        self.screenshotRedImageView.frame = rectForVideo;
        //        [UIView animateWithDuration:0.25 animations:^{
        //            self.screenshotRedImageView.frame = rectForImage;
        //        }];
    }
    self.shootingVideo = NO;
}

- (void)clearTips{
    [[BARAlert sharedInstance] dismiss];
    self.alphaImage = nil;
    self.alphaImageView.image = nil;
    if(self.alphaImageView.superview){
        [self.alphaImageView removeFromSuperview];
        self.alphaImageView = nil;
    }
    [self alphaImageViewHide];
    self.replayTips.hidden = YES;
}


#pragma mark - AR 通用方法
- (void)startScanAnimation {
    if(!self.shootingVideo){
        self.scanView.alpha = 1.0f;
//        if(self.scanView.hidden)  {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scanView.hidden = NO;
                [self.scanView scan];
            });
  //      }
    }
}

- (void)stopScanAnimation {
//    if(!self.scanView.hidden)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scanView.hidden = YES;
            [self.scanView stop];
        });
  //  }
}

//- (void)hideUserGuide {
//    if (self.userGuideView) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.userGuideView setHidden:true];
//        });
//    }
//}

//- (void)showUserGuide {
//    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
//    if( ( nowTimeInterval - self.screenShotTimeInterval) < 0.5 ) {
//        return ;
//    }
//    if (self.userGuideView) {
//        self.userGuideTimeInterval = nowTimeInterval;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.userGuideView setHidden:false];
//            [self bringSubviewToFront:self.userGuideView];
//        });
//    }
//}

- (void)setLandscapeMode:(UIDeviceOrientation)direction {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mainthread_setLandscapeMode:direction animation:YES];
    });
}

- (void)setLandscapeModeNoAnimation:(UIDeviceOrientation)direction {
    
    if ([[NSThread currentThread] isMainThread]) {
        [self mainthread_setLandscapeMode:direction animation:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mainthread_setLandscapeMode:direction animation:NO];
        });
    }
}

- (void)mainthread_setLandscapeMode:(UIDeviceOrientation)direction animation:(BOOL) animation{
    
    if (UIDeviceOrientationLandscapeLeft == direction) {
        if(animation){
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = M_PI/2;
                [self rotateReplayTip:direction];
                [self rotationUI:angle];
                UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
                [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
                [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
                
                CGRect frame = CGRectZero;
                frame.origin.x = self.bounds.size.width - 53 - img.size.height;
                frame.origin.y = self.bounds.size.height - 54 - img.size.width;
                frame.size = CGSizeMake(img.size.height, img.size.width);
                self.voiceTipsView.frame = frame;
                
                [self resizeReplayTipsWithDirection:direction];
                
            } completion:^(BOOL finished) {
            }];
        }else{
            CGFloat angle = M_PI/2;
            [self rotateReplayTip:direction];
            [self rotationUI:angle];
            UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
            [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
            [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
            
            CGRect frame = CGRectZero;
            frame.origin.x = self.bounds.size.width - 53 - img.size.height;
            frame.origin.y = self.bounds.size.height - 54 - img.size.width;
            frame.size = CGSizeMake(img.size.height, img.size.width);
            self.voiceTipsView.frame = frame;
            
            [self resizeReplayTipsWithDirection:direction];
            
        }
    } else if (UIDeviceOrientationLandscapeRight == direction) {
        if (animation) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = -(M_PI/2);
                [self rotateReplayTip:direction];
                [self rotationUI:angle];
                UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
                
                [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
                [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
                
                CGRect frame = CGRectZero;
                frame.origin.x = self.bounds.size.width - 53 - img.size.height;
                frame.origin.y = self.bounds.size.height - 54 - img.size.width;
                frame.size = CGSizeMake(img.size.height, img.size.width);
                self.voiceTipsView.frame = frame;
                
                [self resizeReplayTipsWithDirection:direction];
                
            } completion:^(BOOL finished) {
            }];
        }else{
            CGFloat angle = -(M_PI/2);
            [self rotateReplayTip:direction];
            [self rotationUI:angle];
            UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
            
            [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
            [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
            
            CGRect frame = CGRectZero;
            frame.origin.x = self.bounds.size.width - 53 - img.size.height;
            frame.origin.y = self.bounds.size.height - 54 - img.size.width;
            frame.size = CGSizeMake(img.size.height, img.size.width);
            self.voiceTipsView.frame = frame;
            
            [self resizeReplayTipsWithDirection:direction];
            
        }
    } else {
        if(animation) {
            [UIView animateWithDuration:0.5 animations:^{
                
                [self rotateReplayTip:direction];
                [self rotationUI:0];
                UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
                [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
                [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
                
                CGRect frame = CGRectZero;
                frame.origin.x = self.bounds.size.width - 18 - img.size.width;
                frame.origin.y = self.bounds.size.height - 89 - img.size.height;
                frame.size = CGSizeMake(img.size.width, img.size.height);
                self.voiceTipsView.frame = frame;
                
                [self resizeReplayTipsWithDirection:direction];
                
            } completion:^(BOOL finished) {
                
            }];
        }else{
            
            [self rotateReplayTip:direction];
            [self rotationUI:0];
            UIImage *img = [BARBaseUIViewUI voiceTipsImageLandscape:direction];
            [self.voiceTipsView setBackgroundImage:img forState:UIControlStateNormal];
            [self.voiceTipsView setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
            
            CGRect frame = CGRectZero;
            frame.origin.x = self.bounds.size.width - 18 - img.size.width;
            frame.origin.y = self.bounds.size.height - 89 - img.size.height;
            frame.size = CGSizeMake(img.size.width, img.size.height);
            self.voiceTipsView.frame = frame;
            
            [self resizeReplayTipsWithDirection:direction];
            
        }
    }
    if (self.customLoadingView) {
        [self.customLoadingView setLandscapeMode:direction];
    }
    if (self.textIndicator) {
        [self.textIndicator setLandscapeMode:direction];
    }
    if (self.switchCameraTip) {
        if(animation){
            [UIView animateWithDuration:0.5 animations:^{
                [self resizeSwitchCameraTipWithDirection:direction];
            }];
        }else{
            [self resizeSwitchCameraTipWithDirection:direction];
        }
    }
    if (self.voiceView) {
        [self.voiceView setLandscapeMode:direction];
    }
    [[BARAlert sharedInstance] setLandscapeMode:direction];
}

- (void)rotateReplayTip:(UIDeviceOrientation)direction{
    if(self.replayTips && self.replayTips.superview){
        
        if(UIDeviceOrientationLandscapeLeft == direction){
            UIImage *image = [BARBaseUIViewUI resacnTipImage:@"<-"];
            [self.replayTips setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
            [self.replayTips setBackgroundImage:image forState:UIControlStateNormal];
            // CGRect frame = [BARBaseUIViewUI resacnTipFrame:image relevantView:self.replayBtn direction:@"<-"];
            // self.replayTips.frame = frame;
            
        }else if(UIDeviceOrientationLandscapeRight == direction){
            UIImage *image = [BARBaseUIViewUI resacnTipImage:@"->"];
            [self.replayTips setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
            [self.replayTips setBackgroundImage:image forState:UIControlStateNormal];
            // CGRect frame = [BARBaseUIViewUI resacnTipFrame:image relevantView:self.replayBtn direction:@"<-"];
            // self.replayTips.frame = frame;
            
        }else{
            UIImage *image = [BARBaseUIViewUI resacnTipImage:@"|"];
            [self.replayTips setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
            [self.replayTips setBackgroundImage:image forState:UIControlStateNormal];
            // CGRect frame = [BARBaseUIViewUI resacnTipFrame:image relevantView:self.replayBtn direction:@"|"];
            // self.replayTips.frame = frame;
            
        }
    }
}

- (void)rotationUI:(float)angle {
    self.moreBtn.transform = CGAffineTransformMakeRotation(angle);
    self.screenshotBtn.transform = CGAffineTransformMakeRotation(angle);
    self.closeBtn.transform = CGAffineTransformMakeRotation(angle);
    self.lightSwitchBtn.transform = CGAffineTransformMakeRotation(angle);
 //   self.userGuideBtn.transform = CGAffineTransformMakeRotation(angle);
    self.replayBtn.transform = CGAffineTransformMakeRotation(angle);
    self.voiceBtn.transform = CGAffineTransformMakeRotation(angle);
    self.voiceTipsView.transform = CGAffineTransformMakeRotation(angle);
    self.cameraSwitchBtn.transform = CGAffineTransformMakeRotation(angle);
    if(self.replayTips && self.replayTips.superview){
        self.replayTips.transform = CGAffineTransformMakeRotation(angle);
    }
    if(self.switchCameraTip && self.switchCameraTip.superview) {
        self.switchCameraTip.transform = CGAffineTransformMakeRotation(angle);
    }
    if (self.undetectedFaceImgView && self.undetectedFaceImgView.superview) {
        self.undetectedFaceImgView.transform = CGAffineTransformMakeRotation(angle);
    }
    if (self.faceAlertImgView && self.faceAlertImgView.superview) {
        self.faceAlertImgView.transform = CGAffineTransformMakeRotation(angle);
    }
}

- (UIImage*)screenshot
{
    return nil;
}

- (void)setCameraFront:(BOOL)front {
    if(front){
        if ([self.hiddenViews containsObject:self.lightSwitchBtn]) {
            [self.hiddenViews removeObject:self.lightSwitchBtn];
        }
    }
}
- (void)setLightSwitchBtnOn:(BOOL)turnOn
{
    NSString* key = turnOn ? @"open":@"close";
    UIImage* image = [BARBaseUIViewUI lightSwitchBtnImage:key];
    [self.lightSwitchBtn setImage:image forState:UIControlStateNormal];
    [self.lightSwitchBtn setImage:image forState:UIControlStateDisabled];
}

- (void)resizeReplayTipsWithDirection:(UIDeviceOrientation)direction {
    
    CGRect frame = self.replayTips.frame;
    
    if (direction == UIDeviceOrientationLandscapeLeft) {
        frame.origin.x = 54;
        frame.origin.y = self.bounds.size.height - frame.size.height - 49;
    } else if (direction == UIDeviceOrientationLandscapeRight) {
        frame.origin.x = 54;
        frame.origin.y = self.bounds.size.height - frame.size.height - 49;
    } else {
        frame.origin.x = 18;
        frame.origin.y = self.bounds.size.height - frame.size.height - 84;
    }
    self.replayTips.frame = frame;
    
}
- (void)resizeSwitchCameraTipWithDirection:(UIDeviceOrientation)direction {
    
    if (self.switchCameraTip && self.switchCameraTip.superview) {
        
        CGFloat tipx = self.cameraSwitchBtn.center.x - (self.switchCameraTip.frame.size.width/2);
        CGFloat tipy = 47;
        
        CGRect frame = self.switchCameraTip.frame;
        
        UIImage *image = [BARBaseUIViewUI switchCameraTipImage:@"|"];
        
        if (direction == UIDeviceOrientationLandscapeLeft) {
            image = [BARBaseUIViewUI switchCameraTipImage:@"<"];
            [self.switchCameraTip setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            
        } else if (direction == UIDeviceOrientationLandscapeRight) {
            image = [BARBaseUIViewUI switchCameraTipImage:@">"];
            [self.switchCameraTip setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
            
        } else {
            image = [BARBaseUIViewUI switchCameraTipImage:@"|"];
            [self.switchCameraTip setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -5, 0)];
        }
        
        frame.origin.x = tipx;
        frame.origin.y = tipy;
        
        [self.switchCameraTip setBackgroundImage:image forState:UIControlStateNormal];
        self.switchCameraTip.frame = frame;
        
    }
}

- (UIView*) recommendBgView {
    if(nil == _recommendBgView) {
        _recommendBgView = [[UIView alloc] initWithFrame:self.bounds];
        _recommendBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recommendBgViewTapAction:)];
        [_recommendBgView addGestureRecognizer:tap];
    }
    return _recommendBgView;
}

- (BOOL)canStartRecord{
    return self.imageVideoSwitchView.isForFirst && !self.videoSwitchViewIsSwitching;
}


- (void) recommendBgViewTapAction:(UITapGestureRecognizer *) tap {
    if(self.clickEventHandler) {
        self.clickEventHandler(BARClickRecommendBgView,nil);
    }
}

#pragma mark - top and bottom shadow bg

- (UIImageView *)topShadowBg {
    if (!_topShadowBg) {
        _topShadowBg = [BARBaseUIViewUI createTopBackgroundShadow:self];
    }
    return _topShadowBg;
}

- (UIImageView *)bottomShadowBg {
    if (!_bottomShadowBg) {
        _bottomShadowBg = [BARBaseUIViewUI createBottomBackgroundShadow:self];
    }
    return _bottomShadowBg;
}

+ (BARUnauthorizedView *)createUnauthorizedView:(UIView *)parentView {
    BARUnauthorizedView* uView = [[BARUnauthorizedView alloc] initWithFrame:parentView.bounds];
    return uView;
}

- (UISwitch *)resolutionSwitch {
    if (!_resolutionSwitch) {
        //_resolutionSwitch = [BARBaseUIViewUI createResolutionSwitchView:self];
        //[_resolutionSwitch addTarget:self action:@selector(switchResolution:) forControlEvents:UIControlEventValueChanged];
    }
    return _resolutionSwitch;
}

@end
#pragma clang diagnostic pop

