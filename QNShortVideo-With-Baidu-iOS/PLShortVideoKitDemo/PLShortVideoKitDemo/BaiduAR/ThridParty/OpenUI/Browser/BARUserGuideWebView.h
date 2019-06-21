//
//  BARUserGuideWebView.h
//  ARSDK
//
//  Created by yuxin on 2016/11/3.
//  Copyright © 2016年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import <UIKit/UIKit.h>

typedef void(^BARUserGuideCloseBlock)(NSURL *requestURL, BOOL showSuccess) ;
typedef void(^BARUserGuideShowSuccessBlock)(NSURL *requestURL) ;
typedef void(^BARUserGuideFailedBlock)(NSURL *requestURL, NSError *error) ;

@interface BARUserGuideWebView : UIView

//点击关闭按钮回调
@property (nonatomic, copy) BARUserGuideCloseBlock closeBlock;

//请求失败回调
@property (nonatomic, copy) BARUserGuideFailedBlock failedBlock;

//请求成功回调
@property (nonatomic, copy) BARUserGuideShowSuccessBlock successBlock;

@property (assign, nonatomic) BOOL userGuideWebDown;
//请求URL地址
- (void)requestURL:(NSURL *)requestURL;

- (void)cancelRequest;

@end
#endif
