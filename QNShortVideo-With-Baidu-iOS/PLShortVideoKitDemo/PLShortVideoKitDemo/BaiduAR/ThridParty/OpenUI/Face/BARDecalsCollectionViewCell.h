//
//  BARDecalsCollectionViewCell.h
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/4/10.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BARSWITCHDECALSDONE @"BARSWITCHDECALSDONE"

@interface BARDecalsCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) BOOL  isAnimationing;
- (void)resetStatus;
- (void)updateImageUrl:(NSString *)url;

- (void)setCellWithModel:(id)model;

- (void)startAnimation;
- (void)stopAnimation;
- (void)resumeAnimationWith:(BOOL)resume;

- (void)setLandscapeMode:(UIDeviceOrientation)direction;

@end
