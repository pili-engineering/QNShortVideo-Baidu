//
//  BARBusinessViewController.m
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/7/5.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import "RecordViewController.h"
#import <PLShortVideoKit/PLShortVideoKit.h>

#import <ARSDKProOpenSDK/ARSDKProOpenSDK.h>
#import "DARRenderViewController.h"
#import "BARBaseView.h"
#import "BARBaseView+ARLogic.h"
#import "DARFiltersController.h"
#import "BARShareViewControllers.h"
#import "DarFaceAlgoModleParse.h"
#import "DARFaceDecalsController.h"
#import "EditViewController.h"
#import "BARGestureView.h"

#define IPAD     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define ASPECT_RATIO (IPAD ? (4.0/3.0) : (16.0/9.0))

#define SHOULD_MIRROR 1  //是否要根据设备方向做镜像

#define FILTER_RATIO  0.8  //滤镜透明度所乘的比例系数

#define SAMPLE_BUffER_LAYER 1

typedef NS_ENUM(NSUInteger, BARDeviceType) {
    BARDeviceTypeLow,
    BARDeviceTypeMedium,
    BARDeviceTypeHigh,
    BARDeviceTypeUnknow
};

@interface RecordViewController ()<UINavigationControllerDelegate, UIAlertViewDelegate, BARARKitModuleDelegate, BARGestureImageViewDelegate, PLShortVideoRecorderDelegate>
{
    BOOL _recording;
}

/** UI */
@property (nonatomic, strong) BARBaseView *baseUIView;
@property (nonatomic, strong) UIView *replacedView;
//@property (nonatomic, strong) AVSampleBufferDisplayLayer *bufferLayer;

/** AR */
@property (nonatomic, strong) BARMainController *arController; //AR控制器
@property (nonatomic, strong) BARARKitModule *arkitModule;     //ARKit相机

/** 人脸 */
@property (nonatomic, assign) BOOL isFirstShowDecal;
@property (nonatomic, assign) BOOL loadFirstAssetsFinished;
@property (nonatomic, assign) BOOL isFaceAssetsLoaded;
@property (nonatomic, assign) BOOL isFaceTrackLoadingSucceed;
@property (nonatomic, assign) BOOL isFaceTrackingSucceed;
@property (nonatomic, strong) NSMutableDictionary *faceBeautyLastValueDic;
@property (nonatomic, assign) CGFloat filterLastValue;
@property (nonatomic, copy) NSString *currentTrigger;
@property (nonatomic, copy) NSString *currentBeauty;
@property (nonatomic, strong) DARFaceDecalsController *faceDecalsController;
@property (nonatomic, strong) DARFiltersController *filtersController;
@property (nonatomic, assign) BOOL isManualFocus;
@property (nonatomic, strong) NSString *currentFilterID;

/** 其他属性 */
@property (nonatomic, copy) NSString *arKey;
@property (nonatomic, copy) NSString *arType;
@property (assign, nonatomic) BOOL viewAppearDoneAtLeastOnce;
@property (nonatomic, assign) BOOL willGoToShare;
//@property (nonatomic, assign) BOOL needDelayChangeToARView;

@property (nonatomic, strong) DarFaceAlgoModleParse *darFaceAlgoModleParse;
@property (nonatomic, assign) CFAbsoluteTime m_lastRenderTime;

@property (nonatomic, strong) NSDictionary *demo_trigger_config_list;


@property (assign, nonatomic) CMSampleBufferRef lastARSample;
@property (nonatomic, assign) BOOL roating;
@property (strong, nonatomic) BARGestureView *gestureView;

// ==== 七牛 =====
@property (strong, nonatomic) PLSVideoConfiguration *videoConfiguration;
@property (strong, nonatomic) PLSAudioConfiguration *audioConfiguration;
@property (strong, nonatomic) PLShortVideoRecorder *shortVideoRecorder;
@end

@implementation RecordViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    if (self.navigationController) {
        self.navigationController.delegate = self;
    }
    
    if (self.viewAppearDoneAtLeastOnce) {
        //首次进入不调用resumeAR，从预览页或其他页面回来才调用
        [self resumeAR];
    } else{
        self.viewAppearDoneAtLeastOnce = YES;
    }
    self.baseUIView.screenshotBtn.enabled = YES;
    
    [self.shortVideoRecorder startCaptureSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (self.disappearBlock) {
        self.disappearBlock();
    }
    
    [self resetlightStatus];
    [self pauseAR];
    [[BARAlert sharedInstance] dismiss];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.shortVideoRecorder stopCaptureSession];
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    if (self.arkitModule) {
        [self.arkitModule cleanARKitModule];
        self.arkitModule = nil;
    }
    [self removeNotificationsObserver];
}

#pragma mark - Lifecycle

/**
 ReadMe：
 case的几个操作流程如下：
 加载AR --> 下载AR资源包并且加载AR
 启动AR --> 加载AR成功后，调用startAR
 */

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupShortVideoRecorder];
    
    if ([BARSDKPro isSupportAR]) {
        [self setUpNotifications]; //设置通知
        [self loadFaceData];       //设置人脸资源
        [self setupARView];        //设置ARView
        [self setupUIView];        //设置UI
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied) {
            [self showAlert:@"请在设置中打开相机权限"];
        } else if(status == AVAuthorizationStatusAuthorized) {
            [self cameraAuthorizedFinished];
        } else if(status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self cameraAuthorizedFinished];
                    } else {
                        [self showAlert:@"请在设置中打开相机权限"];
                    }
                });
            }];
        } else {
            [self showAlert:@"请在设置中打开相机权限"];
        }
    }
}

// 短视频录制核心类设置
- (void)setupShortVideoRecorder {
    
    // SDK 的版本信息
    NSLog(@"PLShortVideoRecorder versionInfo: %@", [PLShortVideoRecorder versionInfo]);
    
    // SDK 授权信息查询
    [PLShortVideoRecorder checkAuthentication:^(PLSAuthenticationResult result) {
        NSString *authResult[] = {@"NotDetermined", @"Denied", @"Authorized"};
        NSLog(@"PLShortVideoRecorder auth status: %@", authResult[result]);
    }];
    
    self.videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
    self.videoConfiguration.position = AVCaptureDevicePositionFront;
    self.videoConfiguration.videoFrameRate = 30;
    self.videoConfiguration.videoSize = CGSizeMake(720, 1280);
    self.videoConfiguration.averageVideoBitRate = 4 * 1000 * 1000;
    self.videoConfiguration.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoConfiguration.sessionPreset = AVCaptureSessionPreset1280x720;
    
    self.audioConfiguration = [PLSAudioConfiguration defaultConfiguration];
    
    self.shortVideoRecorder = [[PLShortVideoRecorder alloc] initWithVideoConfiguration:self.videoConfiguration audioConfiguration:self.audioConfiguration];
    self.shortVideoRecorder.delegate = self;
    self.shortVideoRecorder.maxDuration = 10.0f; // 设置最长录制时长
    [self.shortVideoRecorder setBeautifyModeOn:YES]; // 默认打开美颜
    self.shortVideoRecorder.outputFileType = PLSFileTypeMPEG4;
    self.shortVideoRecorder.innerFocusViewShowEnable = YES; // 显示 SDK 内部自带的对焦动画
    self.shortVideoRecorder.previewView.frame = self.view.bounds;
    self.shortVideoRecorder.touchToFocusEnable = NO;
    [self.view addSubview:self.shortVideoRecorder.previewView];
    self.shortVideoRecorder.backgroundMonitorEnable = NO;
}

- (void)cameraAuthorizedFinished{
    [self setupARController];//设置AR控制器
//    #error 设置申请的APPID、APIKey https://dumix.baidu.com/dumixar
    [BARSDKPro setAppID:@"25" APIKey:@"e0f9dd03f6ba90db7ef3582d2df1d496" andSecretKey:@""];//SecretKey可选
    NSString *version = [BARSDKPro arSdkVersion];
    NSLog(@"sdk version is %@",version);
    [self setupComponents];
}

- (void)setupComponents{
    //设置ARKit（可选）
    self.arkitModule = [[BARARKitModule alloc] init];
    self.arkitModule.arkitDelegate = self;
    [self.arkitModule setupARController:self.arController];
    [self.arkitModule setupARKitControllerWithRatio:ASPECT_RATIO];
}

#pragma mark - Notifications

- (void)setUpNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotificationsObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self pauseAR];

    if (self.shortVideoRecorder.isTorchOn) {
        [self.shortVideoRecorder setTorchOn:NO];
    }
    
    if(self.baseUIView.shootingVideo){
        [self.baseUIView stopShootVideo];
    }
    
    [self.baseUIView willEnterBackground];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self pauseAR];
    
    if ([self.shortVideoRecorder isTorchOn]) {
        [self.shortVideoRecorder setTorchOn:NO];
    }
    if(self.baseUIView.shootingVideo){
        [self.baseUIView stopShootVideo];
    }
    
    [self.baseUIView willEnterBackground];
}

- (void)applicationEnterForeground:(NSNotification *)notification {
    if ([self isVisiable]) {
        if(!self.willGoToShare){
            [self resumeAR];
            //锁屏或切到后台后，再次进入如果上次录制时间过短则显示“录制时间过短”提示
            if(self.shortVideoRecorder.getTotalDuration > 0.0 && self.shortVideoRecorder.getTotalDuration < self.shortVideoRecorder.minDuration){
                [self showRecordVideoTooShort];
//                self.videoRecorder.videoDuration = 0; hera
            }
        }
    }
}

#pragma mark - Setup

- (void)loadFaceData {
    self.isFirstShowDecal = YES;
    self.darFaceAlgoModleParse = [[DarFaceAlgoModleParse alloc] init];
    self.faceBeautyLastValueDic = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    
    //贴纸列表
    self.faceDecalsController = [[DARFaceDecalsController alloc] init];
    self.faceDecalsController.plistPath = self.plistPath;
    [self.faceDecalsController queryDecalsListWithFinishedBlock:nil];
    [self.faceDecalsController setDecalsSwitchBlock:^(DARFaceDecalsModel *model) {
        
    }];
    [self.faceDecalsController setUpdateDecalsArray:^{
        [weakSelf.baseUIView updateDecals:weakSelf.faceDecalsController.decalsArray];
    }];
    
    //滤镜列表
    self.filtersController = [[DARFiltersController alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    NSString *filterPath = [path stringByAppendingPathComponent:@"Filter/ar"];
    [self.filtersController queryFiltersResultWithFilterPath:filterPath queryFinishedBlock:nil];
    [self.filtersController setFilterSwitchBlock:^(NSDictionary *dic) {
        NSLog(@"dic %@",dic);
        NSString *filterID = @"500038";
        if (dic != nil) {
            NSDictionary *filterDic = [dic objectForKey:@"filter"];
            filterID = [[filterDic objectForKey:@"filter_group_id"] stringValue];
            [weakSelf.arController switchFilter:filterID];
            weakSelf.currentFilterID = filterID;
            //当切回滤镜时读取之前的参数，设置滤镜效果并修改滑块值
            CGFloat filterDefaultValue = weakSelf.filterLastValue;
            
            if ([filterID isEqualToString:@"500001"]) {
                // 原图滤镜的默认值
                filterDefaultValue = 0.4;
            }
            [weakSelf.arController adjustFilterType:BARFaceBeautyTypeNormalFilter value:filterDefaultValue * FILTER_RATIO];
        } else {
            [weakSelf.arController adjustFilterType:BARFaceBeautyTypeNormalFilter value:0];
            [weakSelf.baseUIView updateBeautySliderValue:0 type:0];
        }
    }];
}

//配置FaceAR
- (void)setupARController {
    __weak typeof(self) weakSelf = self;
    self.arController = [[BARMainController alloc] initARWithCameraSize:self.videoConfiguration.videoSize previewSize:self.videoConfiguration.videoSize];
    [self.arController setAlgorithmModelsPath:[[NSBundle mainBundle] pathForResource:@"dlModels" ofType:@"bundle"]];
    
    [self.arController setDevicePosition:[self devicePosition] needArMirrorBuffer:[self demoNeedARMirrorBuffer]];
    [self.arController setVideoOrientation:self.videoConfiguration.videoOrientation];
    
    if (SAMPLE_BUffER_LAYER) {
        [self.arController setPipeline:BARPipelineFramebuffer];
        weakSelf.m_lastRenderTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"..");
        [self.arController setRenderSampleBufferCompleteBlock:^(CMSampleBufferRef sampleBuffer, id extraData) {
            if (weakSelf.lastARSample) {
                CFRelease(weakSelf.lastARSample);
                weakSelf.lastARSample = NULL;
            }
            weakSelf.lastARSample = sampleBuffer;
            CFRetain(weakSelf.lastARSample);
//            [weakSelf.renderVC updateRenderSampleBuffer:sampleBuffer];
            
            NSDictionary* attachmentWithTime = (NSDictionary*)extraData;
            double beginTime = [attachmentWithTime[@"startTime"] doubleValue];
            double processIntervalTime = CFAbsoluteTimeGetCurrent() - beginTime;
            NSString *frameTimeInfo = [NSString stringWithFormat:@"每帧处理时长 %.1f",processIntervalTime*1000];
//            NSLog(@"setupARController - %@", frameTimeInfo);
            weakSelf.m_lastRenderTime = CFAbsoluteTimeGetCurrent();
        }];
    };
    
    [self.arController setUiStateChangeBlock:^(BARSDKUIState state, NSDictionary *stateInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case BARSDKUIState_DistanceNormal:
                {
                    
                }
                    break;
                case BARSDKUIState_DistanceTooFar:
                case BARSDKUIState_DistanceTooNear:
                {
                    NSLog(@"过远，过近");
                }
                    break;
                case BARSDKUIState_TrackLost_HideModel:
                {
                    [weakSelf.arController setBAROutputType:BAROutputVideo];
                }
                    break;
                case BARSDKUIState_TrackLost_ShowModel:
                {
                    NSLog(@"跟踪丢失,显示模型");
                }
                    break;
                case BARSDKUIState_TrackOn:
                {
                    [weakSelf.arController setBAROutputType:BAROutputBlend];
                    break;
                }
                case BARSDKUIState_TrackTimeOut:
                {
                    //跟踪超时
                }
                    break;
                default:
                    break;
            }
        });
    }];
    
    self.arController.luaMsgBlock = ^(BARMessageType msgType, NSDictionary *dic) {
        switch (msgType) {
            case BARMessageTypeOpenURL:
            {
                //打开浏览器
                NSString *urlStr = dic[@"url"];
                if (urlStr) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                }
            }
                break;
            case BARMessageTypeEnableFrontCamera:
            {
                //允许前置摄像头使用
            }
                break;
            case BARMessageTypeChangeFrontBackCamera:
            {
                //前后摄像头切换
                [weakSelf cameraSwitchBtnClick];
            }
                break;
            case BARMessageTypeIntitialClick:
            {
                //引导图点击
            }
                break;
            case BARMessageTypeNativeUIVisible:
            {
                //隐藏或者显示界面元素
            }
                break;
            case BARMessageTypeCloseAR:
            {
                [weakSelf closeARView];
            }
                break;
            case BARMessageTypeShowAlert:
            {
                //展示弹框
            }
                break;
            case BARMessageTypeShowToast:
            {
                //展示提示框
            }
                break;
            case BARMessageTypeSwitchCase:
            {
                //切换Case
            }
                break;
            case BARMessageTypeBatchDownloadRetryShowDialog:
            {
                //分布加载
                [weakSelf handleBatchDownload];
            }
                break;
            case BARMessageTypeCustom:
            {
                NSLog(@"dic %@",dic);
                NSString *msgId = [[dic objectForKey:@"id"] description];
                NSInteger msgType = [msgId intValue];
                switch (msgType) {
                    case 10100:
                    {
                        NSLog(@"消息A：Do what you want to do.");
                    }
                        break;
                    case 10101:
                    {
                        NSLog(@"消息B：Do what you want to do.");
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
    };
    
    [self.arController setShowAlertEventBlock:^(BARSDKShowAlertType type, dispatch_block_t cancelBlock, dispatch_block_t ensureBlock, NSMutableDictionary *info) {
        NSString *alertMsg = nil;
        switch (type) {
            case BARSDKShowAlertType_CaseVersion_Error:
            {
                [weakSelf showAlert:@"case版本号与SDK版本号不符"];
            }
                break;
            case BARSDKShowAlertType_NetWrong:
                //网络错误
                alertMsg = @"网络异常";
                break;
            case BARSDKShowAlertType_SDKVersionTooLow:
                //版本太低
                alertMsg = @"版本太低";
                break;
            case BARSDKShowAlertType_Unsupport:
            {
                //机型、系统、SDK版本等不支持
                NSString *url = [info objectForKey:@"help_url"];//退化URL
                alertMsg = @"机型、系统、SDK版本等不支持";
            }
                break;
            case BARSDKShowAlertType_ARError:
            case BARSDKShowAlertType_LuaInvokeSDKToast:
            {
                alertMsg = [info objectForKey:@"msg"] ? : @"出错啦";
                break;
            }
            case BARSDKShowAlertType_BatchZipDownloadFail:
                //分布下载，网络异常
                alertMsg = @"分布下载出错";
                break;
            case BARSDKShowAlertType_LuaInvokeSDKAlert:{
                //lua中调起AlertView
                NSString *title = [info objectForKey:@"title"];
                NSString *msg = [info objectForKey:@"msg"];
                NSString *confirm_text = [info objectForKey:@"confirm_text"];
                NSString *cancel_text = [info objectForKey:@"cancel_text"];
                alertMsg = title;
            }
                break;
            case BARSDKShowAlertType_AuthenticationError:
            {
                //鉴权识别
                alertMsg = @"鉴权失败";
                [weakSelf.baseUIView resetDecalsViewData];
            }
                break;
            default:
                break;
        }
        if (alertMsg) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL];
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:NULL];
        }
    }];
    [self.arController initFaceData];
    [self.arController setImbin:[self getImbinPath]];
    [self.arController setFaceDetectModelPath:[self getDetectPath]];
    [self.arController setFaceTrackModelPaths:[self getTrackPaths]];
    
    [self.arController lowDeviceStopAlgoWhenRender:NO];
    
    NSString *deviceInfo = [BARUIDevice barPlatformString];
    BARDeviceType deviceType = [self getDeviceType:deviceInfo];
    
    NSString *trackingSmoothAlpha = [self.darFaceAlgoModleParse trackingSmoothAlpha:deviceType];
    NSString *trackingSmoothThreshold = [self.darFaceAlgoModleParse trackingSmoothThreshold:deviceType];
    
    [self.arController setFaceAlgoInfo:@{@"faceSyncProcess":@(YES),
                                         @"deviceInfo":deviceInfo,
                                         @"deviceType":@(deviceType),
                                         @"printLog":@(NO),
                                         @"trackingSmoothAlpha":trackingSmoothAlpha,
                                         @"trackingSmoothThreshold":trackingSmoothThreshold,
                                         }];
    
    //加载滤镜配置文件
    NSString *filterConfigPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.arController loadFaceFilterDefaultConfigWith:filterConfigPath];
    self.faceBeautyLastValueDic = [[self.arController getFaceConfigDic] mutableCopy];
    [self.faceBeautyLastValueDic setValue:[[self.arController getFilterConfigsDic] mutableCopy] forKey:@"filter"];
    self.currentFilterID = @"500001";
    [self setBeautyDefaultValue:weakSelf.faceBeautyLastValueDic];
    
    //贴纸加载成功
    [self.arController setFaceAssetLoadingFinishedBlock:^(NSArray *triggerList) {
        [weakSelf parseTriggerList:triggerList];
    }];
    
    //box人脸rect，facePoints 特征点， isTracking
    [self.arController setFaceDrawFaceBoxRectangleBlock:^(CGRect box, NSArray *facePoints, BOOL isTracking) {
        if(isTracking){
            weakSelf.isManualFocus = NO;
        }else {
            // 屏幕中心对焦
            if (!weakSelf.isManualFocus) {
                weakSelf.shortVideoRecorder.focusPointOfInterest = CGPointMake(.5, .5);
                weakSelf.isManualFocus = YES;
            }
        }
        // 人脸对焦
        [weakSelf autoFocusAtFace:facePoints];
    }];
    
    //每次算法识别到人脸的表情
    [self.arController setFaceTriggerListLogBlock:^(NSArray *triggerList) {
        [triggerList enumerateObjectsUsingBlock:^(NSString *triggerStr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *array = [triggerStr componentsSeparatedByString:@":"];
            if(array.count==2){
                if ([weakSelf.currentTrigger containsString:array[0]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.baseUIView.triggerLabel.hidden = YES;
                        weakSelf.currentTrigger = nil;
                    });
                }
            }
        }];
    }];
    
    [self.arController setFaceFrameAvailableBlock:^(NSDictionary *frameDict ,CMSampleBufferRef originBuffer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isFaceTrackingSucceed = [[frameDict objectForKey:@"trackingSucceeded"] boolValue];
            NSArray *facePoints = frameDict[@"facePointList"];
            [weakSelf refreshFaceTrackDemoUI];
        });
    }];
    
    [self start:nil];
    [self.arController switchFilter:self.currentFilterID];
    
    {
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"face_trigger" ofType:@"json"];
        NSData *resData = [[NSData alloc] initWithContentsOfFile:resPath];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        self.demo_trigger_config_list = resDic;
    }
}

- (void)setupARView {
    [self.shortVideoRecorder.previewView removeFromSuperview];
    [self.replacedView addSubview:self.shortVideoRecorder.previewView];
}

- (void)setupUIView {
    __weak typeof(self) weakSelf = self;
    self.baseUIView = [[BARBaseView alloc] initWithFrame:self.replacedView.bounds];
    self.baseUIView.clickEventHandler = ^(BARClickActionType action, NSDictionary *data) {
        [weakSelf handleButtonAction:action data:data];
    };
    [self.replacedView addSubview:self.baseUIView];
    
    _gestureView = [[BARGestureView alloc]initWithFrame:self.view.bounds];
    [self.gestureView setBackgroundColor:[UIColor clearColor]];
    [self.replacedView insertSubview:_gestureView belowSubview:self.baseUIView];
    _gestureView.gesturedelegate = (id<BARGestureDelegate>)self;

    [self.baseUIView addFaceUI];
    [self.baseUIView showAllViews];
    self.baseUIView.lightSwitchBtn.hidden = YES;
    self.baseUIView.cameraSwitchBtn.hidden = NO;
    self.baseUIView.cameraSwitchBtn.userInteractionEnabled = YES;
    [self.baseUIView setRecordButtonAndSwitchViewEnable:YES];
}

- (void)loadLocalAR:(NSDictionary *)dic {
    NSString *artype = dic[@"type"];
    NSString *path = dic[@"name"];
    NSString *arkey = dic[@"arkey"];
    if (path && [path length] > 0) {
        [self hideFaceDemoUI];
        if (![self.arType isEqualToString:artype]) {
            self.arType = artype;
        }
        __weak typeof(self) weakSelf = self;
        [self.arController loadARFromFilePath:path arKey:arkey arType:artype success:^(NSString *arKey, kBARType arType) {
            [weakSelf handleARKey:arKey arType:arType];
            [weakSelf.baseUIView handleSwitchDone];
        } failure:^{
            NSString *tipStr = BARNSLocalizedString(@"bar_tip_load_resources_fail");
            [[BARAlert sharedInstance] showToastViewPortraitWithTime:1.0f title:nil message:tipStr dismissComplete:nil];
            [weakSelf.baseUIView resetDecalsViewData];
        }];
    }
}

//卸载当前case，以及当前case使用的组件能力
- (void)unLoadCase {
    [self.arController cancelDownLoadArCase];
}

- (void)handleARKey:(NSString *)arKey arType:(kBARType)arType {
    if (arKey && ![arKey isEqualToString:@""]) {
        self.arKey = arKey;
    }
    self.arType = [NSString stringWithFormat:@"%i",arType];
    if (kBARTypeLocalSameSearch == arType) {
    } else if (kBARTypeCloudSameSearch == arType) {
    } else if (kBARTypeARKit == arType) {
    } else {
        [self start:nil];
    }
}

//启动AR
- (void)start:(id)sender{
    [self.arController startAR];
    
    if(kBARTypeFace == self.arType.integerValue){
        return;
    }
}

#pragma mark - Private

- (NSString *)getImbinPath {
    return  [self.darFaceAlgoModleParse imbinPath];
}

- (NSString *)getDetectPath {
    if (self.faceAlgoModelDic) {
        return self.faceAlgoModelDic[@"detectPath"];
    }
    return  [self.darFaceAlgoModleParse detectPath];
}

- (NSArray *)getTrackPaths {
    if (self.faceAlgoModelDic) {
        return self.faceAlgoModelDic[@"trackArray"];
    }
    NSString *deviceInfo = [BARUIDevice barPlatformString];
    BARDeviceType deviceType = [self getDeviceType:deviceInfo];
    return [self.darFaceAlgoModleParse trackPaths:deviceType];
}

- (BARDeviceType)getDeviceType:(NSString *)deviceInfo {
    BARDeviceType deviceType = BARDeviceTypeUnknow;
    NSString *deviceConfigPath = [[NSBundle mainBundle] pathForResource:@"device_config" ofType:@"json"];
    NSData *deviceData = [[NSData alloc] initWithContentsOfFile:deviceConfigPath];
    NSDictionary *deviceDic = [NSJSONSerialization JSONObjectWithData:deviceData options:NSJSONReadingMutableLeaves error:nil];
    
    id highDevice = [deviceDic objectForKey:@"high"];
    if (highDevice && [highDevice isKindOfClass:[NSArray class]]) {
        for (NSString *temp in highDevice) {
            if ([temp isEqualToString:deviceInfo]) {
                deviceType = BARDeviceTypeHigh;
                return deviceType;
            }
        }
    }
    
    id mediumDevice = [deviceDic objectForKey:@"medium"];
    if (mediumDevice && [mediumDevice isKindOfClass:[NSArray class]]) {
        for (NSString *temp in mediumDevice) {
            if ([temp isEqualToString:deviceInfo]) {
                deviceType = BARDeviceTypeMedium;
                return deviceType;
            }
        }
    }
    
    id lowDevice = [deviceDic objectForKey:@"low"];
    if (lowDevice && [lowDevice isKindOfClass:[NSArray class]]) {
        for (NSString *temp in lowDevice) {
            if ([temp isEqualToString:deviceInfo]) {
                deviceType = BARDeviceTypeLow;
                return deviceType;
            }
        }
    }
    return deviceType;
}

- (BOOL)isVisiable {
    return (self.isViewLoaded && self.view.window);
}

/**
 拍摄视频后跳转到保存页
 
 */
- (void)goEditViewController {
    // 获取当前会话的所有的视频段文件
    AVAsset *asset = [self.shortVideoRecorder assetRepresentingAllFiles];
    NSArray *filesURLArray = [self.shortVideoRecorder getAllFilesURL];
    NSLog(@"filesURLArray:%@", filesURLArray);
    
    __block AVAsset *movieAsset = asset;
    // 设置音视频、水印等编辑信息
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] init];
    // 待编辑的原始视频素材
    NSMutableDictionary *plsMovieSettings = [[NSMutableDictionary alloc] init];
    plsMovieSettings[PLSAssetKey] = movieAsset;
    plsMovieSettings[PLSStartTimeKey] = [NSNumber numberWithFloat:0.f];
    plsMovieSettings[PLSDurationKey] = [NSNumber numberWithFloat:[self.shortVideoRecorder getTotalDuration]];
    plsMovieSettings[PLSVolumeKey] = [NSNumber numberWithFloat:1.0f];
    outputSettings[PLSMovieSettingsKey] = plsMovieSettings;
    
    EditViewController *videoEditViewController = [[EditViewController alloc] init];
    videoEditViewController.settings = outputSettings;
    videoEditViewController.filesURLArray = filesURLArray;
    [self presentViewController:videoEditViewController animated:YES completion:nil];
}

- (void)parseTriggerList:(NSArray *)triggerList {
    if (triggerList && [triggerList count] != 0) {
        NSString *key = triggerList[0];
        NSArray *comArr = [key componentsSeparatedByString:@":"];
        if(comArr.count==2){
            NSString *triggerChineseName = [self getTriggerChineseName:comArr[0]];
            if(triggerChineseName.length>0){
                self.currentTrigger = comArr[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.baseUIView.triggerLabel.text = [NSString stringWithFormat:@"请 %@", triggerChineseName];
                    [self refreshTriggerDemoUIHidden:NO];
                });
                return;
            }else{
                self.currentTrigger = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.baseUIView.triggerLabel.text = @"";
                });
            }
        }
    }
    [self refreshTriggerDemoUIHidden:YES];
}

- (NSString *)getTriggerChineseName:(NSString *)triggerName {
    __block NSString *imgName = @"";
    __block NSString *imgName1 = [triggerName copy];
    [self.demo_trigger_config_list enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if([key isEqualToString:imgName1]){
            imgName = obj;
            *stop = YES;
        }
    }];
    return [imgName copy];
}

- (void)hideFaceDemoUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.baseUIView.undetectedFaceImgView.hidden = YES;
        self.currentTrigger = nil;
        self.baseUIView.triggerLabel.hidden = YES;
    });
}

- (void)refreshTriggerDemoUIHidden:(BOOL)hidden {
    if([self.arType integerValue] == kBARTypeFace){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.baseUIView.triggerLabel.hidden = hidden;
        });
    }
}

- (void)refreshFaceTrackDemoUI {
    if([self.arType integerValue] == kBARTypeFace){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isFaceTrackingSucceed){
                self.baseUIView.undetectedFaceImgView.hidden = YES;
                if(self.currentTrigger){
                    self.baseUIView.triggerLabel.hidden = NO;
                }
            }else{
                self.baseUIView.undetectedFaceImgView.hidden = NO;
                self.baseUIView.triggerLabel.hidden = YES;
            }
        });
    }
}

- (BOOL)isIPhoneX {
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(818, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2607), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    return NO;
}

- (void)showRecordVideoTooShort{
    [[BARAlert sharedInstance] showToastViewPortraitWithTime:1 title:nil message:BARNSLocalizedString(@"bar_tip_video_too_short_alert") dismissComplete:^{
        
    }];
}

- (void)resetlightStatus {
    [self.baseUIView setLightSwitchBtnOn:NO];
//    [self.renderVC openLightSwitch:NO];
}

#pragma mark - Actions
- (void)handleButtonAction:(BARClickActionType)action data:(NSDictionary *)data {
    switch(action) {
        case BARClickActionClose:
            [self closeARView];
            break;
        case BARClickActionLightSwitch:
            [self lightSwitchButtonClicked];
            break;
        case BARClickActionCameraSwitch:
            NSLog(@"BARClickActionCameraSwitch - %ld ", (long)self.videoConfiguration.videoOrientation);

            [self cameraSwitchBtnClick];
            break;
        case BARClickActionScreenshot:
            [self screenshotBtnClick];
            break;
        case BARClickActionShootVideoStart:{
            [self shootVideoBtnStart];
            break;
        }
        case BARClickActionShootVideoStop:{
            [self shootVideoBtnStop];
            break;
        }
        case BARClickActionDecals:
        {
            [self.baseUIView decalsViewShow:self.faceDecalsController.decalsArray];
            break;
        }
        case BARClickActionTypeDecalsSwitch:
        {
            NSInteger decalsIndex = [[data objectForKey:@"index"] integerValue];
//            self.renderVC.isFaceAssetsLoaded = YES;
            DARFaceDecalsModel *model = self.faceDecalsController.decalsArray[decalsIndex];
            [self loadLocalAR:[model dic]];
            
            break;
        }
        case BARClickActionTypeCloseFace:
        {
            [self.baseUIView closeFaceView];
            break;
        }
        case BARClickActionTypeCancelDecals:
        {
            [self.faceDecalsController switchDecalWithIndex:-1];
            //self.isFaceAssetsLoaded = NO;
            self.baseUIView.undetectedFaceImgView.hidden = YES;
            [self.baseUIView hideFaceAlertImgView];
            self.currentTrigger = nil;
            [self.arController stopAR];
            [self.arController startFaceAR];
            
            NSDictionary *dic = @{@"BARNeedAnimate": @(NO)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BARNeedAnimate" object:dic userInfo:nil];
            
            [self.arController setConfigurationType:BAROutConfigurationTypeDefault];
            
            break;
        }
        case BARClickActionBeauty:
        {
            [self.baseUIView beautyViewShow:self.filtersController.filtersArray];
        }
            break;
        case BARClickActionTypeFilterAdjust: {
            [self adjustFilterWithParam:data];
            break;
        }
        case BARClickActionTypeFilterSwitch:
        {
            NSInteger filterIndex = [[data objectForKey:@"index"] integerValue];
            NSString *defaultValue = [[self.faceBeautyLastValueDic objectForKey:@"filter"] objectForKey:@"defaultValue"];
            self.filterLastValue = [defaultValue floatValue];
            [self.filtersController switchFilterWith:filterIndex];
            [self.baseUIView.beautyView setSliderValue:self.filterLastValue type:0];
            break;
        }
        case BARClickActionTypeBeautySwitch:
        {
            NSString *beauty = [data objectForKey:@"beauty"];
            NSString *defaultValue = [[self.faceBeautyLastValueDic objectForKey:beauty] objectForKey:@"defaultValue"];
            [self.baseUIView.beautyView setSliderValue:[defaultValue floatValue] type:0];
            self.currentBeauty = beauty;
            break;
        }
        case BARClickActionTypeCancelFilter:
        {
            [self.filtersController switchFilterWith:-1];
            break;
        }
        case BARClickActionTypeResetBeauty:
        {
            //先保存滤镜参数，因为重置只是重置美颜相关参数
            NSDictionary *filterDic = [self.faceBeautyLastValueDic objectForKey:@"filter"];
            self.faceBeautyLastValueDic = [[self.arController getFaceConfigDic] mutableCopy];
            [self.faceBeautyLastValueDic setValue:filterDic forKey:@"filter"];
            if (self.currentBeauty) {
                NSString *defaultValue = [[self.faceBeautyLastValueDic objectForKey:self.currentBeauty] objectForKey:@"defaultValue"];
                [self.baseUIView.beautyView setSliderValue:[defaultValue floatValue] type:0];
            }
            [self setBeautyDefaultValue:self.faceBeautyLastValueDic];
            break;
        }
        case BARClickActionTypeCancelBeauty:
        {
            self.currentBeauty = nil;
            break;
        }
        case BARClickActionTypeSwitchResolution:
        {
            break;
        }
        default:
            break;
    }
}

//停止AR
- (void)stopAR{
    [self.arController leaveAR];
    [self unLoadCase];
}

//暂停AR
- (void)pauseAR{
    [self.arController pauseAR];
    [self.shortVideoRecorder stopCaptureSession];
//    [self.renderVC pauseCapture];
}

//恢复AR
- (void)resumeAR {
    self.willGoToShare = NO;
//    [self.renderVC resumeCapture];
    [self.shortVideoRecorder startCaptureSession];
    [self.arController resumeAR];
}

- (void)closeARView {
    [self stopAR];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.shortVideoRecorder stopCaptureSession];
    }];
}

//视频录制
- (void)shootVideoBtnStart {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shootVideoBtnStartAction:granted];
            });
        }];
    }
    else if(status == AVAuthorizationStatusDenied) {
        [self shootVideoBtnStartAction:NO];
    }
    else{
        [self shootVideoBtnStartAction:YES];
    }
}

- (void)shootVideoBtnStartAction:(BOOL)enableAudioTrack {
    if (![self.baseUIView canStartRecord]) {
        return;
    }
    if (self.baseUIView.shootingVideo) {
        return ;
    }
    if (self.shortVideoRecorder.isRecording) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.baseUIView startShootVideoWithComplitionHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            [strongSelf shootVideoCompletion];
        }
    }];
//    [self.arController setRenderMovieWriter:self.videoRecorder.movieWriter];
    [self.shortVideoRecorder deleteAllFiles];
    [self.shortVideoRecorder startRecording];
}

//停止视频录制
- (void)shootVideoCompletion {
    [self.shortVideoRecorder stopRecording];
}

- (void)shootVideoBtnStop {
    [self.baseUIView stopShootVideo];
}

//拍照
- (void)screenshotBtnClick {
    [self.baseUIView setRecordButtonAndSwitchViewEnable:NO];
    __weak typeof(self) weakSelf = self;
    [self.arController takePicture:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!image) {
                [weakSelf.baseUIView setRecordButtonAndSwitchViewEnable:YES];
                return;
            }
            BARShareViewControllers* vc = [[BARShareViewControllers alloc] initWithImage:image];
            __weak typeof(self) weakSelf = self;
            weakSelf.willGoToShare = YES;
            __weak typeof(weakSelf) weakweakSelf = weakSelf;
            [weakSelf presentViewController:vc animated:NO completion:^{
                [weakweakSelf.baseUIView setRecordButtonAndSwitchViewEnable:YES];
            }];
        });
    }];
}

//闪光灯开启关闭切换
- (void)lightSwitchButtonClicked {
    [self.shortVideoRecorder setTorchOn:!self.shortVideoRecorder.isTorchOn];
    [self.baseUIView setLightSwitchBtnOn:self.shortVideoRecorder.isTorchOn];
}

- (int)devicePosition {
    if (self.shortVideoRecorder.captureDevicePosition == AVCaptureDevicePositionBack) {
        return 0;
    } else {
        return 1;
    }
}

- (BOOL)demoNeedARMirrorBuffer{
    if (self.videoConfiguration.videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        if(self.devicePosition == 1) {
            return YES;
        } else{
            return NO;
        }
    }
    if (self.devicePosition == 1) {
        if (self.videoConfiguration.previewMirrorFrontFacing) {
            return NO;
        } else{
            return YES;
        }
    }
    return NO;
}

- (void)rotateCamera {
    if (self.roating) {
        return;
    }
    self.roating = YES;
    if (self.shortVideoRecorder.captureDevicePosition == AVCaptureDevicePositionBack) {
        self.shortVideoRecorder.captureDevicePosition = AVCaptureDevicePositionFront;
    } else {
        self.shortVideoRecorder.captureDevicePosition = AVCaptureDevicePositionBack;
    }
    self.roating = NO;
}

//相机前后摄像头切换
- (void)cameraSwitchBtnClick {
    [self pauseAR];
    // AR 模型以后置摄像生效，当当前为前置摄像时，需转换成后置摄像
    [self rotateCamera];
    [self.arController setDevicePosition:[self devicePosition] needArMirrorBuffer:[self demoNeedARMirrorBuffer]];
    [self resumeAR];
}

#pragma mark - DARRenderViewControllerDataSource  // hera 未遵守代理

/**
 Render DataSource
 @param srcBuffer 相机buffer源
 */
- (void)updateSampleBuffer:(CMSampleBufferRef)srcBuffer {
    if (SAMPLE_BUffER_LAYER) {
        NSDictionary *exraDic = @{@"startTime":[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]};
        [self.arController updateSampleBuffer:srcBuffer extraInfo:exraDic];
    } else {
        [self.arController updateSampleBuffer:srcBuffer];
    }
}

- (void)updateAudioSampleBuffer:(CMSampleBufferRef)audioBuffer {
    if(self.shortVideoRecorder.isRecording){

    }
}

- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer extraInfo:(id)info{
    [self.arController updateSampleBuffer:sampleBuffer extraInfo:info];
}

- (void)showAlert:(NSString *)alertinfo{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:alertinfo
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [vc addAction:cancelAction];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:NULL];
    });
}

#pragma mark - Gesture

- (void)onViewGesture:(UIGestureRecognizer *)gesture{
    [self.arController onViewGesture:gesture];
}
- (void)ar_touchesBegan:(NSSet<UITouch *> *)touches scale:(CGFloat)scale {
    [self.arController ar_touchesBegan:touches scale:scale];
    if ([self.arType integerValue] == kBARTypeFace) {
        CGPoint point = [[touches anyObject] locationInView:self.shortVideoRecorder.previewView];
        [self handleCameraFocus:point];
    }
    [self.baseUIView closeFaceView];
}
- (void)ar_touchesMoved:(NSSet<UITouch *> *)touches scale:(CGFloat)scale {
    [self.arController ar_touchesMoved:touches scale:scale];
}
- (void)ar_touchesEnded:(NSSet<UITouch *> *)touches scale:(CGFloat)scale {
    [self.arController ar_touchesEnded:touches scale:scale];
}
- (void)ar_touchesCancelled:(NSSet<UITouch *> *)touches scale:(CGFloat)scale {
    [self.arController ar_touchesCancelled:touches scale:scale];
}

#pragma mark - handle camera focus
// hera 没有走
- (void)handleCameraFocus:(CGPoint)point {
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    if ([self.renderVC devicePosition] == 1) {
//        [self.renderVC manualAdjustFocusAtPoint:CGPointMake(point.y / screenSize.height, point.x / screenSize.width)];
//    }else {
//        [self.renderVC manualAdjustFocusAtPoint:CGPointMake(point.y / screenSize.height, (screenSize.width - point.x) / screenSize.width)];
//    }
//
//    NSValue *leftPoint = [NSValue valueWithCGPoint:CGPointMake(point.x - 50, point.y - 50)];
//    NSValue *rightPoint = [NSValue valueWithCGPoint:CGPointMake(point.x + 50, point.y + 50)];
//    NSArray *points = @[leftPoint, rightPoint];
//    [self.renderVC tapAdjustFocusToDrawRectangle:points];
}

#pragma mark - Face

- (void)adjustFilterWithParam:(NSDictionary *)param {
    NSString *title = [param objectForKey:@"title"];
    CGFloat value = [[param objectForKey:@"value"] floatValue];
    if([title isEqualToString:@"whiten"]){  //美白
        [self.arController adjustFilterType:BARFaceBeautyTypeWhiten value:value];
    }else if([title isEqualToString:@"skin"]){ //磨皮
        [self.arController adjustFilterType:BARFaceBeautyTypeSkin value:value];
    }else if([title isEqualToString:@"eye"]){ //大眼
        [self.arController adjustFilterType:BARFaceBeautyTypeEye value:value];
    }else if([title isEqualToString:@"thinFace"]){ //瘦脸
        [self.arController adjustFilterType:BARFaceBeautyTypeThinFace value:value];
    }else if([title isEqualToString:@"filter"]) { //透明度
        if ([self.currentFilterID isEqualToString:@"500001"]) {
            // 默认滤镜默认值为0.4
            [self.arController adjustFilterType:BARFaceBeautyTypeNormalFilter value:0.4 * FILTER_RATIO];
        }else {
            [self.arController adjustFilterType:BARFaceBeautyTypeNormalFilter value:value * FILTER_RATIO];
            self.filterLastValue = value;
        }
    }
    if (title != nil) {
        //保存当前值
        NSMutableDictionary *faceBeautyValueDict = [[self.faceBeautyLastValueDic objectForKey:title] mutableCopy];
        [faceBeautyValueDict setObject:[NSNumber numberWithFloat:value] forKey:@"defaultValue"];
        if (faceBeautyValueDict != nil) {
            [self.faceBeautyLastValueDic setObject:faceBeautyValueDict forKey:title];
        }
    }
}

- (void)setBeautyDefaultValue:(NSDictionary *)param {
    if (param && [param isKindOfClass:[NSDictionary class]]) {
        [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *dic = @{@"title" : key, @"value": [[param objectForKey:key] objectForKey:@"defaultValue"]};
            [self adjustFilterWithParam:dic];
        }];
    }
}

- (void)autoFocusAtFace:(NSArray *)points {
    NSArray *tempPoints = [points copy];
    double minX = 2000;
    double maxX = 0;
    double minY = 2000;
    double maxY = 0;
    // 循环所有点，求最大框
    for (NSValue *value in tempPoints) {
        CGPoint point = [value CGPointValue];
        if (point.x < minX) {
            minX = point.x;
        }
        if (point.x > maxX) {
            maxX = point.x;
        }
        if (point.y < minY) {
            minY = point.y;
        }
        if (point.y > maxY) {
            maxY = point.y;
        }
    }
    
    NSValue *minXY = [NSValue valueWithCGPoint:CGPointMake(minX, minY)];
    NSValue *maxXY = [NSValue valueWithCGPoint:CGPointMake(maxX, maxY)];
    NSArray *result = [NSArray arrayWithObjects:minXY, maxXY, nil];
    
//    [self.renderVC drawFaceBoxRectangle:result];
}

#pragma mark - setter getter
- (UIView *) replacedView{
    if(!_replacedView){
        _replacedView = [[UIView alloc] initWithFrame:self.view.bounds];
        _replacedView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_replacedView];
    }
    return _replacedView;
}

#pragma mark - 分布加载
- (void)handleBatchDownload {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络不给力" message:@"是否重试？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.arController cancelDownloadBatchZip];
    }];
    [alert addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.arController retryDownloadBatchZip];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - PLShortVideoRecorderDelegate

// 摄像头鉴权的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didGetCameraAuthorizationStatus:(PLSAuthorizationStatus)status {
    if (status == PLSAuthorizationStatusAuthorized) {
        [recorder startCaptureSession];
    }
    else if (status == PLSAuthorizationStatusDenied) {
        NSLog(@"Error: user denies access to camera");
    }
}

// 麦克风鉴权的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didGetMicrophoneAuthorizationStatus:(PLSAuthorizationStatus)status {
    if (status == PLSAuthorizationStatusAuthorized) {
        [recorder startCaptureSession];
    }
    else if (status == PLSAuthorizationStatusDenied) {
        NSLog(@"Error: user denies access to microphone");
    }
}

// 摄像头对焦位置的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didFocusAtPoint:(CGPoint)point {
    NSLog(@"shortVideoRecorder: didFocusAtPoint: %@", NSStringFromCGPoint(point));
}

// 摄像头采集的视频数据的回调
/// @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致帧率下降
- (CVPixelBufferRef)shortVideoRecorder:(PLShortVideoRecorder *)recorder cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CMSampleBufferRef newSampleBuffer = NULL;
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                       pixelBuffer,
                                       true,
                                       NULL,
                                       NULL,
                                       videoInfo,
                                       &timimgInfo,
                                       &newSampleBuffer);
    CFRelease(videoInfo);
    [self.arController updateSampleBuffer:newSampleBuffer];
    CFRelease(newSampleBuffer);
    if (self.lastARSample) {
        // 实现预览效果不断设置Image
        CVImageBufferRef cvImageBufferRef = CMSampleBufferGetImageBuffer(self.lastARSample);
        // 转换类型
        CVPixelBufferRef cvPixelBufferRef = cvImageBufferRef;
        return cvPixelBufferRef;
//        return CMSampleBufferGetImageBuffer(self.lastARSample);
    } else {
        return nil;
    }
//    return pixelBuffer;
}

// 完成一段视频录制的回调
- (void)shortVideoRecorder:(PLShortVideoRecorder *)recorder didFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    if(totalDuration > 1.0 || totalDuration == 1.0){
        self.willGoToShare = YES;
        [self.baseUIView stopShootVideo];
        [self goEditViewController];
    }else{
        if([self isVisiable]){
            [self  showRecordVideoTooShort];
        }
    }
}

@end

