//
//  BARPerformanceUtil.h
//  ARSDKBasic-OpenSDK
//
//  Created by Zhao,Xiangkai on 2018/5/14.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^BARPerformanceBlock)(CGFloat currentCPU, CGFloat currentMemory);

typedef NS_ENUM(NSInteger, BARResourceMonitorType)
{
    BARResourceMonitorTypeDefault = (1 << 2) | (1 << 3),
    BARResourceMonitorTypeSystemCpu = 1 << 0,   ///<    监控系统CPU使用率，优先级低
    BARResourceMonitorTypeSystemMemory = 1 << 1,    ///<    监控系统内存使用率，优先级低
    BARResourceMonitorTypeApplicationCpu = 1 << 2,  ///<    监控应用CPU使用率，优先级高
    BARResourceMonitorTypeApplicationMemoty = 1 << 3,   ///<    监控应用内存使用率，优先级高
};

@interface BARPerformanceUtil : NSObject

+ (instancetype)sharedMonitor;

@property (nonatomic, copy) BARPerformanceBlock performanceBlock;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
