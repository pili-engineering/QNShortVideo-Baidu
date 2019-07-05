//
//  BARUploadPogressView.m
//  ARSDK
//
//  Created by tony_Q on 2017/3/14.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BARUploadPogressView.h"
#import "BARFaceUtil.h"
#import "UIImage+Load.h"


#define kCircleLineWidth 3.f
#define kCircleFont [UIFont boldSystemFontOfSize:18.0f]
#define kCircleFontColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]
#define kCircleLineColor [UIColor colorWithRed:0.35 green:0.62 blue:0.99 alpha:1.00]
#define kCircleRadius  37.0f
#define kContentFont [UIFont boldSystemFontOfSize:14.0f]
#define kTotalheight 112.0f
#define kCancelBtnWidth 96.5

@interface BARUploadPogressView ()

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation BARUploadPogressView


- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    
    CGFloat x = self.bounds.origin.x;
    CGFloat y = (self.bounds.size.height - kTotalheight)/2;
    CGFloat width = self.bounds.size.width;
    
    self.backgroundColor = [UIColor clearColor];
    _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y-kCircleRadius + kCircleLineWidth , width, kCircleRadius*2)];
    _progressLabel.font = kCircleFont;
    _progressLabel.textColor = kCircleFontColor;
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_progressLabel];
    
    _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, y+kCircleRadius+20, self.bounds.size.width, 20)];
    _contentLabel.font =kContentFont;
    _contentLabel.textColor = kCircleFontColor;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.text = BARNSLocalizedString(@"bar_tip_video_creating");
    [self addSubview:_contentLabel];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame = CGRectMake((self.bounds.size.width-kCancelBtnWidth)/2, y + kCircleRadius + 20 + 20 + 20, kCancelBtnWidth, 32);
    
    UIImage *imageHighLight = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_取消按钮"];
    [_cancelBtn setImage:imageHighLight forState:UIControlStateNormal];
    [_cancelBtn.layer setMasksToBounds:YES];
    _cancelBtn.layer.cornerRadius = 2.0;
    [_cancelBtn addTarget:self action:@selector(cancleBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
}

- (void) setProgress:(CGFloat)progress {

    _progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

/**
 *  开始画进度条
 */
- (void)drawRect:(CGRect)rect
{
    //路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    //线宽
    path.lineWidth = kCircleLineWidth;
    //颜色
    [kCircleLineColor set];
    //拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    //半径
    //    CGFloat radius = (MIN(rect.size.width, rect.size.height) - kCircleLineWidth) * 0.5;
    CGFloat radius = kCircleRadius;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, (rect.size.height - kTotalheight)/2.0f} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    //连线
    [path stroke];
}

- (void) cancleBtnClik:(UIButton *)sender {
    
    if (self.cancleBtnBlock) {
        self.cancleBtnBlock();
    }
}

- (void)resizeViewWithAngel:(CGFloat )angle {
    self.transform = CGAffineTransformMakeRotation(angle);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
