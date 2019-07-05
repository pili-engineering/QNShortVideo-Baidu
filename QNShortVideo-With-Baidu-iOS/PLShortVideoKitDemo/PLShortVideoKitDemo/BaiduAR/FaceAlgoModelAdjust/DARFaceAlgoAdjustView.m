//
//  DARFaceAlgoAdjustView.m
//  ARAPP-OpenStandard
//
//  Created by V_,Lidongxue on 2018/12/7.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "DARFaceAlgoAdjustView.h"
#define Alpha_Max 1
#define Alpha_Min 0.01
#define Threshod_Max 0.05
#define Threshod_Min 0.005


@interface DARFaceAlgoAdjustView()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UISwitch *faceSwitch;
@property (nonatomic, strong) UISwitch *animateSwitch;

@end

@implementation DARFaceAlgoAdjustView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBaseView];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:@"BARNeedAnimate" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:@"BAR_SET_FACE_ALGO_STATE" object:nil];
    }
    return self;
}


- (void)notification:(NSNotification *)notify{
    
    NSString *notifyName = notify.name;
    
    if([notifyName isEqualToString:@"BAR_SET_FACE_ALGO_STATE"]){
        
        id data = notify.object;
        if([data isKindOfClass:[NSNumber class]]){
            BOOL state = [data boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"9999999999 %d",state);
                self.faceSwitch.on = state;
            });
        }
        return;
    }
    
    NSDictionary *sic = notify.object;
    
    BOOL outside = [sic[@"outside"] boolValue];
    if(!outside){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animateSwitch.on = [sic[@"BARNeedAnimate"] boolValue];
        });
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupBaseView {
    
    CGFloat y = 0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.bounces = YES;
    [self addSubview:self.scrollView];
    
    self.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    
    UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.frame = CGRectMake(self.frame.size.width- 100, self.frame.size.height - 44, 100, 44);
    [hideButton setTitle:@"隐藏" forState:UIControlStateNormal];
    [hideButton setBackgroundColor:[UIColor greenColor]];
    [hideButton addTarget:self action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideButton];
    
    //添加alpha滑竿
    UISlider *alphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    alphaSlider.minimumTrackTintColor = [UIColor greenColor];
    alphaSlider.maximumTrackTintColor = [UIColor blueColor];
    alphaSlider.minimumValue = Alpha_Min;
    alphaSlider.maximumValue = Alpha_Max;
    [alphaSlider setThumbImage:[UIImage imageNamed:@"BaiduAR_Face_Rectangle"] forState:UIControlStateNormal];
    alphaSlider.value = Alpha_Min;
    [alphaSlider addTarget:self action:@selector(handleAlphaSlider:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:alphaSlider];
    
    //添加alpha文字
    self.alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    self.alphaLabel.text = [NSString stringWithFormat:@"alpha:%f", alphaSlider.value];
    self.alphaLabel.font = [UIFont boldSystemFontOfSize:30];
    self.alphaLabel.textColor = [UIColor greenColor];
    [self.scrollView addSubview:self.alphaLabel];

    
    //添加threshod滑竿
    UISlider *threshodSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    threshodSlider.minimumTrackTintColor = [UIColor greenColor];
    threshodSlider.maximumTrackTintColor = [UIColor blueColor];
    threshodSlider.minimumValue = Threshod_Min;
    threshodSlider.maximumValue = Threshod_Max;
    [threshodSlider setThumbImage:[UIImage imageNamed:@"BaiduAR_Face_Rectangle"] forState:UIControlStateNormal];
    threshodSlider.value = Threshod_Min;
    [threshodSlider addTarget:self action:@selector(handleThreshodSlider:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:threshodSlider];
    
    //添加threshod文字
    self.threshodLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    self.threshodLabel.text = [NSString stringWithFormat:@"threshod:%f", threshodSlider.value];
    self.threshodLabel.font = [UIFont boldSystemFontOfSize:30];

    self.threshodLabel.textColor = [UIColor greenColor];
    [self.scrollView addSubview:self.threshodLabel];
    y = CGRectGetMaxY(self.threshodLabel.frame)+10;
    y = [self addCommonUISwitchWithState:YES labelName:@"needHeadPose" tag:1000 yPosition:y outsideSwitch:nil];
    y = [self addCommonUISwitchWithState:YES labelName:@"needSkeleton" tag:1000+1 yPosition:y outsideSwitch:nil];
    y = [self addCommonUISwitchWithState:YES labelName:@"needTriggers" tag:1000+2 yPosition:y outsideSwitch:nil];
    
    y = [self addCommonUISwitchWithState:NO labelName:@"自动切换case" tag:1000+3 yPosition:y outsideSwitch:nil];
    
    self.faceSwitch  = [[UISwitch alloc] init];
    y = [self addCommonUISwitchWithState:NO labelName:@"人脸算法:" tag:2000 yPosition:y outsideSwitch:self.faceSwitch];
    y = [self addCommonUISwitchWithState:NO labelName:@"显示特征点:" tag:2001 yPosition:y outsideSwitch:nil];

//    self.animateSwitch = [[UISwitch   alloc] init];
//    y = [self addCommonUISwitchWithState:NO labelName:@"计算animate:" tag:2002 yPosition:y outsideSwitch:self.animateSwitch];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), y+100);
    
}


- (CGFloat )addCommonUISwitchWithState:(BOOL)on
                             labelName:(NSString *)labelName
                                   tag:(NSInteger)tag
                             yPosition:(CGFloat)yPosition
                         outsideSwitch:(UISwitch *)outsideSwitch{
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,yPosition, 250, 20)];
    tempLabel.font = [UIFont boldSystemFontOfSize:30];
    tempLabel.text = labelName;
    tempLabel.textColor = [UIColor greenColor];
    [self.scrollView addSubview:tempLabel];
    
    UISwitch *tempSwitch = nil;
    
    if(outsideSwitch){
        tempSwitch = outsideSwitch;
    }else{
        tempSwitch = [[UISwitch alloc] init];
    }
    [tempSwitch setFrame:CGRectMake(290,yPosition, 51, 31)];
    tempSwitch.center = CGPointMake(315, tempLabel.center.y);
    tempSwitch.on = on;
    tempSwitch.tag = tag;
    
    [tempSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [self.scrollView addSubview:tempSwitch];
    return CGRectGetMaxY(tempSwitch.frame)+10;
}

- (void)hideView:(UIButton *)sender {
    [self setHidden:YES];
}

- (void)valueChanged:(UISwitch *)sender {
    
    //[NSThread sleepForTimeInterval:3];
    switch (sender.tag) {
        case 1000: {
            NSDictionary *dic = @{@"needHeadPose": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedHeadPose" object:nil userInfo:dic];
            break;
            
        }
        case 1001: {
            NSDictionary *dic = @{@"needSkeleton": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedSkeleton" object:nil userInfo:dic];
            break;
        }
        case 1002: {
            NSDictionary *dic = @{@"needTriggers": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedTriggers" object:nil userInfo:dic];
            break;
        }
        case 1003: {
            NSDictionary *dic = @{@"aotoSwitchCase": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"aotoSwitchCase" object:dic userInfo:nil];
            break;
        }
        
        case 2000:{
            NSDictionary *dic = @{@"state": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BARSETFACEALGOSTATE" object:dic userInfo:nil];
            break;
        }
        case 2001:{
            NSDictionary *dic = @{@"state": @(sender.on)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DARSHOWFACEPOINTS" object:dic userInfo:nil];
            break;
        }
        case 2002:{
            NSDictionary *dic = @{@"BARNeedAnimate": @(sender.on),@"outside":@(YES)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BARNeedAnimate" object:dic userInfo:nil];
            break;
        }
        default:
            break;
    }
}

- (void)handleAlphaSlider:(UISlider *)sender {
    self.alphaLabel.text = [NSString stringWithFormat:@"alpha:%f", sender.value];
    NSDictionary *dic = @{@"trackingSmoothAlpha": @(sender.value)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TrackingSmoothAlpha" object:nil userInfo:dic];
    NSLog(@"%f", sender.value);
}

- (void)handleThreshodSlider:(UISlider *)sender {
    self.threshodLabel.text = [NSString stringWithFormat:@"threshod:%f", sender.value];
    NSDictionary *dic = @{@"trackingSmoothThreshold": @(sender.value)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TrackingSmoothThreshold" object:nil userInfo:dic];
    NSLog(@"%f", sender.value);
}

@end
