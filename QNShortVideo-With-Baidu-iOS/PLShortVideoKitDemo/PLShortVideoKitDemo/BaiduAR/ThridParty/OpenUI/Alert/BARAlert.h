//
//  BARAlert.h
//  ARSDK
//
//  Created by LiuQi on 15/8/18.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BARAlert : NSObject

typedef void (^BARAlertOtherEventBlock)(void);
typedef void (^BARAlertCancelEventBlock)(void);
typedef void (^BARAlertCompleteEventBlock)(void);

// 类方法
+ (BARAlert *)sharedInstance;

/**
 * @brief 显示自定义的 AlertView
 * @prama title 标题
 * @prama message  内容
 * @prama otherButtonTitles  确定按钮的文字
 * @prama cancelButtonTitle  取消按钮的文字
 * @prama dismissOther   是否dimiss其他的 alert
 */
- (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             otherButtonTitles:(NSString *)otherButtonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  dismissOther:(BOOL)dismiss;

/**
 * @brief 显示自定义的 AlertView  参数同上 ，默认隐藏其他的alertview
 */
- (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             otherButtonTitles:(NSString *)otherButtonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle;


- (void)dismiss;

- (void)showToastOnlyDismissToastViewWithTime:(NSTimeInterval)it message:(NSString *)message;

- (void)setButtonOtherBlock:(BARAlertOtherEventBlock)block;
- (void)setButtonCancelBlock:(BARAlertCancelEventBlock)block;

- (void)showToastViewWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message dismissComplete:(BARAlertCompleteEventBlock)complete;
- (void)showToastViewPortraitWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message dismissComplete:(BARAlertCompleteEventBlock)complete;
- (void)showToastViewPortraitWithTime:(NSTimeInterval)it title:(NSString *)title message:(NSString *)message frame:(CGRect)frame dismissComplete:(BARAlertCompleteEventBlock)complete;

- (void)showToastViewWithTime:(NSTimeInterval)it message:(NSString *)message dismissOthers:(BOOL)diss;


/**
 * @brief 跟踪类型的case内提示：过近，过远，跟踪丢失，
 * @prama 提示的内容
 */
- (void)showTrackIndicatorViewWithText:(NSString *)text;

- (void)dismissIndicator;

- (void)setLandscapeMode:(UIDeviceOrientation)direction;

@end
