//
//  BARRenderBaseViewController.h
//  AR-Base
//
//  Created by yijieYan on 2018/4/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BARGestureImageView.h"

@protocol BARCameraRenderViewControllerDataSource<NSObject>
@optional
- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer extraInfo:(id)info;
- (void)onViewGesture:(UIGestureRecognizer *)gesture;
- (void)ar_touchesBegan:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;
- (void)ar_touchesMoved:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;
- (void)ar_touchesEnded:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;
- (void)ar_touchesCancelled:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;

- (void)touchesBegan:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesMoved:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesEnded:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesCancelled:(CGPoint)point scale:(CGFloat)scale;
@end

@interface BARRenderBaseViewController : UIViewController

@property (nonatomic, assign) CGFloat aspect;
@property (nonatomic, strong) BARGestureImageView *videoPreviewView;
@property (nonatomic, weak) id<BARCameraRenderViewControllerDataSource> dataSource;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) CGSize cameraSize;

- (void)startCapture;
- (void)stopCapture;
- (void)pauseCapture;
- (void)resumeCapture;
- (BOOL)hasTorch;
- (void)turnTorchOn;
- (void)turnTorchOff;
- (BOOL)isTorchOn;
- (void)swapFrontAndBackCameras;
- (BOOL)isFrontCameraPresent;
- (BOOL)isFrontCamera;
- (id)currentCameraForRecord;

- (CGSize)currentCameraSize;
- (CGSize)currentPreviewSize;
- (void)showPlaceModelWithStatus:(BOOL)status;
@end
