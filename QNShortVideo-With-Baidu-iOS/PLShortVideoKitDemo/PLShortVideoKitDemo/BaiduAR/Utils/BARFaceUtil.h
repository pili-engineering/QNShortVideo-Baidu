//
//  BARFaceUtil.h
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/7/11.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BARNSLocalizedString(key) [BARFaceUtil getBARLocalString:key]

@interface BARFaceUtil : NSObject

+ (NSString *)getBARLocalString:(NSString *)key;

@end
