//
//  BARLightsView.h
//  ARSDK
//
//  Created by 雪岑申 on 2017/3/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import <UIKit/UIKit.h>

@interface BARLightsView : UIView
- (id)init:(NSInteger)num;
- (void)lightUp:(NSInteger)lights;
@end
#endif
