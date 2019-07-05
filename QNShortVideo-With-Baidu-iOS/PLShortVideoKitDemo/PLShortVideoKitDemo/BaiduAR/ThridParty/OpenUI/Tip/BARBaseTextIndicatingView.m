//
//  BARBaseTextIndicatingView.m
//  ARSDK
//
//  Created by LiuQi on 16/7/7.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BARBaseTextIndicatingView.h"
#import "NSString+BARFont.h"

@interface BARBaseTextIndicatingView ()
@property (nonatomic, strong) UILabel *indicatingLabel;
@property (nonatomic, strong) UIView *indicatingBg;
//@property (nonatomic) CGRect originPointRect;
@property (nonatomic) UIDeviceOrientation direction;
@end

@implementation BARBaseTextIndicatingView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.bottomMargin = 135.f;
        self.leftMargin = 30.f;
        self.indicatingBg = [[UIView alloc] init];
        self.indicatingBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.indicatingBg.layer.cornerRadius = 3;
        self.indicatingBg.layer.masksToBounds =  true;
        [self addSubview:self.indicatingBg];
        
        self.indicatingLabel = [[UILabel alloc] init];
        self.indicatingLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.indicatingLabel.numberOfLines = 0;
        self.indicatingLabel.textAlignment = NSTextAlignmentCenter;
        self.indicatingLabel.textColor = [UIColor whiteColor];
        self.indicatingLabel.font = [UIFont systemFontOfSize:16.0];
        self.indicatingLabel.backgroundColor = [UIColor clearColor];
        [self.indicatingBg addSubview:self.indicatingLabel];
        self.direction = UIDeviceOrientationPortrait;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)show
{    
    if(self.hidden) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFrame];
            self.hidden = NO;
        });
    }
}

- (void)hide
{
    if(!self.hidden) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hidden = YES;
        });
    }
}

- (void)setText:(NSString*)text
{
     dispatch_async(dispatch_get_main_queue(), ^{
         self.indicatingLabel.text = text;
         [self updateFrame];
     });
}

- (void)layoutSubviews  {
    [super layoutSubviews];
}

- (void)updateFrame {
    
    CGSize fontSize = [self.indicatingLabel.text re_sizeWithFont:self.indicatingLabel.font];
    
    if (self.direction == UIDeviceOrientationLandscapeLeft) {
        
        self.indicatingBg.transform = CGAffineTransformMakeRotation(0.5 * M_PI);
        
        CGSize indicatingSize = CGSizeMake(fontSize.height+ 22.f,fontSize.width + 40.f);
        CGRect indicatingFrame = CGRectMake(self.leftMargin, (self.frame.size.height - indicatingSize.height) /2 , indicatingSize.width, indicatingSize.height);
        
        self.indicatingLabel.frame = CGRectMake(20.f,11.f,fontSize.width,fontSize.height);
        self.indicatingBg.frame = indicatingFrame;
        
        
    } else if (self.direction == UIDeviceOrientationLandscapeRight) {
        
        self.indicatingBg.transform = CGAffineTransformMakeRotation(-0.5 * M_PI);
        
        CGSize indicatingSize = CGSizeMake(fontSize.height+ 22.f,fontSize.width + 40.f);
        CGRect indicatingFrame = CGRectMake(self.frame.size.width - indicatingSize.width - 30.f  ,(self.frame.size.height - indicatingSize.height) /2 , indicatingSize.width, indicatingSize.height);

        self.indicatingLabel.frame = CGRectMake(20.f,11.f,fontSize.width,fontSize.height);
        self.indicatingBg.frame = indicatingFrame;
        
        
    }else {
        self.indicatingBg.transform = CGAffineTransformIdentity;
         CGSize indicatingSize = CGSizeMake(fontSize.width + 40.f, fontSize.height+ 22.f);
         CGRect indicatingFrame = CGRectMake( (self.frame.size.width - indicatingSize.width) /2, self.frame.size.height - indicatingSize.height - self.bottomMargin , indicatingSize.width, indicatingSize.height);
        
        self.indicatingLabel.frame = CGRectMake(20.f,11.f, fontSize.width, fontSize.height);
        self.indicatingBg.frame = indicatingFrame;
    }
}

- (void)setLandscapeMode:(UIDeviceOrientation)direction
{
    self.direction = direction;
    [self updateFrame];
}


@end
