//
//  DARRenderViewController.m
//  ARAPP-Pro
//
//  Created by Asa on 2017/10/23.
//  Copyright © 2018年 JIA CHUANSHENG. All rights reserved.
//

#import "DARRenderViewController.h"
#if defined (__arm64__)

#define FACE_DEFAULT_OUTPUT_IMAGE_WIDTH           720.0f
#define SCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height
#define SHOULD_PORTRAIT  1    //控制视频流是横向还是竖向 0：横向  1：竖向
#define DEMO_VIDEO_MIRROR 1 //
#define DEMO_VIDEO_FORMATYUV 0 //

@interface DARRenderViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureConnection* _audioConnection;
    dispatch_queue_t _audioQueue;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, retain) AVCaptureDevice *avCaptureDevice;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;
@property (nonatomic, strong) dispatch_queue_t videoOperationQueue;
@property (nonatomic, strong) dispatch_queue_t audioOperationQueue;

@property (nonatomic, assign) int pixelFormatType;
@property (nonatomic, assign) CGSize previewSize;

@property (nonatomic, assign)BOOL isCapturePaused;

@property (nonatomic, assign) BOOL isAutoRecLayerExist;
@property (nonatomic, strong) CAShapeLayer *autoRecLayer;
@property (nonatomic, strong) CAShapeLayer *manualRecLayer;
@property (nonatomic, assign) BOOL videoMirrored;

@property (nonatomic, assign) int frameRate;
@property (nonatomic, assign) BOOL is1080PResolution;
@property (nonatomic, assign) BOOL roating;
@end

@implementation DARRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoOperationQueue = dispatch_queue_create("com.baidu.arsdk.videocapture", DISPATCH_QUEUE_SERIAL);
    self.audioOperationQueue = dispatch_queue_create("com.baidu.arsdk.audiocapture", DISPATCH_QUEUE_SERIAL);
#if DEMO_VIDEO_FORMATYUV
    self.pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
#else
    self.pixelFormatType = kCVPixelFormatType_32BGRA;
#endif
    
    self.is1080PResolution = NO;
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"device_resolution" ofType:@"json"];
    NSData *resData = [[NSData alloc] initWithContentsOfFile:resPath];
    NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    if (resDic && [resDic isKindOfClass:[NSDictionary class]]) {
        self.is1080PResolution = [[resDic objectForKey:@"1080P"] boolValue];
    }
    
    _cameraSize = CGSizeMake(720, 1280);
    
    if(SHOULD_PORTRAIT){
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    else
    {
        self.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        _previewSize = CGSizeMake([UIScreen mainScreen].bounds.size.height , ceil( [UIScreen mainScreen].bounds.size.height * self.aspect));
    }else {
        _previewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width , ceil( [UIScreen mainScreen].bounds.size.width * self.aspect));
    }
    
    self.videoMirrored = NO;
#if DEMO_VIDEO_MIRROR
    self.videoMirrored = YES;
#endif
    
    if (self.deviceType == 0) {
        self.frameRate = 25;
    } else {
        self.frameRate = 30;
    }
    
    [self setupBaseContainerView];
    if (self.isInitCamera) {
        [self setupSession];
    }
    [self setupCameraPreview];
    [self setupGestureView];
    
    float scale = [UIScreen mainScreen].scale;
    _previewSizeInPixels = CGSizeMake(self.previewSize.width * scale , self.previewSize.height * scale);
    self.isFaceAssetsLoaded = NO;
    self.isTrackingSucceed = NO;
    self.isAutoRecLayerExist = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //解决闪屏bug
    //    [self startCapture];
    [self performSelector:@selector(startCapture) withObject:nil afterDelay:0.1];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawFaceBoxRectangle:) name:@"BARDrawFaceBoxRectangle" object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - Private
- (void)setupBaseContainerView {
    
    self.arContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.previewSize.width, self.previewSize.height)];
    [self.arContentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.arContentView];
    
    if (self.isLandscape) {
        self.arContentView.transform = CGAffineTransformIdentity;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationPortrait == orientation) {
            
            self.arContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
            
            self.arContentView.layer.position = CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
            
        }else if (UIInterfaceOrientationPortraitUpsideDown == orientation) {
            self.arContentView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.arContentView.layer.position = CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
            
        }else {
            [self adjustViewsForOrientation:orientation];
        }
        
    }
}

- (void)setupGestureView
{
    if(!self.gestureView){
        _gestureView = [[BARGestureView alloc]initWithFrame:self.arContentView.bounds];
        [self.gestureView setBackgroundColor:[UIColor clearColor]];
        [self.arContentView addSubview:self.gestureView];
        _gestureView.gesturedelegate = (id<BARGestureDelegate>)self;
    }
}

- (void)updateRenderSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    if (self.sampleBufferDisplayLayer) {
        if (self.sampleBufferDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
            [self.sampleBufferDisplayLayer flushAndRemoveImage];
        }
        
        if ([self.sampleBufferDisplayLayer isReadyForMoreMediaData]) {
            [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
            if (!self.isInitCamera){
                [self.sampleBufferDisplayLayer flush];
            }
        }
    }
    
}

- (void)changeCameFormatPreset:(int)type {
    if(type == 0){
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }else if(1 == type){
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
    }
}


- (void)setupCameraPreview
{
    if (SAMPLE_BUffER_LAYER) {
        self.sampleBufferDisplayLayer = [[AVSampleBufferDisplayLayer alloc] init];
        self.sampleBufferDisplayLayer.frame = CGRectMake(0, 0, self.arContentView.frame.size.width, self.arContentView.frame.size.height);
        self.sampleBufferDisplayLayer.position = CGPointMake(CGRectGetMidX(self.arContentView.bounds), CGRectGetMidY(self.arContentView.bounds));
        self.sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.sampleBufferDisplayLayer.opaque = YES;
        [self.arContentView.layer addSublayer:self.sampleBufferDisplayLayer];
    } else {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.previewLayer setFrame:self.arContentView.bounds];
        [self.arContentView.layer addSublayer:self.previewLayer];
    }
    
    
}

- (BOOL)demoNeedARMirrorBuffer{
    
    if(self.videoOrientation == AVCaptureVideoOrientationLandscapeLeft){
        if(self.devicePosition == 1){
            return YES;
        }else{
            return NO;
        }
    }
    
    if(self.devicePosition == 1){
        if(self.videoMirrored){
            return NO;
        }else{
            return YES;
        }
    }
    
    return NO;
}

- (void) setupAudioCapture {
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"Error getting audio input device: %@", error.description);
    }
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    }
    
    _audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioOutput setSampleBufferDelegate:self queue:_audioQueue];
    if ([self.captureSession canAddOutput:_audioOutput]) {
        [self.captureSession addOutput:_audioOutput];
    }
    _audioConnection = [_audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void)setupSession
{
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    
    // 设置换面尺寸
    [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    
    // 设置输入设备
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    if (self.isDefaultBack) {
        position = AVCaptureDevicePositionBack;
    }
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            inputCamera = device;
            self.avCaptureDevice = device;
        }
    }
    
    if (!inputCamera) {
        return;
    }
    
    NSError *error = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:&error];
    if ([self.captureSession canAddInput:_videoInput])
    {
        [self.captureSession addInput:_videoInput];
    }
    
    
    // 设置输出数据
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.pixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [_videoOutput setSampleBufferDelegate:self queue:self.videoOperationQueue];
    
    if ([self.captureSession canAddOutput:_videoOutput]) {
        [self.captureSession addOutput:_videoOutput];
    }
    
    [self setupAudioCapture];
    if(SHOULD_PORTRAIT){
        self.videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([self.videoConnection isVideoOrientationSupported]) {
            [self.videoConnection setVideoOrientation:self.videoOrientation];
        }
        
        if (inputCamera.position == AVCaptureDevicePositionFront) {
            self.videoConnection.videoMirrored = self.videoMirrored;
        }else {
            self.videoConnection.videoMirrored = NO;
        }
    }
    else{
        
    }
    
    if (self.is1080PResolution) {
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
            _cameraSize = CGSizeMake(1080, 1920);
        }
    }
    
    [self.captureSession commitConfiguration];
    
    [self setCaptureFrameRate:self.frameRate];
    
    
    
    /*
     NSDictionary* outputSettings = [_videoOutput videoSettings];
     for(AVCaptureDeviceFormat *vFormat in [self.avCaptureDevice formats] )
     {
     CMFormatDescriptionRef description= vFormat.formatDescription;
     float maxrate=((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
     
     CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(description);
     FourCharCode formatType = CMFormatDescriptionGetMediaSubType(description);
     if(maxrate == 30 && formatType ==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange && dimensions.width ==[[outputSettings objectForKey:@"Width"]  intValue] && dimensions.height ==[[outputSettings objectForKey:@"Height"]  intValue]  )
     {
     if ( YES == [self.avCaptureDevice lockForConfiguration:NULL] )
     {
     self.avCaptureDevice.activeFormat = vFormat;
     [self.avCaptureDevice setActiveVideoMinFrameDuration:CMTimeMake(1,24)];
     [self.avCaptureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,24)];
     [self.avCaptureDevice unlockForConfiguration];
     }
     }
     }*/
    
}

- (void)setCaptureFrameRate:(int)frameRate {
    if ([self.avCaptureDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] && [self.avCaptureDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
        [self.avCaptureDevice lockForConfiguration:nil];
        [self.avCaptureDevice setActiveVideoMinFrameDuration:CMTimeMake(1,frameRate)];
        [self.avCaptureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,frameRate)];
        [self.avCaptureDevice unlockForConfiguration];
    }
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.isCapturePaused) {
        return;
    }
    if (!self.captureSession.isRunning) {
        return;
    }else if (captureOutput == _videoOutput) {
        CFRetain(sampleBuffer);
        dispatch_async(self.videoOperationQueue, ^{
            
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(updateSampleBuffer:)]) {
                [self.dataSource updateSampleBuffer:sampleBuffer];
            }
            
            CFRelease(sampleBuffer);
            
        });
    }else if (captureOutput == _audioOutput) {
        CFRetain(sampleBuffer);
        dispatch_async(self.audioOperationQueue, ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(updateAudioSampleBuffer:)]) {
                [self.dataSource updateAudioSampleBuffer:sampleBuffer];
            }
            
            CFRelease(sampleBuffer);
        });
    }
}

- (void)onViewGesture:(UIGestureRecognizer *)gesture{
    [self.dataSource onViewGesture:gesture];
}
- (void)ar_touchesBegan:(NSSet<UITouch *> *)touches scale:(CGFloat)scale
{
    [self.dataSource ar_touchesBegan:touches scale:scale];
}
- (void)ar_touchesMoved:(NSSet<UITouch *> *)touches scale:(CGFloat)scale
{
    [self.dataSource ar_touchesMoved:touches scale:scale];
}
- (void)ar_touchesEnded:(NSSet<UITouch *> *)touches scale:(CGFloat)scale
{
    [self.dataSource ar_touchesEnded:touches scale:scale];
}

- (void)ar_touchesCancelled:(NSSet<UITouch *> *)touches scale:(CGFloat)scale{
    [self.dataSource ar_touchesCancelled:touches scale:scale];
}

- (int)devicePosition
{
    AVCaptureDevicePosition currentCameraPosition = [[self.videoInput device] position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

//判断闪光灯是否开启
- (BOOL)lightSwitchOn
{
    BOOL isOn = NO;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch]) {
        if (captureDevice.torchMode == AVCaptureTorchModeOn) {
            isOn = YES;
        } else {
            isOn = NO;
        }
    } else {
        isOn = NO;
    }
    return isOn;
}


- (void)rotateCamera
{
    if (self.roating) {
        return;
    }
    
    self.roating = YES;
    
    [self.captureSession stopRunning];
    
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = [[self.videoInput device] position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        currentCameraPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == currentCameraPosition)
        {
            backFacingCamera = device;
        }
    }
    self.avCaptureDevice = backFacingCamera;
    
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    if (newVideoInput != nil)
    {
        [self.captureSession beginConfiguration];
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
        if (self.is1080PResolution) {
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
            }
        }
        
        [self.captureSession removeInput:self.videoInput];
        if ([self.captureSession canAddInput:newVideoInput])
        {
            [self.captureSession addInput:newVideoInput];
            self.videoInput = newVideoInput;
        }
        else
        {
            [self.captureSession addInput:self.videoInput];
        }
        
        if(SHOULD_PORTRAIT){
            self.videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([self.videoConnection isVideoOrientationSupported]) {
                [self.videoConnection setVideoOrientation:self.videoOrientation];
            }
            
            if (backFacingCamera.position == AVCaptureDevicePositionFront) {
                self.videoConnection.videoMirrored = self.videoMirrored;
            }else {
                self.videoConnection.videoMirrored = NO;
            }
        }
        else{
            
        }
        [self.captureSession commitConfiguration];
        
        [self setCaptureFrameRate:self.frameRate];
    }
    
    [self.captureSession startRunning];
    
    self.roating = NO;
}

//打开或者关闭闪光灯
- (void)openLightSwitch:(BOOL)isOpen
{
    if (isOpen) {
        //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else{
        //关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    if (!self.isLandscape) {
        return;
    }
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.arContentView.transform = CGAffineTransformIdentity;
            
            self.arContentView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.arContentView.layer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            self.arContentView.transform = CGAffineTransformIdentity;
            
            self.arContentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
            self.arContentView.layer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)startCapture {
    self.isCapturePaused = NO;
    if (self.captureSession && ![self.captureSession isRunning]) {
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
        //        });
    }
}

- (void)stopCapture
{
    self.isCapturePaused = YES;
    if (self.captureSession)
    {
        [self.captureSession stopRunning];
        
        [self.videoOutput setSampleBufferDelegate:nil queue:nil];
        [self.audioOutput setSampleBufferDelegate:nil queue:nil];
        
        [self.captureSession removeInput:self.videoInput];
        [self.captureSession removeOutput:self.videoOutput];
        [self.captureSession removeOutput:self.audioOutput];
        
        self.videoOutput = nil;
        self.videoInput = nil;
        self.audioOutput = nil;
        self.captureSession = nil;
        self.avCaptureDevice = nil;
    }
}

- (void)pauseCapture {
    self.isCapturePaused = YES;
}

- (void)resumeCapture {
    self.isCapturePaused = NO;
    if (!self.captureSession.isRunning) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if(!self.captureSession.isRunning){
                [self.captureSession startRunning];
            }
        });
    }
}

- (void)removeContaintView
{
    self.gestureView.gesturedelegate = nil;
    [self.gestureView removeFromSuperview];
    self.gestureView = nil;
}

#pragma mark - For Face

- (void)adjustFocusAtPoint:(CGPoint)point {
    if (self.isTrackingSucceed) {
        [self manualFocusAtPoint:point];
    }
}

- (void)manualAdjustFocusAtPoint:(CGPoint)point {
    [self manualFocusAtPoint:point];
}

- (void)manualFocusAtPoint:(CGPoint)point {
    if ([self.avCaptureDevice isFocusPointOfInterestSupported] && [self.avCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        NSError *error;
        if ([self.avCaptureDevice lockForConfiguration:&error])
        {
            [self.avCaptureDevice setFocusPointOfInterest:point];
            [self.avCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [self.avCaptureDevice unlockForConfiguration];
        } else {
            NSLog(@"focus error :%@", error);
        }
    }
    
    //    if([self.avCaptureDevice isExposurePointOfInterestSupported] && [self.avCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    //    {
    //        NSError *error;
    //        if ([self.avCaptureDevice lockForConfiguration:&error])
    //        {
    //            [self.avCaptureDevice setExposurePointOfInterest:point];
    //            [self.avCaptureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    //            [self.avCaptureDevice unlockForConfiguration];
    //        } else {
    //            NSLog(@"exposure error :%@", error);
    //        }
    //    }
}

- (void)tapAdjustFocusToDrawRectangle:(NSArray *)points {
    if (self.autoRecLayer) {
        [self removeRectangleLayer:self.autoRecLayer isAuto:NO];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.manualRecLayer = [weakSelf drawRectangle:points layer:weakSelf.manualRecLayer isAuto:NO];
        if (weakSelf.manualRecLayer) {
            [weakSelf.arContentView.layer addSublayer:weakSelf.manualRecLayer];
            [weakSelf autoRemoveRectangleLayer:weakSelf.manualRecLayer];
        }
    });
}

- (CAShapeLayer *)drawRectangle:(NSArray *)points layer:(CAShapeLayer *)layer isAuto:(BOOL)isAuto{
    int minWidth = MIN(self.cameraSize.width, self.cameraSize.height);
    CGFloat scale = (minWidth > FACE_DEFAULT_OUTPUT_IMAGE_WIDTH ? minWidth : FACE_DEFAULT_OUTPUT_IMAGE_WIDTH) / [UIScreen mainScreen].bounds.size.width;
    NSArray *tempPoints = [points copy];
    CGPoint minXY = CGPointZero, maxXY = CGPointZero;
    if (tempPoints && [tempPoints count] == 2) {
        minXY = [[tempPoints objectAtIndex:0] CGPointValue];
        maxXY = [[tempPoints objectAtIndex:1] CGPointValue];
    }
    if (!self.isTrackingSucceed && (CGPointEqualToPoint(minXY, CGPointZero) || CGPointEqualToPoint(minXY, CGPointMake(2000, 2000)))) {
        if (self.autoRecLayer) {
            [self removeRectangleLayer:self.autoRecLayer isAuto:YES];
        }
        return nil;
    }
    
    double recHeight = fabs(maxXY.y - minXY.y);
    double recWidth = fabs(maxXY.x - minXY.x);
    
    double leftX = 0;
    double leftY = 0;
    
    if(SHOULD_PORTRAIT) {
        if ([self devicePosition] == 0) {
            leftX = (minXY.x - 0.2 * recWidth) / scale;
            leftY = (minXY.y - 0.2 * recHeight) / scale;
        }else {
            if (self.videoConnection.videoMirrored) {
                leftX = (minXY.x - 0.2 * recWidth) / scale;
                leftY = (minXY.y - 0.2 * recHeight) / scale;
            }else {
                leftX = (SCREEN_WIDTH - (minXY.x + 0.4 * recWidth)) / scale;
                leftY = (minXY.y - 0.2 * recHeight) / scale;
            }
        }
    }else {
        if ([self devicePosition] == 0) {
            leftY = (minXY.x - 0.2 * recWidth) / scale;//SCREEN_HEIGHT - (minXY.x + (1 + 0.2) * recWidth) / scale;
            leftX = SCREEN_WIDTH - (minXY.y + (1 + 0.2) * recHeight) / scale;//(minXY.y - 0.2 * recHeight) / scale;
        }else {
            leftY = (minXY.x - 0.2 * recWidth) / scale;
            leftX = (minXY.y - 0.2 * recHeight) / scale;
        }
    }
    
    CGRect pathRect = CGRectZero;
    if (isAuto) {
        pathRect = CGRectMake(leftX, leftY, recHeight * 1.4 / scale , recWidth * 1.4 / scale);
    }else {
        pathRect = CGRectMake(minXY.x, minXY.y, recWidth, recHeight);
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:pathRect];
    
    if (!layer) {
        layer = [[CAShapeLayer alloc] init];
    }
    layer.path = path.CGPath;
    layer.lineWidth = 2;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor yellowColor].CGColor;
    
    return layer;
}

- (void)autoRemoveRectangleLayer:(CAShapeLayer *)layer {
    if (layer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [layer removeFromSuperlayer];
        });
    }
}

- (void)removeRectangleLayer:(CAShapeLayer *)layer isAuto:(BOOL)isAuto{
    if (layer) {
        [layer removeFromSuperlayer];
        if (isAuto) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isAutoRecLayerExist = NO;
            });
        }
    }
}

- (CGPoint)getCenterPoint:(NSArray *)points {
    // 左上和右下两个点
    CGPoint leftP = CGPointMake(0, 0);
    CGPoint rightP = CGPointMake(2000, 2000);
    if (points && points.count == 2) {
        leftP = [[points objectAtIndex:0] CGPointValue];
        rightP = [[points objectAtIndex:1] CGPointValue];
    }
    int minWidth = MIN(self.cameraSize.width, self.cameraSize.height);
    CGFloat scale = (minWidth > FACE_DEFAULT_OUTPUT_IMAGE_WIDTH ? minWidth : FACE_DEFAULT_OUTPUT_IMAGE_WIDTH) / SCREEN_WIDTH;
    CGPoint tempPoint;
    double recWidth = fabs(rightP.x - leftP.x);
    double recHeight = fabs(rightP.y - leftP.y);
    double centerX = 0;
    double centerY = 0;
    
    if (SHOULD_PORTRAIT) {
        if ([self devicePosition] == 0) {
            centerX = (leftP.x + recWidth / 2) / scale;
            centerY = (leftP.y + recHeight / 2) /scale;
        }else {
            if (self.videoConnection.videoMirrored) {
                centerX = (leftP.x + recWidth / 2) / scale;
                centerY = (leftP.y + recHeight / 2) /scale;
            }else {
                centerX = SCREEN_WIDTH - (leftP.x + recWidth  - recWidth/ 2) / scale;
                centerY = (leftP.y + recHeight / 2) /scale;
            }
        }
    }else {
        if (self.devicePosition == 0) {
            centerY = (leftP.x + recWidth - recWidth / 2) / scale;
            centerX = SCREEN_WIDTH - (leftP.y + recHeight - recHeight / 2) / scale;
        }else {
            centerY = (leftP.x + recWidth / 2) / scale;
            centerX = (leftP.y + recHeight / 2) /scale;
        }
    }
    
    tempPoint = CGPointMake(centerY / SCREEN_HEIGHT, centerX / SCREEN_WIDTH);
    
    return tempPoint;
}

- (void)removeFocusRectangle {
    if (self.autoRecLayer) {
        [self.autoRecLayer removeFromSuperlayer];
    }
    if (self.manualRecLayer) {
        [self.manualRecLayer removeFromSuperlayer];
    }
}

- (void)autoAdjustFocusToDrawRectangle:(NSArray *)points faceAssetsLoad:(BOOL)isLoad {
    if (!points) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.autoRecLayer = [weakSelf drawRectangle:points layer:weakSelf.autoRecLayer isAuto:YES];
        if (!weakSelf.isAutoRecLayerExist && weakSelf.autoRecLayer) {
            if (weakSelf.manualRecLayer) {
                [weakSelf removeRectangleLayer:self.manualRecLayer isAuto:NO];
            }
            if (!isLoad) {
                [weakSelf.arContentView.layer addSublayer:weakSelf.autoRecLayer];
                [weakSelf autoRemoveRectangleLayer:weakSelf.autoRecLayer];
            }
            
            weakSelf.isAutoRecLayerExist = YES;
            [weakSelf adjustFocusAtPoint:[weakSelf getCenterPoint:points]];
        }
    });
}

#pragma mark - face notification
//- (void)drawFaceBoxRectangle:(NSNotification *)info {
//    NSDictionary *dic = info.object;
//    if (dic) {
//        NSArray *points = [dic objectForKey:@"points"];
//        if (points) {
//            [self autoAdjustFocusToDrawRectangle:points faceAssetsLoad:self.isFaceAssetsLoaded];
//        }
//    }
//}

- (void)drawFaceBoxRectangle:(NSArray *)points {
    if (!self.isInitCamera) {
        return;
    }
    if (points) {
        [self autoAdjustFocusToDrawRectangle:points faceAssetsLoad:self.isFaceAssetsLoaded];
    }
}


@end

#endif
