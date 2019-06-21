//
//  BARFilterCollectionViewCell.m
//  ARSDKBasic-INDEP
//
//  Created by Zhao,Xiangkai on 2018/4/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARFilterCollectionViewCell.h"
#import "UIImage+Load.h"
//#import "UIImageView+WebCache.h"

@interface BARFilterCollectionViewCell()

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *selectedImgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation BARFilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    
    self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self.contentView addSubview:self.bgImgView];
    
    self.selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.selectedImgView.hidden = YES;
    self.selectedImgView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_滤镜选中"];
    [self.contentView addSubview:self.selectedImgView];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.selectedImgView.frame) + 4, self.contentView.bounds.size.width, 17)];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.textColor = [UIColor whiteColor];
    self.titleLab.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:self.titleLab];
    
}

- (void)updateBgImgViewWith:(NSString *)url {
    if ([url hasPrefix:@"http"]) {
//        UIImage * holderImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"];
//        if([url length]) {
//            [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:holderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                if(error){
//                    NSLog(@"url :%@\nerror:%@ ",imageURL,error);
//                }
//                if(!image){
//                    NSLog(@"url :%@\nerror:%@ imageisnull",imageURL,error);
//                }
//            }];
//        }else{
//            [self.bgImgView sd_cancelCurrentImageLoad];
//        }
    }else{
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:url];
        self.bgImgView.image = [UIImage imageWithContentsOfFile:path];
    }
}

- (void)updateSelectedStatusWith:(BOOL)selected {
    self.selectedImgView.hidden = !selected;
    if (selected) {
        self.titleLab.textColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0];
    } else {
        self.titleLab.textColor = [UIColor whiteColor];
    }
}

- (void)setTitlaLabelWith:(NSString *)title {
    self.titleLab.text = title;
}

@end
