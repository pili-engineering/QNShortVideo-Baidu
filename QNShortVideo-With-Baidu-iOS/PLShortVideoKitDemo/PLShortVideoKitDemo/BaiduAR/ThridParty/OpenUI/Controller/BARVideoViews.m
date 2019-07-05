//
//  BARVideoView.m
//  ARSDK
//
//  Created by tony_Q on 2017/3/13.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARVideoViews.h"

@interface BARVideoViews ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL isBehide;

@property (nonatomic, readonly, copy) NSString *videoUrlStringWhenStop;
@property (nonatomic, readonly, assign) BOOL hasScrolled;
@property (nonatomic, readonly, assign) BOOL isScrolling;

@end

@implementation BARVideoViews

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void) customInit {
    self.clipsToBounds = NO;
    [self hideLoading];
    [self hideWifi2Wwan];
    [self hideUnreach];
}

- (void) dealloc {
    [self removeObserver];
    if(!self.isBehide){
        self.isBehide = NO;
    }
}

- (void) removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    [self removePlayer];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.playerLayer.frame = self.bounds;
}

- (void) setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.playerLayer.frame = self.bounds;
}

- (void) setVideoUrlString:(NSString *)videoUrlString {
    NSString *oldUrl = _videoUrlString;
    _videoUrlString = videoUrlString;
    
    if ([videoUrlString length]) {
        if (![oldUrl isEqualToString:videoUrlString]) {
            [self prepareToPlay];
        }else{
            [self resume];
        }
    }else {
        [self removeObserver];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void) removePlayer {
    if(self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    if (self.player) {
        self.player = nil;
    }
    if (self.playerItem) {
        self.playerItem = nil;
    }
}

- (void) prepareToPlay {
    
    [self removeObserver];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL local = [fileManager fileExistsAtPath:self.videoUrlString isDirectory:&isDir];

    if (local) {
        self.playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL fileURLWithPath:self.videoUrlString]]];
    }else{
        self.playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:self.videoUrlString]]];
    }
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    //self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayerDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player.currentItem];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
    });
}

//- (void) playFromZero {
//    //如果没有加载的时候进行seek,会崩溃，所以
//    if ([self.videoUrlString length]) {
//        [self.player seekToTime:kCMTimeZero];
//        [self play];
//    }
//}

- (void) pause {
    if ([self.videoUrlString length]){
        [self.player pause];
        self.isPlaying=NO;
    }
}

- (void) resume {
    if ([self.videoUrlString length]){
        [self play];
    }
}

- (void) videoPlayerDidEnd:(NSNotification *) notification {
    if ([notification.object isKindOfClass:[AVPlayerItem class]] ) {
        if (notification.object == self.playerItem) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player seekToTime:kCMTimeZero];
                [self play];
            });
        }
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
                //准备好了，准备播放
                [self didStatusReady];
            }else if( self.playerItem.status == AVPlayerItemStatusFailed) {
                //出错了
                [self startLoadingAnimation];
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            //计算缓冲时间
//            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//            CMTime duration = self.playerItem.duration;
//            CGFloat totalDuration = CMTimeGetSeconds(duration);
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            //缓存空了
            if (self.playerItem.playbackBufferEmpty) {
                [self startLoadingAnimation];
                [self play];
            }
        }else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            //又有缓存了
            if (self.playerItem.playbackLikelyToKeepUp) {
                [self stopLoadingAnimation];
            }
        }
    }
}

//- (NSTimeInterval) availableDuration {
//    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
//    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
//    float startSeconds = CMTimeGetSeconds(timeRange.start);
//    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
//    return result;
//}

- (void)didStatusReady {
    if([self.delegate respondsToSelector:@selector(didStatusReady:)]){
        [self.delegate didStatusReady:self];
    }
}
- (void) startLoadingAnimation {
    [self showLoading];
}

- (void) stopLoadingAnimation {
    
}

- (void) showLoading {
    
}

- (void) hideLoading {
    
}

//- (void) showWifi2Wwan {
//   
//}

- (void) hideWifi2Wwan {
    
}
- (void) hideUnreach {
   
}

- (void) play {
    if ([self.videoUrlString length]) {
        if ([self shouldPlay]) {
            [self.player play];
            self.isPlaying = YES;
        }
    }else{
        
    }
}

- (BOOL) superHasHidden {
    UIView *sup = self.superview;
    while (sup) {
        if (sup.hidden) {
            return YES;
        }
        sup = [sup superview];
    }
    return NO;
}

- (BOOL) shouldPlay {
    if (![self.videoUrlString length]){
        return NO;
    }
    if (self.isBehide) {
        return NO;
    }
    if ([self superHasHidden]) {
        return NO;
    }
//    if ([BARDeviceMotionManager sharedInstance].appInBackground) {
//        return NO;
//    }
    if (self.hasScrolled) {
        if ( self.isScrolling) {
            return NO;
        }
        if (![self.videoUrlString isEqualToString:self.videoUrlStringWhenStop]) {
            return NO;
        }
    }
    return YES;
}

//- (void) scrollLeftRightStart:(NSNotification *)notification{
//    _hasScrolled = YES;
//    _isScrolling = YES;
//    _videoUrlStringWhenStop = nil;
//    [self pause];
//}
//
//- (void) scrollLeftRightStop:(NSNotification *)notification{
//    _isScrolling =  NO;
//    if (notification.userInfo) {
//        NSString * videoUrlString = [notification.userInfo objectForKey:@"videoUrl"];
//        _videoUrlStringWhenStop = videoUrlString;
//    }
//    [self play];
//}
//- (void) videoBlackCoverShow{
//    self.isBehide = YES;
//    [self pause];
//}
//
//- (void) videoBlackCoverHide {
//    self.isBehide = NO;
//    [self play];
//}
- (void) seekToTime:(CGFloat) seekTime {
    CMTime seekToTime = CMTimeMake(seekTime * 60, 60);
    [self.player seekToTime:seekToTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


+ (UIImage *)imageWithVideoFirstKeyFrame:(NSURL *)videoPath atTime:(CMTime)atTime
{
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    
    NSError *error = nil;
    UIImage *imageResult = nil;
    
    CGImageRef imgeRef = [generator copyCGImageAtTime:atTime actualTime:NULL error:&error];
    if (!error)
    {
        imageResult = [UIImage imageWithCGImage:imgeRef];
    }
    else{
        //BARLog(@"Get Video Thumbnail Failed:%@",[error description]);
    }
    
    CGImageRelease(imgeRef);
    
    return imageResult;
    
}


+ (UIImage *)imageWithVideoFirstKeyFrame:(NSURL *)videoPath
{
//    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    
//    Float64 durationSeconds = CMTimeGetSeconds(urlAsset.duration);
    CMTime time = CMTimeMakeWithSeconds(0.2, 30);
    
    return [self imageWithVideoFirstKeyFrame:videoPath atTime:time];
    
}

@end
