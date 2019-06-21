//
//  BARBaseImageVideoSwtichView.h
//  ARSDK
//
//  Created by liubo on 13/03/2017.
//  Copyright © 2017 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BARBaseImageVideoSwitchView;

@protocol BARBaseImageVideoSwitchViewDelegate <NSObject>

@optional
-(void) imageVideoSwitchToFirst:(BOOL) toFirst;
-(void) imageVideoSwitchDoingAnimation:(BOOL)doingAnimation;
@end


@interface BARBaseImageVideoSwitchView : UIView

@property (nonatomic, weak) id<BARBaseImageVideoSwitchViewDelegate> delegate;

@property (nonatomic, assign) BOOL isForFirst;

@end
