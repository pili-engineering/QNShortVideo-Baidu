//
//  BARUploadPogressView.h
//  ARSDK
//
//  Created by tony_Q on 2017/3/14.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BARUploadPogressView : UIView

typedef void (^BARCancleBtnClik)(void);

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) BARCancleBtnClik cancleBtnBlock;

- (void)resizeViewWithAngel:(CGFloat )angle;

@end
