//
//  BARVolumeQueue.h
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/8/17.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARVolumeQueue : NSObject

- (void)pushVolume:(CGFloat)volume;
- (void)pushVolumeWithArray:(NSArray *)array;
- (CGFloat)popVolume;
- (void)cleanQueue;

@end

