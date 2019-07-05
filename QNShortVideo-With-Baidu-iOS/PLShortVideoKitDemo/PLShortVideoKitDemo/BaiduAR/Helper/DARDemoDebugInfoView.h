//
//  DARDemoDebugInfoView.h
//  ARAPP-OpenStandard
//
//  Created by yijieYan on 2018/10/16.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DARDemoDebugInfoView : UIView

@property (nonatomic, assign)CGRect arContentFrame;

- (void)showInView:(UIView *)view;
- (void)hideInView:(UIView *)view;
- (void)setFaceMode:(NSInteger)mode deviceInfo:(NSString *)deviceInfo;
- (void)showARNLabel;
- (void)updateTriggerInfo:(NSString *)trigger;


- (void)drawFacePoints:(NSArray *)point
           frontCamera:(BOOL)frontCamera
            needMirror:(BOOL)needMirror
              vertical:(BOOL)vertical;
@end

