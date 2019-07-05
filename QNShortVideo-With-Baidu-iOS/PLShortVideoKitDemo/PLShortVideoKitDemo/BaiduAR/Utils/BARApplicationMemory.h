//
//  BARApplicationMemory.h
//  ARSDKBasic-OpenSDK
//
//  Created by Zhao,Xiangkai on 2018/5/14.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct BARApplicationMemoryUsage
{
    double usage;   ///< 已用内存(MB)
    double total;   ///< 总内存(MB)
    double ratio;   ///< 占用比率
} BARApplicationMemoryUsage;

@interface BARApplicationMemory : NSObject

- (BARApplicationMemoryUsage)currentUsage;

@end
