//
//  BARBeautyCollectionViewCell.m
//  ARAPP-OpenStandard
//
//  Created by Zhou,Rui(ART) on 2018/10/16.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "BARBeautyCollectionViewCell.h"
#import "UIImage+Load.h"

@interface BARBeautyCollectionViewCell()

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation BARBeautyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 28, 28)];
    [self.contentView addSubview:self.bgImgView];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bgImgView.frame) + 5, self.contentView.bounds.size.width, 17)];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.textColor = [UIColor whiteColor];
    self.titleLab.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:self.titleLab];
}

- (void)updateBgImgViewWith:(NSString *)url {
    NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:url];
    self.bgImgView.image = [UIImage imageWithContentsOfFile:path];
}

- (void)updateTitleColorwith:(BOOL)isSelect {
    if (isSelect) {
        self.titleLab.textColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0];
    } else {
        self.titleLab.textColor = [UIColor whiteColor];
    }
}

- (void)setTitlaLabelWith:(NSString *)title {
    self.titleLab.text = title;
}

@end
