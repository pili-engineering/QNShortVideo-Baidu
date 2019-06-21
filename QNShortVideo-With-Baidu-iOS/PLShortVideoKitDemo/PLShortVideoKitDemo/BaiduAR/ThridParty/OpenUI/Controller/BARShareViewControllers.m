//
//  BARShareViewController.m
//  ARSDK
//
//  Created by yijieYan on 16/9/19.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BARShareViewControllers.h"

#import "BARAlert.h"
#import <AVFoundation/AVFoundation.h>
#import "BARVideoViews.h"
#import "BARFaceUtil.h"
#import "BARShareViewControllerUI.h"
#import <Photos/Photos.h>

//屏幕宽度
#define SCREEN_WIDTH ([self replaceViewWidth])
//屏幕高度
#define SCREEN_HEIGHT ([self replaceViewHeight])

typedef NS_ENUM(NSUInteger,BARShareCategory) {
    BARShareCategoryImage,
    BARShareCategoryVideo
};

@interface BARShareViewControllers () <BARVideoViewDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *httpRequestTask;

@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) UIImage *videoThumbImg;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) BARVideoViews *videoView;
@property (nonatomic, assign) BARShareCategory shareCategory;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, strong) UIView *replacedView;
@property (nonatomic, assign) BOOL saveDidFinish;

@property (nonatomic, assign) BOOL isAppInBackground;

@end

@implementation BARShareViewControllers

- (id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.shareImage = image;
        self.shareCategory = BARShareCategoryImage;
    }
    return self;
}

- (id)initWithVideoPath:(NSString *)path {
    if (self = [super init]) {
        self.videoPath = path;
        self.shareCategory = BARShareCategoryVideo;
        self.isSave = NO;
    }
    return self;
}

- (void)dealloc {
    self.videoView = nil;
}

+ (UIImage *)imageWithVideoFirstKeyFrame:(NSURL *)videoPath atTime:(CMTime)atTime {
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = NO;
    
    NSError *error = nil;
    UIImage *imageResult = nil;
    
    CGImageRef imgeRef = [generator copyCGImageAtTime:atTime actualTime:NULL error:&error];
    if (!error) {
        imageResult = [UIImage imageWithCGImage:imgeRef];
    } else {
        
    }
    CGImageRelease(imgeRef);
    
    return imageResult;
}

- (BOOL) isIPhoneX {
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(818, 1792), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2607), [[UIScreen mainScreen] currentMode].size) : NO)) return YES;
    return NO;

}

- (UIView *)replacedView {
    if(!_replacedView){
        if([self isIPhoneX]){
            CGRect parentBound = [super view].bounds;
            CGFloat topOffset;
            CGFloat bottomOffset;
            if (parentBound.size.height == 812) {//XR和XSMax的bound为414*896
                topOffset = 73;
                bottomOffset = 72;
            } else {
                topOffset = 80;
                bottomOffset = 80;
            }
            CGRect cropRect = CGRectMake(0,topOffset, parentBound.size.width, parentBound.size.height - topOffset - bottomOffset);
            _replacedView = [[UIView alloc] initWithFrame:cropRect];
            [[super view] addSubview:_replacedView];
            
        }else{
            _replacedView = self.view;
        }
    }
    return _replacedView;
}

- (CGFloat)replaceViewWidth {
    return self.replacedView.bounds.size.width;
}
- (CGFloat)replaceViewHeight {
    return self.replacedView.bounds.size.height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.shareCategory == BARShareCategoryImage) {
        [self buildView];
    } else if (self.shareCategory == BARShareCategoryVideo) {
        CMTime time = CMTimeMakeWithSeconds(0.0, 30);
        self.shareImage = [BARShareViewControllers imageWithVideoFirstKeyFrame:[NSURL fileURLWithPath:self.videoPath] atTime:time];
        if(self.shareImage){
            [self buildVideoBackViewWithImage:self.shareImage];
        }
        [self buildVideoView];
    }
    [self buildBaseUI];
    self.angle = 0;
    self.saveDidFinish = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //BARLog(@"BARShareViewControllerBARShareViewController viewWillAppear");
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    if ([BARDeviceMotionManager sharedInstance].appInBackground) {
//
//    }else{
//        [self enterPlayGround];
//    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //BARLog(@"BARShareViewControllerBARShareViewController viewDidAppear");
        [self orientationChanged:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //BARLog(@"BARShareViewControllerBARShareViewController viewWillDisappear");
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissToast];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:UIDeviceOrientationDidChangeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    self.isSave =NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)buildView {
    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.shareImage.size, self.replacedView.bounds);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cropRect];
    imageView.image = self.shareImage;

    [self.replacedView addSubview:imageView];
    self.imageView = imageView;
  
    if (UIDeviceOrientationLandscapeLeft == [self currentOrientation]) {
        CGFloat angle = M_PI/2;
        self.imageView.transform = CGAffineTransformMakeRotation(angle);
        [self resizeImageView:angle];
    } else if (UIDeviceOrientationLandscapeRight == [self currentOrientation]) {
        CGFloat angle = -(M_PI/2);
        self.imageView.transform = CGAffineTransformMakeRotation(angle);
        [self resizeImageView:angle];
    }
    else {
        CGFloat angle = 0;
        self.imageView.transform = CGAffineTransformMakeRotation(angle);
        [self resizeImageView:angle];
    }
}

// 增加背景图片解决视频预览会黑屏问题
- (void)buildVideoBackViewWithImage:(UIImage *)image {
    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.replacedView.bounds);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cropRect];
    imageView.image = image;
    [self.replacedView insertSubview:imageView atIndex:0];
    self.imageView = imageView;
    
    CGFloat angle = 0;
    [self resizeVideoBackView:angle];
}


- (void)buildVideoView {
    
    BARVideoViews *videoView = [[BARVideoViews alloc]initWithFrame:self.replacedView.bounds];
    
    videoView.videoUrlString = self.videoPath;
    
    self.videoThumbImg = [BARVideoViews imageWithVideoFirstKeyFrame:[NSURL fileURLWithPath:self.videoPath]];
    self.videoWidth = self.videoThumbImg.size.width;
    self.videoHeight = self.videoThumbImg.size.height;
    self.videoView = videoView;
    self.videoView.delegate = self;
    [self.replacedView addSubview: self.videoView];
    
    CGFloat angle = 0;
    self.videoView.transform = CGAffineTransformMakeRotation(angle);
    [self resizeVideoView:angle];

    if (self.isAppInBackground) {
        [self.videoView pause];
    } else {
        [self.videoView.player play];
    }
}

- (void)buildBaseUI {
    
        UIButton *closeBtn = [BARShareViewControllerUI createCloseBtn:self.replacedView];
        [closeBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.replacedView addSubview:closeBtn];
        _closeBtn = closeBtn;
        
        UIButton *shareBtn = [BARShareViewControllerUI createShareBtn:self.replacedView];
        [shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.replacedView addSubview:shareBtn];
        _shareBtn = shareBtn;
        
        UIButton *saveBtn = [BARShareViewControllerUI createSaveBtn:self.replacedView];
        [saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.replacedView addSubview:saveBtn];
        self.saveBtn = saveBtn;
}

- (void)shareBtnClicked {
    
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)showToast:(NSString *)str {
    if (!str || str.length==0) {
        return;
    }
    if ([str isEqualToString:BARNSLocalizedString(@"bar_tip_save_picture")]) {
        CGRect frame = CGRectMake((self.replacedView.bounds.size.width-150)/2, (self.replacedView.bounds.size.height-100)/2, 150, 100);
        [[BARAlert sharedInstance] showToastViewPortraitWithTime:3 title:nil message:str frame:frame dismissComplete:^{
            
        }];
    } else {
        [[BARAlert sharedInstance] showToastViewPortraitWithTime:3 title:nil message:str dismissComplete:^{
            
        }];
    }
    UIDeviceOrientation orientation = [self currentOrientation];
    [[BARAlert sharedInstance] setLandscapeMode:orientation];
}

- (void)dismissToast {
    [[BARAlert sharedInstance] dismiss];
}

#pragma mark - Image Operate
- (void)writeToSavedPhotosAlbum {
    
    if (!self.shareImage) {
        return;
    }
    
   UIImageWriteToSavedPhotosAlbum(self.shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    self.saveDidFinish = YES;
    if (!error) {
        [self showToast:BARNSLocalizedString(@"bar_tip_save_picture")];
        self.isSave = YES;
    } else {
        [self showToast:BARNSLocalizedString(@"bar_tip_save_failed_and_open_album")];
        self.isSave = NO;
    }
}

- (void)saveBtnClicked {
    
    __weak typeof(self) weakSelf = self;
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];

    if (authorStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [weakSelf saveBtnClicked];
                return ;
            }
        }];
        return;
        
    } else if (authorStatus == PHAuthorizationStatusRestricted || authorStatus == PHAuthorizationStatusDenied) {
        [self hintPhotoPrivacyAlertView:nil];
        return;
    }
    
    BOOL isDiskFree = [self checkDiskSpace];
    if (!isDiskFree) {
        [self showDiskFullAlertView];
        return;
    }
    
    if (!self.saveDidFinish) {
        return;
    }
    
    if (!self.isSave) {
        self.saveDidFinish = NO;
        if (self.shareCategory == BARShareCategoryImage) {
            [self writeToSavedPhotosAlbum];
        } else if (self.shareCategory == BARShareCategoryVideo) {
            UISaveVideoAtPathToSavedPhotosAlbum([NSURL URLWithString:self.videoPath].path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    } else {
        self.saveDidFinish = YES;
        [self showToast:BARNSLocalizedString(@"bar_tip_save_picture")];
    }
}

- (void)hintPhotoPrivacyAlertView:(NSString *)errorMsg {
    
    NSString *title = BARNSLocalizedString(@"bar_tip_can_not_save");
    NSString *msg = BARNSLocalizedString(@"bar_tip_set_photo_authority");
    
    [[BARAlert sharedInstance] showAlertViewWithTitle:title message:msg otherButtonTitles:nil cancelButtonTitle:BARNSLocalizedString(@"bar_tip_good")];
    [[BARAlert sharedInstance] setLandscapeMode:[self currentOrientation]];

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    self.saveDidFinish = YES;
    if (!error) {
        [self showToast:BARNSLocalizedString(@"bar_tip_save_picture")];
        self.isSave = YES;
    } else {
        [self showToast:BARNSLocalizedString(@"bar_tip_save_failed_and_open_album")];
        self.isSave = NO;
    }
}

- (BOOL)checkDiskSpace {
    
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float freeSize = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue]/(1024.f*1024.f); // 此函数获取的可用容量与手机上显示的大约有200M的差距
    float totalSize = [[fattributes objectForKey:NSFileSystemSize] floatValue]/(1024.f*1024.f);
    float limitSize = 216.0f;       // 在 7p 32G 上 大约在215M的时候，会存储失败 上边函数获取的大小
    
    if (freeSize<limitSize) {
        return NO;
    }
    return YES;
}

- (void)showDiskFullAlertView {
    /*
    [[BARAlert sharedInstance] showAlertViewWithTitle:BARNSLocalizedString(@"bar_tip_storage_space_full")
                                              message:BARNSLocalizedString(@"bar_tip_manage_storage_space")
                                    otherButtonTitles:BARNSLocalizedString(@"bar_tip_go_set")
                                    cancelButtonTitle:BARNSLocalizedString(@"bar_tip_cancel")];
    
    [[BARAlert sharedInstance] setButtonOtherBlock:^{
        NSString *urlStr = @"App-Prefs:root=General";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
            if ([BARUIDevice isIOS10]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            }
        }
//         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [[BARAlert sharedInstance] setButtonCancelBlock:^{
        
    }];
     */
}

- (UIDeviceOrientation)currentOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation direction = UIDeviceOrientationPortrait;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:{
            direction = UIDeviceOrientationPortrait;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            direction = UIDeviceOrientationLandscapeLeft;
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            direction = UIDeviceOrientationLandscapeRight;
            break;
        }
        default:
            break;
    }

    return direction;
}

- (void)setLandscapeMode:(UIDeviceOrientation)direction {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIDeviceOrientationLandscapeLeft == direction) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = M_PI/2;
                [weakSelf rotationUI:angle];
            } completion:^(BOOL finished) {
            }];
        } else if (UIDeviceOrientationLandscapeRight == direction) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = -(M_PI/2);
                [weakSelf rotationUI:angle];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                [weakSelf rotationUI:0];
            } completion:^(BOOL finished) {
            }];
        }
    });
}

- (void)rotationUI:(float)angle {
    
    self.angle = angle;
    self.closeBtn.transform = CGAffineTransformMakeRotation(angle);
    self.shareBtn.transform = CGAffineTransformMakeRotation(angle);
    self.saveBtn.transform = CGAffineTransformMakeRotation(angle);
    
    if (self.shareCategory == BARShareCategoryVideo) {
        self.videoView.transform = CGAffineTransformMakeRotation(angle);
        [self resizeVideoView:angle];
    } else if(self.shareCategory == BARShareCategoryImage) {
        self.imageView.transform = CGAffineTransformMakeRotation(angle);
        [self resizeImageView:angle];
    }
    [[BARAlert sharedInstance] setLandscapeMode:[self currentOrientation]];
}

- (void)resizeImageView:(float)angle {
    CGSize imgSize = self.shareImage.size;
    
    bool portait = imgSize.width > imgSize.height ? NO : YES;
    if (portait) {
        if (angle != 0) {
            self.imageView.clipsToBounds = YES;
            [self.imageView setBounds:CGRectMake(0, 0, [self calculateWidthWithHeight:SCREEN_WIDTH],SCREEN_WIDTH)];
            [self.imageView layoutSubviews];
            [self.imageView layoutIfNeeded];
        } else {
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT)];
        }
    } else {
        if (angle != 0) {
            self.imageView.clipsToBounds = YES;
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_HEIGHT , SCREEN_WIDTH)];
            [self.imageView layoutSubviews];
            [self.imageView layoutIfNeeded];
        } else {
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [self calculateWidthWithHeight:SCREEN_WIDTH])];
        }
    }
}

- (void)resizeVideoBackView:(float)angle {
    CGSize imgSize = self.shareImage.size;
    
    bool portait = imgSize.width > imgSize.height ? NO : YES;
    
    CGSize videoSize = self.videoView.playerItem.presentationSize;
    if(videoSize.height <= 1 && videoSize.width <=2) {
        videoSize = CGSizeMake(self.videoWidth, self.videoHeight);
    }
    portait = videoSize.width > videoSize.height ? NO : YES;
    
    if (portait) {
        if (angle != 0) {
            self.imageView.clipsToBounds = YES;
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
        } else {
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT)];
        }
    } else {
        if (angle != 0) {
            self.imageView.clipsToBounds = YES;
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_HEIGHT , SCREEN_WIDTH)];
        } else {
            [self.imageView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [self calculateWidthWithHeight:SCREEN_WIDTH])];
        }
    }
    [self.imageView layoutSubviews];
    [self.imageView layoutIfNeeded];
}

- (void)resizeVideoView:(float)angle {
    CGSize videoSize = self.videoView.playerItem.presentationSize;
    if(videoSize.height <= 1 && videoSize.width <=2) {
        videoSize = CGSizeMake(self.videoWidth, self.videoHeight);
    }
    bool portait = videoSize.width > videoSize.height ? NO : YES;
    if (portait) {
        if (angle != 0) {
            self.videoView.clipsToBounds = YES;
            [self.videoView setBounds:CGRectMake(0, 0, [self calculateWidthWithHeight:SCREEN_WIDTH],SCREEN_WIDTH)];
            [self.videoView layoutSubviews];
            [self.videoView layoutIfNeeded];
        } else {
            [self.videoView setBounds:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT)];
        }
    } else {
        if (angle != 0) {
            self.videoView.clipsToBounds = YES;
            [self.videoView setBounds:CGRectMake(0, 0, SCREEN_HEIGHT , SCREEN_WIDTH)];
            [self.videoView layoutSubviews];
            [self.videoView layoutIfNeeded];
        } else {
            [self.videoView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, [self calculateWidthWithHeight:SCREEN_WIDTH])];
        }
    }
}

- (CGFloat)calculateWidthWithHeight:(CGFloat)height {
    CGFloat w = height * SCREEN_WIDTH/SCREEN_HEIGHT;
    return w;
}

-(void)orientationChanged:(NSNotification*)notification {
//    __block typeof (self) weakSelf = self;
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    UIDeviceOrientation direction = UIDeviceOrientationPortrait;
//    switch (orientation) {
//        case UIInterfaceOrientationPortrait:{
//            direction = UIDeviceOrientationPortrait;
//            break;
//        }
//        case UIInterfaceOrientationLandscapeLeft:{
//            direction = UIDeviceOrientationLandscapeLeft;
//            break;
//        }
//        case UIInterfaceOrientationLandscapeRight:{
//            direction = UIDeviceOrientationLandscapeRight;
//            break;
//        }
//        default:
//            break;
//    }
//
//    [weakSelf setLandscapeMode:direction];
}

- (void)actuallyOrientationDidChange:(NSNotification*)notification {
    
}

#pragma  app前后台切换

//程序进入后台（如果播放，则暂停，否则不管）
- (void)appDidEnterBackground {
    self.isAppInBackground = YES;
    [self.videoView pause];
    
    // 为了解决切换后台在返回时黑屏问题，用当前的截图作为背景图，在回到前台后remove
    if (self.videoPath) {
        UIImage *image= [BARShareViewControllers imageWithVideoFirstKeyFrame:[NSURL fileURLWithPath:self.videoPath] atTime:self.videoView.player.currentTime];
        if (image) {
            [self buildVideoBackViewWithImage:image];
        }
    }
}

//程序进入前台（退出前播放，进来后继续播放，否则不管）
- (void)appDidEnterPlayGround {
    self.isAppInBackground = NO;
    [self enterPlayGround];
    
    if (self.videoPath && self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
}

- (void)enterPlayGround {
    if ([self.videoView.videoUrlString length] <= 0) {
        self.videoView.videoUrlString = self.videoPath;
    } else {
        [self.videoView resume];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didStatusReady:(BARVideoViews *)videoView {
    if (self.imageView) {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
        }];
    }
}

@end
