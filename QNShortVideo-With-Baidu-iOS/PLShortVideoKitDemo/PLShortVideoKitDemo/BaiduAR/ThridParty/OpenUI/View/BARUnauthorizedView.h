//
//  BARUnauthorizedView.h
//  ARSDK
//
//  Created by LiuQi on 15/8/20.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BARUnauthorizedViewCloseEvent)();
typedef void (^BARUnauthorizedGoToSetEvent)();

@interface BARUnauthorizedView : UIView

@property (nonatomic, copy) BARUnauthorizedViewCloseEvent closeEvent;
@property (nonatomic, copy) BARUnauthorizedGoToSetEvent goSetEvent;
@end
