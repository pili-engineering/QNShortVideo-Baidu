//
//  BARBaseView+ARLogic.m
//  ARSDK-Pro
//
//  Created by Asa on 2017/11/28.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARBaseView+ARLogic.h"
#import "UIImage+Load.h"

@implementation BARBaseView (ARLogic)

- (void)loadARFinished{
    
   // if (!self.modelMgr.uiResource.hideShotImmediately) ?
    self.screenshotBlur.hidden = NO;
    self.screenshotBtn.hidden = NO;
    self.imageVideoSwitchView.hidden = NO;
    [self setRecordButtonAndSwitchViewEnable:YES];
    self.closeBtn.hidden = NO;
    self.lightSwitchBtn.hidden = NO;
    self.moreBtn.hidden = NO;
    self.replayBtn.enabled = YES;
}


//半透明触发图实现
- (CGRect)alphaImgeViewFrame:(CGFloat)imageViewHeight {
    CGFloat cameraWidth = imageViewHeight;
    CGSize size = self.bounds.size;
    CGFloat width = cameraWidth>1000 ? (int)(size.width/cameraWidth*1000) : (int)(size.width/1080*1000);
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    return CGRectMake(center.x - width/2, center.y - width/2, width, width);
}

- (void)addBoxReplayButton{
    if(!self.replayBtn.superview){
        [self addSubview:[self replayBtn]];
        [self addReplayTipView];
        [self.replayBtn addTarget:self action:@selector(replayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Track

- (void)alphaImageViewShow:(NSString *)imageName imageViewHeight:(CGFloat)imageViewHeight{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.alphaImageView){
            self.alphaImageView = [[UIImageView alloc] initWithFrame:[self alphaImgeViewFrame:imageViewHeight]];
            self.alphaImageView.alpha = 0.5;
            self.alphaImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:self.alphaImageView];
        }
        if(self.alphaImage == nil){
            UIImage *image = [UIImage imageWithContentOfFileForBAR:imageName];
            self.alphaImage = image;
            self.alphaImageView.image = self.alphaImage;
        }
        [self.alphaImageView setHidden:false];
    });
}

- (void)alphaImageViewHide{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alphaImageView setHidden:true];
    });
}

- (void)addReplayTipView {
    
    UIButton *btn  = self.replayTips;
    NSDictionary *theDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReplayTips"];
    if (nil == theDic) {
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
        [recordSetting setObject:@1 forKey:@"haveShowReplayTips"];
        [[NSUserDefaults standardUserDefaults] setObject:recordSetting forKey:@"ReplayTips"];
        btn.hidden = NO;
        [self addSubview:btn];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [btn removeFromSuperview];
        });
    } else {
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)replayBtnClick{
    self.replayBtn.enabled = false;
    if (self.clickEventHandler) {
        self.clickEventHandler(BARClickActionReScan, nil);
    }
}

#pragma mark - SameSearch
#ifdef BAR_FOR_OPENSDK
- (void)addBackToSameSearchBtn{
    if(!self.replayBtn.superview ){
        [self.replayBtn addTarget:self action:@selector(switchToSameSearchView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:[self replayBtn]];
    }
    self.replayBtn.hidden = NO;
    self.replayBtn.enabled = YES;
    [self addReplayTipView];
}

- (void)switchToSameSearchView {
    self.replayBtn.enabled = false;
    [self startSameSearch];
    if (self.clickEventHandler) {
        self.clickEventHandler(BARClickActionSwitchToSameSearch, nil);
    }
}

- (void)startSameSearch {
    self.screenshotBlur.hidden = YES;
    self.screenshotBtn.hidden = YES;
    self.imageVideoSwitchView.hidden = YES;
    self.replayBtn.hidden = YES;
    self.replayTips.hidden = YES;
    [self voiceBtnTurnOn:NO];
    self.voiceBtn.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScanAnimation];
    });
}

- (void)stopSameSearch {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopScanAnimation];
        //[self.scanView removeFromSuperview];
    });}
#endif
#pragma mark - Voice

- (void)showVoiceIcon {
    self.voiceBtn.hidden = NO;
}
- (void)hideVoiceIcon {
    self.voiceBtn.hidden = YES;
}

- (void)startVoiceRecog {
    [self.voiceView startVoice];
}

- (void)stopVoiceRecog {
    [self.voiceView stopVoice];
}

- (void)voiceViewShowLoadingView {
    [self.voiceView showLoadingWave];
}

- (void)voiceViewStopLoadingView {
    [self.voiceView stopLoadingWave];
}

- (void)voiceViewShowWaveView {
    [self.voiceView showWaving];
}

- (void)voiceViewStopWaveView {
    [self.voiceView stopWaving];
}

- (void)setVoiceViewTips:(NSString *)tips {
    [self.voiceView setTips:tips];
}

- (void)setVoiceVolume:(NSUInteger)volume {
    [self.voiceView changeVolume:volume shootingVideo:self.shootingVideo];
}

#pragma mark - face
- (void)beautyViewShow:(NSArray *)filterGroup {
    [self.beautyView setFilterGroupWith:filterGroup];
    self.beautyView.hidden = NO;
    self.beautyBtn.hidden = YES;
    self.decalsBtn.hidden = YES;
    [self hideShotButton];
}

- (void)decalsViewShow:(NSArray *)decalsData{
    [self.decalsView setDecalsDataWith:decalsData];
    self.decalsView.hidden = NO;
    self.beautyBtn.hidden = YES;
    self.decalsBtn.hidden = YES;
    [self hideShotButton];
}

- (void)updateDecals:(NSArray *)decalsData{
     [self.decalsView setDecalsDataWith:decalsData];
}

- (void)updateBeautySliderValue:(CGFloat)value type:(NSInteger)type {
    [self.beautyView setSliderValue:value type:type];
}

- (void)closeFaceView {
    self.decalsView.hidden = YES;
    self.beautyView.hidden = YES;
    self.beautyBtn.hidden = NO;
    self.decalsBtn.hidden = NO;
    [self showShotButton];
}

- (void)setFaceAlertImgViewWith:(NSString *)imageName {
    self.faceAlertImgView.image = [UIImage imageWithContentOfFileForBAR:imageName];
    self.faceAlertImgView.hidden = YES;
}

- (void)hideFaceAlertImgView {
    self.triggerLabel.hidden = YES;
}

- (void)handleSwitchDone {
    [self.decalsView handleSwitchDone];
}

- (void)resetDecalsViewData {
    [self.decalsView resetDecalsViewData];
}

#pragma mark - Slam



@end
