//
//  BARPerformanceUtil.m
//  ARSDKBasic-OpenSDK
//
//  Created by Zhao,Xiangkai on 2018/5/14.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARPerformanceUtil.h"
#import "BARApplicationCPU.h"
#import "BARApplicationMemory.h"

@interface BARPerformanceUtil()

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) CADisplayLink *displayLink;


@property (nonatomic, strong) BARApplicationCPU * appCpu;
@property (nonatomic, strong) BARApplicationMemory *appMemory;


@end

@implementation BARPerformanceUtil

+ (instancetype)sharedMonitor {
    static BARPerformanceUtil *sharedMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[super allocWithZone:NSDefaultMallocZone()] init];
    });
    return sharedMonitor;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedMonitor];
}


#pragma mark - CPU&Memory

- (instancetype)init {
    return [self initWithMonitorType:BARResourceMonitorTypeDefault];
}

- (instancetype)initWithMonitorType: (BARResourceMonitorType)monitorType {
    if (self = [super init]) {
        
        if (monitorType & BARResourceMonitorTypeApplicationCpu) {
            self.appCpu = [[BARApplicationCPU alloc] init];
        } else if (monitorType & BARResourceMonitorTypeSystemCpu) {
            
        } else {
            
        }
        if (monitorType & BARResourceMonitorTypeApplicationMemoty) {
            self.appMemory = [[BARApplicationMemory alloc] init];
        } else if (monitorType & BARResourceMonitorTypeSystemMemory) {
            
        } else {
            
        }
        
    }
    return self;
}


- (void)startMonitoring {
    
    _isMonitoring = YES;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(monitor:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.lastTime =self.displayLink.timestamp;
    if (@available(iOS 10.0, *)) {
        self.displayLink.preferredFramesPerSecond = 30;
    } else {
        self.displayLink.frameInterval = 60/30;
    }
}

- (void)monitor:(CADisplayLink *)link {
    double cpuUsage, memoryUsage;
    if (_appCpu) {
        cpuUsage = [_appCpu currentUsage];
    } else {
        cpuUsage = 0;
    }
    if (_appMemory) {
        BARApplicationMemoryUsage usage = [_appMemory currentUsage];
        memoryUsage = usage.usage;
    } else {
        memoryUsage = 0;
    }
    if (self.performanceBlock) {
        self.performanceBlock(cpuUsage,memoryUsage);
    }
}

- (void)stopMonitoring {
    
    [self.displayLink invalidate];
    self.displayLink = nil;
    _isMonitoring = NO;
}

@end
