//
//  BARBeautyCollectionViewCell.h
//  ARAPP-OpenStandard
//
//  Created by Zhou,Rui(ART) on 2018/10/16.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BARBeautyCollectionViewCell : UICollectionViewCell

- (void)updateBgImgViewWith:(NSString *)url;
- (void)updateTitleColorwith:(BOOL)isSelect;//根据是否选择更改字体颜色
- (void)setTitlaLabelWith:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
