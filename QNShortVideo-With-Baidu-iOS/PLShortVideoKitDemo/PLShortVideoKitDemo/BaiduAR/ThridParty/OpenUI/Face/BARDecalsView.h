//
//  BARDecalsView.h
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BARChangeDecalsBlock)(NSInteger index);
typedef void(^BARCancelDecalsBlock)(NSInteger index);
typedef void(^BARHideDeclasBlock)(void);

@interface BARDecalsView : UIView

@property (nonatomic, copy) BARChangeDecalsBlock changeDecalsBlock;
@property (nonatomic, copy) BARCancelDecalsBlock cancelDecalsBlock;
@property (nonatomic, copy) BARHideDeclasBlock hideDecalsBlock;
- (void)setDecalsDataWith:(NSArray *)decalsData;
- (void)handleSwitchDone;
- (void)resetDecalsViewData ;
@end
