//
//  BARLogoRecogView.h
//  ARSDK
//
//  Created by Zhao,Xiangkai on 2018/1/17.
//  Copyright © 2018年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import <UIKit/UIKit.h>

typedef void(^BARLogoRecogCloseBlock)() ;

@interface BARLogoRecogView : UIView

@property (nonatomic,strong) BARLogoRecogCloseBlock closeBlock;

- (void)setIconImages:(NSArray *)images;
- (void)setTitle:(NSString *)title;
- (void)startAnimation;
- (void)stopAnimation;

@end
#endif
