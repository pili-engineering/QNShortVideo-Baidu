//
//  BARFaceUtil.m
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/7/11.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import "BARFaceUtil.h"

@implementation BARFaceUtil

+ (NSString *)getBARLocalString:(NSString *)key {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BaiduAR" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if(bundle){
        NSString *value = [bundle localizedStringForKey:key value:nil table:@"BARLocalizable"];
        return value;
    }
    
    return key;
}

@end
