//
//  BARFilterCollectionViewCell.h
//  ARSDKBasic-INDEP
//
//  Created by Zhao,Xiangkai on 2018/4/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARFilterCollectionViewCell : UICollectionViewCell

- (void)updateBgImgViewWith:(NSString *)url;
- (void)updateSelectedStatusWith:(BOOL)selected;
- (void)setTitlaLabelWith:(NSString *)title;

@end
