//
//  BARBeautyView.h
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BARChangeSliderValueBlock)(CGFloat value, NSString *title);
typedef void(^BARChangeFilterBlock)(NSInteger index);
typedef void(^BARChangeBeautyBlock)(NSString *beauty);
typedef void(^BARCancelFilterBlock)(void);
typedef void(^BARHideBeautyBlock)(void);
typedef void(^BARResetBeautyBlock)(void);
typedef void(^BARCancelBeautyBlock)(void);

@interface BARBeautyView : UIView

@property (nonatomic, copy) BARChangeSliderValueBlock changeSliderValueBlock;
@property (nonatomic, copy) BARChangeFilterBlock changeFilterBlock;
@property (nonatomic, copy) BARChangeBeautyBlock changeBeautyBlock;
@property (nonatomic, copy) BARHideBeautyBlock hideBeautyBlock;
@property (nonatomic, copy) BARCancelFilterBlock cancelFilterBlock;
@property (nonatomic, copy) BARResetBeautyBlock resetBeautyBlock;
@property (nonatomic, copy) BARCancelBeautyBlock cancelBeautyBlock;

- (void)setSliderValue:(CGFloat)value type:(NSInteger)type;
- (void)setFilterGroupWith:(NSArray *)filterGroup;

@end
