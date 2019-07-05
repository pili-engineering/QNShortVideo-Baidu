//
//  BARGestureView.h
//  ARAPP-OpenStandard
//
//  Created by Asa on 2019/3/25.
//  Copyright © 2019 Asa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BARGestureDelegate <NSObject>

- (void)onViewGesture:(UIGestureRecognizer *)gesture;

- (void)ar_touchesBegan:(NSSet<UITouch *> *)touches scale:(CGFloat)scale ;
- (void)ar_touchesMoved:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;
- (void)ar_touchesEnded:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;
- (void)ar_touchesCancelled:(NSSet<UITouch *> *)touches scale:(CGFloat)scale;

- (void)touchesBegan:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesMoved:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesEnded:(CGPoint)point scale:(CGFloat)scale;
- (void)touchesCancelled:(CGPoint)point scale:(CGFloat)scale;

@end


@interface BARGestureView : UIView

@property (nonatomic, weak) id<BARGestureDelegate> gesturedelegate;
@property (nonatomic, assign) BOOL enabled;

@end

NS_ASSUME_NONNULL_END
