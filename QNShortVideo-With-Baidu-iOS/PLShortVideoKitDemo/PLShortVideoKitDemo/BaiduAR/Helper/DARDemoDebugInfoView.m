//
//  DARDemoDebugInfoView.m
//  ARAPP-OpenStandard
//
//  Created by yijieYan on 2018/10/16.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "DARDemoDebugInfoView.h"
#import "BARPerformanceUtil.h"
#import "DARFaceAlgoAdjustView.h"

@interface DARDemoDebugInfoView()
@property (nonatomic, strong) UILabel *faceInfo;
@property (nonatomic, strong) UILabel *renderTimeLabel;
@property (nonatomic, strong) UILabel *cpuInfoLabel;
@property (nonatomic, strong) UILabel *frameInfoLabel;
@property (nonatomic, strong) UILabel *memoryInfoLabel;
@property (nonatomic, strong) UILabel *faccDetectTimeLabel;
@property (nonatomic, strong) UILabel *faceTrackTimeLabel;
@property (nonatomic, strong) UILabel *faceLoadModleTimeLabel;
@property (nonatomic, strong) DARFaceAlgoAdjustView *faceAlgoAdjustView; //调节人脸参数视图
@property (nonatomic, strong) UIButton *faceAlgoAdjustButton; //调节人脸参数按钮
@property (nonatomic, strong) UITextView *faceTriggerLabel;
@property (nonatomic, strong) UILabel *anrLabel;

@property (nonatomic, strong) CAShapeLayer *facePointsLayer;

@property (nonatomic, assign) BOOL showFacePoints;

@property (nonatomic, strong) UILabel *percentLabel;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DARDemoDebugInfoView

- (void)dealloc{
    [self stopMonitoring];
    NSLog(@"DARDemoDebugInfoView dealloc");
}

- (void)showInView:(UIView *)view{
    if(!self.superview){
        [view addSubview:self];
        {
            self.faceAlgoAdjustButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            self.faceAlgoAdjustButton.frame = CGRectMake(0, 400, 50, 50);
            [view addSubview:self.faceAlgoAdjustButton];
            [self.faceAlgoAdjustButton addTarget:self action:@selector(adjustFaceAlgo:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        {
            self.faceAlgoAdjustView = [[DARFaceAlgoAdjustView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 300)];
            [view addSubview:self.faceAlgoAdjustView];
        }
    }
    [view bringSubviewToFront:self];
    [view bringSubviewToFront:self.faceAlgoAdjustView];
    [view bringSubviewToFront:self.faceAlgoAdjustButton];
    self.hidden = NO;
    self.faceAlgoAdjustButton.hidden = NO;
    self.faceAlgoAdjustView.hidden = YES;
    [self startMonitoring];
}

- (void)hideInView:(UIView *)view{
    self.hidden = YES;
    self.faceAlgoAdjustView.hidden = YES;
    self.faceAlgoAdjustButton.hidden = YES;
    [self stopMonitoring];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self buildView];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)buildView{
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.scrollView];
    
    
    CGFloat y = 20;
    
    
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.imageView];
    }
    
    {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        if (!self.facePointsLayer) {
            self.facePointsLayer = [[CAShapeLayer alloc] init];
        }
        self.facePointsLayer.path = path.CGPath;
        self.facePointsLayer.fillColor = [UIColor clearColor].CGColor;
        [self.scrollView.layer addSublayer:self.facePointsLayer];
        
    }
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 20)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor purpleColor];
        [self.scrollView addSubview:label];
        self.faceInfo = label;
        y = CGRectGetMaxY(label.frame);
    }
    
    {
        self.cpuInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 20)];
        self.cpuInfoLabel.numberOfLines = 0;
        self.cpuInfoLabel.font = [UIFont systemFontOfSize:16];
        self.cpuInfoLabel.textColor = [UIColor redColor];
        self.cpuInfoLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.cpuInfoLabel];
        
//        self.anrLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, y, 200, 20)];
//        self.anrLabel.numberOfLines = 0;
//        self.anrLabel.backgroundColor = [UIColor greenColor];
//        self.anrLabel.font = [UIFont systemFontOfSize:16];
//        self.anrLabel.textColor = [UIColor redColor];
//        self.anrLabel.userInteractionEnabled = NO;
//        self.anrLabel.text = @"!!!卡顿！！！";
//        self.anrLabel.hidden = YES;
//        [self addSubview:self.anrLabel];
        
        y = CGRectGetMaxY(self.cpuInfoLabel.frame);
    }
    
    {
        self.memoryInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 20)];
        self.memoryInfoLabel.numberOfLines = 0;
        self.memoryInfoLabel.font = [UIFont systemFontOfSize:16];
        self.memoryInfoLabel.textColor = [UIColor redColor];
        self.memoryInfoLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.memoryInfoLabel];
        y = CGRectGetMaxY(self.memoryInfoLabel.frame);
        
    }
    
    {
        self.frameInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 20)];
        self.frameInfoLabel.numberOfLines = 0;
        self.frameInfoLabel.font = [UIFont systemFontOfSize:16];
        self.frameInfoLabel.textColor = [UIColor purpleColor];
        [self.frameInfoLabel setText:@"每帧处理时长"];
        self.frameInfoLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.frameInfoLabel];
        y = CGRectGetMaxY(self.frameInfoLabel.frame);
    }
    
    {
        self.renderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 50)];
        self.renderTimeLabel.numberOfLines = 0;
        self.renderTimeLabel.font = [UIFont systemFontOfSize:16];
        self.renderTimeLabel.textColor = [UIColor purpleColor];
        self.renderTimeLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.renderTimeLabel];
        y = CGRectGetMaxY(self.renderTimeLabel.frame);
    }
    
  

    {
        self.faccDetectTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 20)];
        self.faccDetectTimeLabel.numberOfLines = 0;
        self.faccDetectTimeLabel.font = [UIFont systemFontOfSize:16];
        self.faccDetectTimeLabel.textColor = [UIColor purpleColor];
        self.faccDetectTimeLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.faccDetectTimeLabel];
        y = CGRectGetMaxY(self.faccDetectTimeLabel.frame);
    }
    {
        self.faceTrackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 50)];
        self.faceTrackTimeLabel.numberOfLines = 0;
        self.faceTrackTimeLabel.font = [UIFont systemFontOfSize:16];
        self.faceTrackTimeLabel.textColor = [UIColor purpleColor];
        self.faceTrackTimeLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.faceTrackTimeLabel];
        y = CGRectGetMaxY(self.faceTrackTimeLabel.frame);
    }
    {
        self.percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 130)];
        self.percentLabel.numberOfLines = 0;
        self.percentLabel.font = [UIFont systemFontOfSize:16];
        self.percentLabel.textColor = [UIColor purpleColor];
        self.percentLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.percentLabel];
        y = CGRectGetMaxY(self.percentLabel.frame);
    }
    
    {
        self.faceLoadModleTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 100)];
        self.faceLoadModleTimeLabel.numberOfLines = 0;
        self.faceLoadModleTimeLabel.font = [UIFont systemFontOfSize:16];
        self.faceLoadModleTimeLabel.textColor = [UIColor purpleColor];
        self.faceLoadModleTimeLabel.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.faceLoadModleTimeLabel];
        y = CGRectGetMaxY(self.faceLoadModleTimeLabel.frame);
        
    }
    
    {
        CGFloat width = CGRectGetWidth(self.frame)/2;
        self.faceTriggerLabel = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-width, 50, width, 100)];
        self.faceTriggerLabel.backgroundColor = [UIColor clearColor];
        self.faceTriggerLabel.layer.borderColor = [UIColor purpleColor].CGColor;
        self.faceTriggerLabel.layer.borderWidth = 1;
        self.faceTriggerLabel.textAlignment = NSTextAlignmentCenter;
        self.faceTriggerLabel.font = [UIFont systemFontOfSize:16];
        self.faceTriggerLabel.textColor = [UIColor purpleColor];
        self.faceTriggerLabel.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.faceTriggerLabel];
        y = CGRectGetMaxY(self.faceTriggerLabel.frame);
    }
    
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, y+50);
    
    __weak typeof(self)weakSelf = self;
    [[BARPerformanceUtil sharedMonitor] setPerformanceBlock:^(CGFloat currentCPU, CGFloat currentMemory) {
        weakSelf.cpuInfoLabel.text = [NSString stringWithFormat:@"CPU: %.1f%%",currentCPU];
        weakSelf.memoryInfoLabel.text = [NSString stringWithFormat:@"Memory: %.0fMB",currentMemory];
    }];
}

- (void)showARNLabel{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.anrLabel.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.anrLabel.hidden = YES;
        });
    });
    
    
}

- (void)adjustFaceAlgo:(UIButton *)sender {
    self.faceAlgoAdjustView.hidden = NO;
}

- (void)startMonitoring{
    [self addObserver];
    [[BARPerformanceUtil sharedMonitor] startMonitoring];
}
- (void)stopMonitoring{
    [self removeObserver];
    [[BARPerformanceUtil sharedMonitor] stopMonitoring];
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFaceDetectTime:) name:@"DEMO_TIME_FACE_DETECT" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFaceTrackTime:) name:@"DEMO_TIME_FACE_TRACK" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRenderTime:) name:@"DEMO_TIME_CAMERA_RENDER" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadFaceModleTime:) name:@"DEMO_TIME_FACE_LOADMODLE" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowFacePointsChanged:) name:@"DARSHOWFACEPOINTS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadEveryFrameTime:) name:@"DEMO_TIME_EVERY_FRAME" object:nil];
    
}

- (void)onShowFacePointsChanged:(NSNotification *)notify{
    NSDictionary *dic = notify.object;
    
    self.showFacePoints = [dic[@"state"] boolValue];
    
}

- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onLoadFaceModleTime:(NSNotification *)notify{
    NSString *time = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faceLoadModleTimeLabel.text = time;
    });
}

- (void)onFaceDetectTime:(NSNotification *)notify{
    NSString *time = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faccDetectTimeLabel.text = time;
    });
}

- (void)onFaceTrackTime:(NSNotification *)notify{
    NSString *time = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faceTrackTimeLabel.text = time;
    });
}

- (void)onRenderTime:(NSNotification *)notify{
    NSString *time = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.renderTimeLabel.text = time;
    });
}

- (void)onLoadEveryFrameTime:(NSNotification *)notify{
    NSDictionary *dic = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frameInfoLabel.text = [dic valueForKey:@"rveryFrameTime"];
        self.percentLabel.text = [dic valueForKey:@"percentString"];
    });
}

- (void)setFaceMode:(NSInteger)mode deviceInfo:(NSString *)deviceInfo{
    NSString *modeInfo = nil;
    NSString *debugInfo = nil;
    
    if(0==mode){
        modeInfo = @"LOW";
    }
    if(1==mode){
        modeInfo = @"MIDDLE";
    }
    if(2==mode){
        modeInfo = @"HEAVY";
    }
    
#ifdef DEBUG
    debugInfo = @"DEBUG";
#else
    debugInfo = @"RELEASE";
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faceInfo.text = [NSString stringWithFormat:@"%@ - %@ - %@",debugInfo,modeInfo,deviceInfo];
    });
    
}


- (void)updateTriggerInfo:(NSString *)trigger{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faceTriggerLabel.text = [self.faceTriggerLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n :%@",trigger]];
        [self.faceTriggerLabel scrollRangeToVisible:NSMakeRange(self.faceTriggerLabel.text.length, 1)];
    });
}


- (void)drawFacePoints:(NSArray *)point
           frontCamera:(BOOL)frontCamera
            needMirror:(BOOL)needMirror
              vertical:(BOOL)vertical{
    
    [self drawAlgoLayers:point
             frontCamera:frontCamera
              needMirror:needMirror
                vertical:vertical
             strokeColor:[UIColor greenColor]
               fillColor:[UIColor greenColor]];
    
}


- (void)drawAlgoLayers:(NSArray *)boxs
           frontCamera:(BOOL)frontCamera
            needMirror:(BOOL)needMirror
              vertical:(BOOL)vertical
           strokeColor:(UIColor *)strokeColor
             fillColor:(UIColor *)fillColor{
    
    NSArray *pointArray = [boxs copy];
    
    
    [self.facePointsLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    if(!self.showFacePoints){
        return;
    }
    
    [pointArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj CGPointValue];
        
        CGPoint pointInvert = CGPointZero;
        
        CGRect rect = CGRectZero;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat ratio = screenWidth /720 ;
        CGFloat offset = (screenHeight - self.arContentFrame.size.height)/2 ;
        CGFloat pointWidth = 2;
        
        if(vertical){
            pointInvert = point;
            if(needMirror){
                rect = CGRectMake((screenWidth - pointInvert.x * ratio - pointWidth) , pointInvert.y * ratio, pointWidth, pointWidth);
            }else{
                rect = CGRectMake(pointInvert.x* ratio, pointInvert.y* ratio + offset, pointWidth, pointWidth);
            }
        }else{
            pointInvert = CGPointMake(point.y, point.x);
            if(!needMirror){
                rect = CGRectMake((screenWidth - pointInvert.x * ratio - pointWidth) , pointInvert.y * ratio, pointWidth, pointWidth);
            }else{
                rect = CGRectMake(pointInvert.x* ratio, pointInvert.y* ratio, pointWidth, pointWidth);
            }
        }
        
        
        
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
        pointLayer.path = path.CGPath;
        pointLayer.lineWidth = 1;
        pointLayer.fillColor = fillColor.CGColor;
        pointLayer.strokeColor = strokeColor.CGColor;
        //[[UIApplication  sharedApplication].keyWindow.layer addSublayer:pointLayer];
        [self.facePointsLayer addSublayer:pointLayer];
    }];
}

- (void)showFaceOriginImage:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

@end

