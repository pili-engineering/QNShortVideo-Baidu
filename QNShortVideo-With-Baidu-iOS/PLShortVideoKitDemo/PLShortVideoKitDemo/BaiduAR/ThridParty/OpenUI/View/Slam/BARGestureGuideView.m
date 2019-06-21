//
//  BARGestureGuideView.m
//  ARSDK
//
//  Created by 雪岑申 on 2017/3/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import "BARGestureGuideView.h"
#import "BARFaceUtil.h"
#import "UIImage+BARLoad.h"


@interface BARGestureGuideView ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIButton *button;
@end

@implementation BARGestureGuideView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.imgView = [[UIImageView alloc] initWithFrame:self.frame];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_手势弹窗"];
    [self addSubview:self.imgView];
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 35)];
    self.button.layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 66 - self.button.frame.size.height/2);
    [self.button setTitle:BARNSLocalizedString(@"bar_tip_known") forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor whiteColor];
    self.button.layer.cornerRadius = 3.f;
    self.button.layer.masksToBounds = true;
    [self addSubview:self.button];
    [self.button addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClickBtn:(id)sender {
    self.hidden = true;
}

@end
#endif
