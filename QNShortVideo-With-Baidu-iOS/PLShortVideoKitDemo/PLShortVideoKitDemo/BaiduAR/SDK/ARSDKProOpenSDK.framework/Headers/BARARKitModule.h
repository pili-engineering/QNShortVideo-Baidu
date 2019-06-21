//
//  BARARKitModule.h
//  ARSDKPro-BoxSDK
//
//  Created by Asa on 2018/7/27.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BARMainController.h"
#import "BARRenderBaseViewController.h"

@protocol BARARKitModuleDelegate<NSObject>

@required
- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)updateAudioSampleBuffer:(CMSampleBufferRef)audioBuffer;
- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer extraInfo:(id)info;
@end

typedef void(^BARAudioSampleBufferHandler)(CMSampleBufferRef srcBuffer);

@interface BARARKitModule : NSObject

@property (nonatomic, weak) id<BARARKitModuleDelegate> arkitDelegate;
@property (nonatomic, strong) BARRenderBaseViewController *arRenderWithCameraVC;

- (BARRenderBaseViewController *)setupARKitControllerWithRatio:(float)ratio;
- (void)setupARController:(BARMainController *)controller;
- (void)cleanARKitModule;

@end
