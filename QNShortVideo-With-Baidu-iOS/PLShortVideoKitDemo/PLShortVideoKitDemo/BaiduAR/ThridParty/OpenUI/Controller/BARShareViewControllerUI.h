//
//  BARShareViewControllerUI.h
//  ARSDK
//
//  Created by yijieYan on 2017/7/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BARShareViewControllerUI : NSObject

+ (UIButton *)createCloseBtn:(UIView *)parentView;
+ (UIButton *)createShareBtn:(UIView *)parentView;
+ (UIButton *)createSaveBtn:(UIView *)parentView;

@end
