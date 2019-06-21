//
//  BARTitleSliderView.h
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BARTitleSliderView;

@protocol BARTitleSliderViewDelegate <NSObject>

- (void)updateSliderValue:(CGFloat)value titleSliderView:(BARTitleSliderView *)titleSliderView;

@end

@interface BARTitleSliderView : UIView

@property (nonatomic, weak) id<BARTitleSliderViewDelegate>delegate;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)showPercentLabWith:(BOOL)show;
- (void)setSliderValue:(CGFloat)value;
- (void)setSliderThumbImage:(UIImage *)image forState:(UIControlState)state;
- (void)setSliderMinimumTrackImage:(UIImage *)image forState:(UIControlState)state;
@end

@interface CSlider:UISlider

@property (nonatomic, assign) CGRect thumbRect;

@end
