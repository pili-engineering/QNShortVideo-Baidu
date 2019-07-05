//
//  BARVideoView.h
//  ARSDK
//
//  Created by tony_Q on 2017/3/13.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class BARVideoViews;
@protocol BARVideoViewDelegate <NSObject>

@optional
- (void) didStatusReady:( BARVideoViews *)videoView;
@end

@interface BARVideoViews : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, copy)   NSString *videoUrlString;
@property (nonatomic, copy)   NSString *videoPath;
@property (nonatomic ,assign) BOOL isPlaying;
@property (nonatomic, weak) id<BARVideoViewDelegate> delegate;

//- (void) videoBlackCoverShow;
- (void) videoBlackCoverHide;
- (void) pause;
- (void) resume;
//- (void) playFromZero;
- (void) seekToTime:(CGFloat) seekTime;


/**
 *  获取视频第五帧
 */
+ (UIImage *)imageWithVideoFirstKeyFrame:(NSURL *)videoPath;

@end
