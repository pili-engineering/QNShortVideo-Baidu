//
//  BARTitleSliderView.m
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BARTitleSliderView.h"
#import "UIImage+Load.h"

@interface BARTitleSliderView()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) CSlider *slider;
@property (nonatomic, strong) UILabel *percentLab;
@property (nonatomic, assign) BOOL isPercentShow;

@end

@implementation BARTitleSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame title:nil]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    if (self = [super initWithFrame:frame]) {
        self.isPercentShow = YES;
        CGFloat sliderX = 0;
        if (![title isEqualToString:@""] && title != nil && title.length != 0) {
            self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height - 17, 50, 17)];
            self.titleLab.font = [UIFont systemFontOfSize:14];
            self.titleLab.textColor = [UIColor whiteColor];
            self.titleLab.textAlignment = NSTextAlignmentLeft;
            self.titleLab.text = title;
//            [self.titleLab sizeToFit];
            [self addSubview:self.titleLab];
            sliderX = CGRectGetMaxX(self.titleLab.frame) + 20;
        }
        
        self.slider = [[CSlider alloc]initWithFrame:CGRectMake(sliderX, frame.size.height - 20, frame.size.width - sliderX, 20)];
        [self.slider setValue:0.0];
        [self.slider setMinimumValue:0.0];
        [self.slider setMaximumValue:1.0];
        [self.slider addTarget:self action:@selector(updateSlider:) forControlEvents:UIControlEventValueChanged];
        //[self.slider addTarget:self action:@selector(hidePercentLab:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.slider];
        
        [self.slider setThumbImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_Rectangle"] forState:UIControlStateNormal];
        [self setSliderMinimumTrackImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_RectangleLine"] forState:UIControlStateNormal];
        
        self.percentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, -20, 28, 14)];
        self.percentLab.font = [UIFont systemFontOfSize:10];
        self.percentLab.textColor = [UIColor whiteColor];
        self.percentLab.textAlignment = NSTextAlignmentCenter;
        self.percentLab.hidden = NO;
        [self addSubview:self.percentLab];
        [self updatePercentLabFrameWith:0];
        
    }
    return self;
}

- (void)setSliderThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.slider setThumbImage:image forState:state];
}

- (void)setSliderMinimumTrackImage:(UIImage *)image forState:(UIControlState)state {
    CGSize newSize = self.bounds.size;
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage *TransformedImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.slider setMinimumTrackImage:TransformedImg forState:state];
}

- (void)showPercentLabWith:(BOOL)show {
    self.isPercentShow = show;
    if (!show) {
        CGRect sliderFrame = self.slider.frame;
        sliderFrame.origin.y = 0;
        self.slider.frame = sliderFrame;
        self.percentLab.hidden = YES;
    }
}

- (void)updateSlider:(UISlider *)sender {
    CGFloat value = sender.value;
    if (self.isPercentShow) {
        self.percentLab.hidden = NO;
        [self updatePercentLabFrameWith:value];
    }
    
    if ([self.delegate respondsToSelector:@selector(updateSliderValue:titleSliderView:)]) {
        [self.delegate updateSliderValue:value titleSliderView:self];
    }
}

- (void)hidePercentLab:(UISlider *)sender {
    self.percentLab.hidden = YES;
}

- (void)updatePercentLabFrameWith:(CGFloat)value {
    
    CGRect rect = [self.slider convertRect:self.slider.thumbRect toView:self];
    CGPoint center = self.percentLab.center;
    center.x = rect.origin.x + rect.size.width / 2;
    self.percentLab.center = center;
    self.percentLab.text = [NSString stringWithFormat:@"%.0f%%",value * 100];
}

- (void)setSliderValue:(CGFloat)value {
    [self.slider setValue:value animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updatePercentLabFrameWith:value];
    });
}

- (void)setTitle:(NSString *)title {
    self.titleLab.text = title;
}

@end

@implementation CSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    self.thumbRect = thumbRect;
    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
//            view.clipsToBounds = YES;
            view.contentMode = UIViewContentModeBottomLeft;
        }
    }
    return bounds;
}

@end
