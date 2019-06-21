//
//  NSString+Font.h
//  FMApp
//
//  Created by LiuQi on 16/3/17.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (BARFont)

- (CGSize)re_sizeWithFont:(UIFont *)font;
- (CGSize)re_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end
