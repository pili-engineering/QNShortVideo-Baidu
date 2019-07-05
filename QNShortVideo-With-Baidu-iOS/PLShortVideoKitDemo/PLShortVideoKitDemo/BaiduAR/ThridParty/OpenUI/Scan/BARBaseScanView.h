//
//  BARTrackingScanView.h
//  ARSDK
//
//  Created by LiuQi on 16/7/7.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARBaseScanView : UIView

@property (nonatomic, assign) BOOL indicatorClockwise;

-(void)scan;
-(void)stop;
-(void)show;
-(void)hide;
//-(void)hideWithFadeAnimation:(NSTimeInterval)duration finishCallBack:(void (^ __nullable)(void))completion;

@end
