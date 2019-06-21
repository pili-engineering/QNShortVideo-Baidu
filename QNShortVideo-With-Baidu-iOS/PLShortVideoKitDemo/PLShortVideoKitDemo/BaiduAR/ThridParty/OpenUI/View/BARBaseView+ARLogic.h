//
//  BARBaseView+ARLogic.h
//  ARSDK-Pro
//
//  Created by Asa on 2017/11/28.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARBaseView.h"
#import "BARFaceUtil.h"
@interface BARBaseView (ARLogic)

- (void)loadARFinished;

- (void)alphaImageViewShow:(NSString *)imageName imageViewHeight:(CGFloat)imageViewHeight;
- (void)alphaImageViewHide;
#ifdef BAR_FOR_OPENSDK
- (void)startSameSearch;
- (void)stopSameSearch;

- (void)switchToSameSearchView;
- (void)addBackToSameSearchBtn;
#endif
- (void)addBoxReplayButton;
- (void)showVoiceIcon;
- (void)hideVoiceIcon;

- (void)startVoiceRecog;
- (void)stopVoiceRecog;
- (void)voiceViewShowLoadingView;
- (void)voiceViewStopLoadingView;
- (void)voiceViewShowWaveView;
- (void)voiceViewStopWaveView;
- (void)setVoiceViewTips:(NSString *)tips;
- (void)setVoiceVolume:(NSUInteger)volume;

//face
- (void)beautyViewShow:(NSArray *)filterGroup;
- (void)decalsViewShow:(NSArray *)decalsData;
- (void)updateBeautySliderValue:(CGFloat)value type:(NSInteger)type;
- (void)closeFaceView;
- (void)setFaceAlertImgViewWith:(NSString *)imageName;
- (void)hideFaceAlertImgView;
- (void)handleSwitchDone;
- (void)resetDecalsViewData;
- (void)updateDecals:(NSArray *)decalsData;
@end
