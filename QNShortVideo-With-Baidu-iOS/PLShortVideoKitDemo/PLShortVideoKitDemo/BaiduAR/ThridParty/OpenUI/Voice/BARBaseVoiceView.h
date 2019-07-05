//
//  BARBaseVoiceView.h
//  ARSDK
//
//  Created by Zhao,Xiangkai on 2018/2/9.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARBaseVoiceView : UIView

- (void)startVoice;
- (void)stopVoice;
- (void)showLoadingWave;
- (void)stopLoadingWave;
- (void)showWaving;
- (void)stopWaving;
- (void)setTips:(NSString *)tips;
- (void)changeVolume:(NSInteger)volume shootingVideo:(BOOL)shootingVideo;
- (void)setContainer:(UIView *)container;

- (void)setLandscapeMode:(UIDeviceOrientation)direction;

@end
