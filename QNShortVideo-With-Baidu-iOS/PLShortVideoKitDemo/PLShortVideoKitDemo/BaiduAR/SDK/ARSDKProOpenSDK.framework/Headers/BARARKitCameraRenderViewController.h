//
//  BARARKitCameraRenderViewController.h
//  ARSDK
//
//  Created by lusnaow on 15/01/2018.
//  Copyright © 2018 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BARGestureImageView.h"
#import "BARVideoRecorder.h"
#import "BARRenderBaseViewController.h"

@protocol BARARKitCameraRenderViewControllerDataSource<NSObject>
@optional
//- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//- (void)onViewGesture:(UIGestureRecognizer *)gesture;
//- (void)touchesBegan:(CGPoint)point scale:(CGFloat)scale;
//- (void)touchesMoved:(CGPoint)point scale:(CGFloat)scale;
//- (void)touchesEnded:(CGPoint)point scale:(CGFloat)scale;
//- (void)touchesCancelled:(CGPoint)point scale:(CGFloat)scale;


- (void)updateCamera:(matrix_float4x4)matrix;
- (void)updateARKitCameraProjectionMatrix:(matrix_float4x4)matrix;
- (void)outputAudioSampleBufferRef:(CMSampleBufferRef)audioBuffer;
- (BOOL)currentIsRecording;
@end


@interface BARARKitCameraRenderViewController : BARRenderBaseViewController
@property (nonatomic, weak) id <BARARKitCameraRenderViewControllerDataSource> arKitdataSource;
@property (nonatomic, assign) CGSize previewSizeInPixels;
@property (nonatomic, strong) BARVideoRecorder *videoRecorder;
@property (nonatomic, assign) BOOL isPlaneDetected;

//- (void)startCapture;
//- (void)stopCapture;
//- (void)pauseCapture;
//- (void)resumeCapture;
//- (void)resetARKit;
//- (BOOL)hasTorch;
//- (void)turnTorchOn;
//- (void)turnTorchOff;
//- (BOOL)isTorchOn;

- (void)startARKitDetectPlane;
- (void)resetARKit;
- (void)showPlaceModelWithStatus:(BOOL)show;
- (void)setArKitAudioProvideEnable;
- (void)setARKitPlaneDetectionType:(NSInteger)planeDetection;
- (void)setPlaneFeatureInfoEnable:(BOOL)enable;
- (void)setARKitPlaneHitTestEnable:(BOOL)enable point:(CGPoint)point isDefault:(BOOL)isDefault;

- (void)changeToSystemCamera;
- (void)changeToARCamera;

@end
