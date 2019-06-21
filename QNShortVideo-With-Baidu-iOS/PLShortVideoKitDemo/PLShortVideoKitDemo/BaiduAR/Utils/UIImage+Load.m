//
//  UIImage+BARLoad.m
//  ARSDK
//
//  Created by liubo on 26/07/2017.
//  Copyright © 2017 Baidu. All rights reserved.
//

#import "UIImage+Load.h"


@implementation UIImage (Load)
+ (UIImage *) imageNamedForBAR:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    if(!image){
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"BaiduAR.bundle"];
        image = [UIImage imageNamed:[path stringByAppendingPathComponent:name]];
    }
    return image;
}

+ (UIImage *) imageWithContentOfFileForBAR:(NSString *)name {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}
@end
