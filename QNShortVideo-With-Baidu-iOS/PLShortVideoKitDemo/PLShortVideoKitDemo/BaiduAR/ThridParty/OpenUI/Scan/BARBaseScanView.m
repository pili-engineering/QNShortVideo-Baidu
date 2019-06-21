//
//  BARTrackingScanView.m
//  ARSDK
//
//  Created by LiuQi on 16/7/7.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BARBaseScanView.h"
#import "BARFaceUtil.h"
#import "UIImage+Load.h"


@interface BARBaseScanView ()

@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *scanImageView;
@property (nonatomic, strong) CABasicAnimation* rotationAnimation;
@end

@implementation BARBaseScanView

- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {

    if (!self.centerImageView) {
        self.centerImageView = [[UIImageView alloc] init];
        self.centerImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_center"]];
        self.centerImageView.center = self.center;
        [self addSubview:self.centerImageView];
    }
    
    if (!self.scanImageView) {
        self.scanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 910, 910)];
        self.scanImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scanImageView setImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_scan"]];
        self.scanImageView.center = self.center;
        [self addSubview:self.scanImageView];
    }

    self.indicatorClockwise = YES;
    [self scan];
}

-(void)scan
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: (self.indicatorClockwise?1:-1) * M_PI * 2.0 ];
    rotationAnimation.duration = 360.f/ 60.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    rotationAnimation.removedOnCompletion = NO;
//    rotationAnimation.delegate = self;
    self.rotationAnimation = rotationAnimation;
    [self.scanImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stop
{
    [self.scanImageView.layer removeAnimationForKey:@"rotationAnimation"];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    int i = 0;
}
-(void)hide{
    self.hidden = YES;
}

-(void)show{
    self.hidden = NO;
}
/*
-(void)hideWithFadeAnimation:(NSTimeInterval)duration finishCallBack:(void (^ __nullable)(void))completion{
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finish){
        completion();
    }];
}*/
@end
