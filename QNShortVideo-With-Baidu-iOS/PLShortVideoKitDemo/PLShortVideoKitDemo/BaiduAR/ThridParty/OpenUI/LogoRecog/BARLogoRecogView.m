//
//  BARLogoRecogView.m
//  ARSDK
//
//  Created by Zhao,Xiangkai on 2018/1/17.
//  Copyright © 2018年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import "BARLogoRecogView.h"

#define ICONWIDTH 48

@interface BARLogoRecogView()

@property (nonatomic, strong)UIView * maskView;
@property (nonatomic, strong)UIView * scanContainerView;
@property (nonatomic, strong)UIImageView * scanImgView;
@property (nonatomic, strong)UILabel * alertLabel;
@property (nonatomic, strong)UIView * iconContainerView;
@property (nonatomic, strong)NSMutableArray * iconArr;
@property (nonatomic, strong)UIButton * closeBtn;

@end

@implementation BARLogoRecogView

- (void)dealloc {
    NSLog(@"BARLogoRecogView dealloc");
}

- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _maskView = [[UIView alloc] initWithFrame:self.bounds];
    _maskView.backgroundColor = [self RGBColorFromHexString:@"#000000" alpha:0.6];
    [self addSubview:_maskView];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Logo_关闭按钮"] forState:UIControlStateNormal];
    _closeBtn.frame = CGRectMake(self.frame.size.width - 17 - 22, 17, 22, 22);
    [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [_maskView addSubview:_closeBtn];
    
    CGFloat width = self.bounds.size.width - 34;
    CGRect scanRect = CGRectMake(17, 114, width, width);
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *bezierPath = [[UIBezierPath bezierPathWithRoundedRect:scanRect cornerRadius:1] bezierPathByReversingPath];
    [maskPath appendPath:bezierPath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
    _maskView.layer.mask = shapeLayer;
    
    _scanContainerView = [[UIView alloc] initWithFrame:scanRect];
    _scanContainerView.backgroundColor = [UIColor clearColor];
    _scanContainerView.clipsToBounds = YES;
    [self addSubview:_scanContainerView];
    
    _scanImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _scanContainerView.frame.size.height + 100, _scanContainerView.frame.size.width, _scanContainerView.frame.size.height)];
    _scanImgView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Logo_扫描条"];
    [_scanContainerView addSubview:_scanImgView];
    
    
//    CGFloat alertLabelY = self.bounds.size.height / 667 * 42 + CGRectGetMaxY(_scanContainerView.frame);
//    _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, alertLabelY, self.bounds.size.width - 20, 20)];
    _alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _alertLabel.font = [UIFont systemFontOfSize:14];
    _alertLabel.textAlignment = NSTextAlignmentCenter;
    
    _alertLabel.textColor = [self RGBColorFromHexString:@"#ffffff" alpha:1.0];
    _alertLabel.text = @"找到下方logo，扫描获取";
    [self addSubview:_alertLabel];
    
    _iconContainerView = [[UIView alloc] init];
    _iconContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_iconContainerView];
    
}

- (void)setIconImages:(NSArray *)images {
    
    self.alertLabel.hidden = NO;
    self.iconContainerView.hidden = NO;
    if (images == nil || images.count  == 0 || images.count > 3) {
        self.alertLabel.hidden = YES;
        self.iconContainerView.hidden = YES;
        return;
    }
    CGFloat iconMargin = 24;
    CGFloat width = (images.count - 1) * iconMargin + images.count * ICONWIDTH;
    CGFloat iconContainerViewY = self.bounds.size.height - ICONWIDTH - self.bounds.size.height / 667 * 78;
    _iconContainerView.frame = CGRectMake(0, iconContainerViewY, width, ICONWIDTH);
    _iconContainerView.center = CGPointMake(self.center.x, _iconContainerView.center.y);
    
    CGFloat alertLabelY = _iconContainerView.frame.origin.y - self.bounds.size.height / 667 * 24 - 20;
    _alertLabel.frame = CGRectMake(10, alertLabelY, self.bounds.size.width - 20, 20);
    
    [self.iconArr removeAllObjects];
    [_iconContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.iconArr =images.mutableCopy;
    
    for (int i = 0; i < images.count; i++) {
        UIImageView * imgView = [self iconImgView];
        imgView.image = [UIImage imageWithContentsOfFile:images[i]];
        CGRect frame = imgView.frame;
        frame.origin.x = (i * ICONWIDTH) + (i * 24);
        imgView.frame = frame;
        [_iconContainerView addSubview:imgView];
    }
}

- (void)setTitle:(NSString *)title {
    if (title != nil && ![title isEqualToString:@""]) {
        self.alertLabel.text = title;
    }
}

- (void)startAnimation {
    [self.scanImgView.layer removeAnimationForKey:@"positionAnima"];
    CABasicAnimation * positionAnima = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionAnima.duration = 3;
    positionAnima.removedOnCompletion = NO;
    positionAnima.repeatCount = HUGE_VALF;
    positionAnima.autoreverses = NO;
    positionAnima.fromValue = @(self.scanContainerView.bounds.size.height + 100);
    positionAnima.toValue = @(-self.scanImgView.bounds.size.height / 2);
    [self.scanImgView.layer addAnimation:positionAnima forKey:@"positionAnima"];
}

- (void)stopAnimation {
    [self.iconArr removeAllObjects];
    [_iconContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scanImgView.layer removeAnimationForKey:@"positionAnima"];
}
- (void)closeClick {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (UIImageView *)iconImgView {
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(0, 0, ICONWIDTH, ICONWIDTH);
    iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    iconImgView.clipsToBounds = YES;
    [iconImgView setBackgroundColor:[UIColor whiteColor]];
    return iconImgView;
}

- (NSMutableArray *)iconArr {
    if (!_iconArr) {
        _iconArr = [NSMutableArray array];
    }
    return _iconArr;
}

- (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha {
    if ([aHexStr isKindOfClass:[NSString class]] && aHexStr
        && aHexStr.length > 6) // #rrggbb 大小写字母及数字
    {
        int nums[6] = {0};
        for (int i = 1; i < MIN(7, [aHexStr length]); i++) // 第一个字符是“＃”号
        {
            int asc = [aHexStr characterAtIndex:i];
            if (asc >= '0' && asc <= '9') // 数字
                nums[i - 1] = [aHexStr characterAtIndex:i] - '0';
            else if(asc >= 'A' && asc <= 'F') // 大写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'A' + 10;
            else if(asc >= 'a' && asc <= 'f') // 小写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'a' + 10;
            else
                return [UIColor whiteColor];
        }
        float rValue = (nums[0] * 16 + nums[1]) / 255.0f;
        float gValue = (nums[2] * 16 + nums[3]) / 255.0f;
        float bValue = (nums[4] * 16 + nums[5]) / 255.0f;
        UIColor *rgbColor = [UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aAlpha];
        return rgbColor;
    }
    
    return [UIColor blackColor]; // 默认黑色
}

@end
#endif
