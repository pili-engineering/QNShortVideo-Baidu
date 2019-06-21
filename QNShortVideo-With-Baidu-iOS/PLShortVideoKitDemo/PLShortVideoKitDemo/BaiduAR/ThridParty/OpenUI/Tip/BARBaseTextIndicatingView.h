//
//  BARBaseTextIndicatingView.h
//  ARSDK
//
//  Created by LiuQi on 16/7/7.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARBaseTextIndicatingView : UIView
@property (assign, nonatomic) float leftMargin;
@property (assign, nonatomic) float bottomMargin;
- (void)setText:(NSString*)text;
- (void)show;
- (void)hide;

- (void)setLandscapeMode:(UIDeviceOrientation)direction;

@end
