//
//  BARBaseVoiceView.m
//  ARSDK
//
//  Created by Zhao,Xiangkai on 2018/2/9.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARBaseVoiceView.h"
#import "BARVoiceWaveView.h"
#import "BARVoiceLoadingCircleView.h"

@interface BARBaseVoiceView()
{
    CGFloat _waveBottomSpace;
    CGFloat _wavePosY;
    CGFloat _waveHeight;
    
    CGRect _tipsFrame;
    CGRect _waveFrame;
    CGRect _waveCurrentFrame;
    CGRect _loadingCurrentFrame;
    CGRect _loadingFrame;
    
    CGPoint _loadingCenter;
    CGSize _loadingSize;
    
    NSInteger lastVolume;
    
}

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) BARVoiceLoadingCircleView *loadingView;
@property (nonatomic, strong) BARVoiceWaveView *voiceWaveView;
@property (nonatomic, weak) UIView *containersView;

@end

@implementation BARBaseVoiceView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"voiceview dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setContainer:(UIView *)container {
    _containersView = container;
    _wavePosY = self.containersView.bounds.size.height - _waveBottomSpace - _waveHeight;
    _tipsFrame = CGRectMake(18, self.containersView.bounds.size.height - 195, self.containersView.bounds.size.width - 36, 20);
    _waveFrame = CGRectMake(0, _wavePosY, self.containersView.bounds.size.width, _waveHeight);
    _waveCurrentFrame = _waveFrame;
}

- (void)setup {
    _waveBottomSpace = 111.7f;
    _waveHeight = 50.3f;
    _loadingSize = CGSizeMake(24, 24);
}

- (void)configureUI {
    [self.containersView addSubview:self.tipsLabel];
}

#pragma mark - public
- (void)setLandscapeMode:(UIDeviceOrientation)direction {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (UIDeviceOrientationLandscapeLeft == direction) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = M_PI/2;
                CGAffineTransform rotate  = CGAffineTransformMakeRotation(angle);//先旋转
                self.voiceWaveView.transform = rotate;
                
                CGRect frame = CGRectZero;
                frame = CGRectMake(15 , 0, _waveHeight,self.containersView.bounds.size.height);
                self.voiceWaveView.frame = frame;
                _waveCurrentFrame = frame;
                
                frame = self.loadingView.frame;
                frame.size = _loadingSize;
                frame.origin.x = frame.size.width/2 + _waveHeight/2 - 15;//上下
                frame.origin.y = self.containersView.bounds.size.height/2 - frame.size.width/2;
                self.loadingView.frame = frame;
                _loadingCurrentFrame = frame;
                _loadingCenter = self.loadingView.center;
                
                self.tipsLabel.transform = rotate;
                frame = self.tipsLabel.frame;
                frame.size.height = self.containersView.bounds.size.height - 36;
                frame.origin.y = 18;
                frame.origin.x =  94 ;
                self.tipsLabel.frame = frame;
                
            } completion:^(BOOL finished) {
            }];
        } else if (UIDeviceOrientationLandscapeRight == direction) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat angle = -(M_PI/2);
                CGAffineTransform rotate  = CGAffineTransformMakeRotation(angle);//先旋转
                self.voiceWaveView.transform = rotate;
                
                CGRect frame = CGRectZero;
                frame = CGRectMake(self.containersView.bounds.size.width - 15 - _waveHeight, 0, _waveHeight,self.containersView.bounds.size.height);
                self.voiceWaveView.frame = frame;
                _waveCurrentFrame = frame;
                
                frame = self.loadingView.frame;
                frame.size = _loadingSize;
                //                frame.origin.x = self.containersView.bounds.size.width - 15 - frame.size.width - _waveHeight/2;
                frame.origin.x = self.containersView.bounds.size.width - 15 - frame.size.width/2 - _waveHeight/2 ;//上下
                frame.origin.y = self.containersView.bounds.size.height/2 - frame.size.width/2;
                self.loadingView.frame = frame;
                _loadingCenter = self.loadingView.center;
                _loadingCurrentFrame = frame;
                
                self.tipsLabel.transform = rotate;
                frame = self.tipsLabel.frame;
                frame.size.height = self.containersView.bounds.size.height - 36;
                frame.origin.y = 18;
                frame.origin.x = self.containersView.bounds.size.width - 94 - 20;
                self.tipsLabel.frame = frame;
                
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.voiceWaveView.transform = CGAffineTransformIdentity;
                self.voiceWaveView.frame = _waveFrame;
                _waveCurrentFrame = _waveFrame;
                _loadingCurrentFrame = _loadingFrame;
                
                self.tipsLabel.transform = CGAffineTransformIdentity;
                self.tipsLabel.frame = _tipsFrame;
                
                self.loadingView.transform = CGAffineTransformIdentity;
                self.loadingView.center = CGPointMake(self.containersView.bounds.size.width / 2.0, self.containersView.bounds.size.height - 124 - 12);
                _loadingCenter = self.loadingView.center;
                
                _loadingCurrentFrame = self.loadingView.frame;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    });
}

- (void)startVoice {
    [self clearKeyWindowUI];
    [self configureUI];
    [self showWaving];
}

- (void)stopVoice {
    [self clearKeyWindowUI];
}

- (void)setTips:(NSString *)tips {
    self.tipsLabel.text = tips;
}

- (void)changeVolume:(NSInteger)volume shootingVideo:(BOOL)shootingVideo {
    if (shootingVideo) {//视频录制的时候，
        CGFloat deleta = 0;
        deleta = volume - lastVolume;
        lastVolume = volume;
        volume = volume*0.15 + deleta;
        [self.voiceWaveView changeVolume: 0.8*volume / 100.0f];
    }else {
        [self.voiceWaveView changeVolume: 0.8*volume / 100.0f];
    }
}

#pragma mark - action
- (void)clearKeyWindowUI {
    self.tipsLabel.text = @"";
    [self.voiceWaveView removeFromParent];
    [self.loadingView stopLoading];
    [self.loadingView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
}

- (void)showLoadingWave {
    __weak typeof(self)weakSelf = self;
    [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{
        [weakSelf.loadingView startLoadingInParentView:weakSelf.containersView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.loadingView.center = _loadingCenter;
        });
    }];
}

- (void)stopLoadingWave {
    [self.loadingView stopLoading];
    [self.loadingView removeFromSuperview];
}

- (void)showWaving {
    self.tipsLabel.text = @"正在聆听中...";
    [self stopLoadingWave];
    [self.voiceWaveView showInParentView:self.containersView frame:_waveCurrentFrame];
    [self.voiceWaveView startVoiceWave];
}

- (void)stopWaving {
    [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{
        
    }];
}

#pragma mark - setter getter
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:_tipsFrame];
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.numberOfLines = 1;
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _tipsLabel.layer.shadowOpacity = 0.4;
        _tipsLabel.layer.shadowRadius = 3;
        _tipsLabel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _tipsLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        _tipsLabel.userInteractionEnabled = NO;
    }
    return _tipsLabel;
}

- (BARVoiceLoadingCircleView *)loadingView
{
    if (!_loadingView) {
        CGSize screenSize = self.containersView.bounds.size;
        CGPoint loadViewCenter = CGPointMake(screenSize.width / 2.0, self.containersView.bounds.size.height - 124 - 12);
        _loadingView = [[BARVoiceLoadingCircleView alloc] initWithCircleRadius:12 center:loadViewCenter];
    }
    
    return _loadingView;
}

- (BARVoiceWaveView *)voiceWaveView {
    if (!_voiceWaveView) {
        _voiceWaveView = [[BARVoiceWaveView alloc] init];
        _voiceWaveView.userInteractionEnabled = NO;
    }
    return _voiceWaveView;
}

- (UIView *)containersView {
    if (_containersView) {
        return _containersView;
    } else {
        return [[UIApplication sharedApplication] keyWindow];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
