//
//  DARRenderViewController.h
//  ARAPP-Pro
//
//  Created by Asa on 2017/10/23.
//  Copyright © 2017年 Asa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BARGestureView.h"

#if defined (__arm64__)

#define SAMPLE_BUffER_LAYER 1

@protocol DARRenderViewControllerDataSource<NSObject>
@optional

/**
 将相机流数据传给MainController，进行渲染处理
 
 @param srcBuffer 相机流原始数据
 */
- (void)updateSampleBuffer:(CMSampleBufferRef)srcBuffer;

/**
 录制视频时，将音频数据传给BARVideoRecorder
 
 @param srcBuffer 音频数据
 */
- (void)updateAudioSampleBuffer:(CMSampleBufferRef)srcBuffer;

/**
 手势相关
 
 @param gesture 手势
 */
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

@interface DARRenderViewController : UIViewController

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, weak) id<DARRenderViewControllerDataSource> dataSource;
@property (strong, nonatomic)  UIView *arContentView;//AR视图容器
@property (nonatomic, assign) CGSize previewSizeInPixels;//预览尺寸
@property (nonatomic, assign) CGSize cameraSize;//相机尺寸
@property (nonatomic, assign) CGFloat aspect;//屏占比
@property (nonatomic, strong) BARGestureView *gestureView;//手势view
@property (nonatomic, assign) BOOL isLandscape;//是否横屏
@property (nonatomic, assign) BOOL isFaceAssetsLoaded;
@property (nonatomic, assign) BOOL isTrackingSucceed;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, assign) BOOL isDefaultBack;
@property (nonatomic, assign) BOOL usePreivewLayer;

@property (nonatomic, assign) int deviceType;

@property (nonatomic, assign) BOOL isInitCamera;


/**
 切换到系统相机
 */
- (void)changeToSystemCamera;

/**
 切换到AR相机
 */
- (void)changeToARCamera;

/**
 切换前后摄像头
 */
- (void)rotateCamera;

/**
 打开或者关闭闪光灯
 */
- (void)openLightSwitch:(BOOL)isOpen;

/**
 相机当前位置
 
 @return 0:后置 1：前置
 */
- (int)devicePosition;

/**
 判断闪光灯是否开启
 
 @return YES:开启 NO：关闭
 */
- (BOOL)lightSwitchOn;


- (BOOL)demoNeedARMirrorBuffer;

- (void)startCapture;
/**
 停止相机
 */
- (void)stopCapture;

- (void)pauseCapture;
- (void)resumeCapture;

- (void)manualAdjustFocusAtPoint:(CGPoint)point;
- (void)tapAdjustFocusToDrawRectangle:(NSArray *)points;
- (void)removeFocusRectangle;
- (void)drawFaceBoxRectangle:(NSArray *)points;
- (void)removeContaintView;

- (void)updateRenderSampleBuffer:(CMSampleBufferRef) sampleBuffer;

- (void)changeCameFormatPreset:(int)type;
@end

#else
@interface DARRenderViewController : UIViewController

@end
#endif
