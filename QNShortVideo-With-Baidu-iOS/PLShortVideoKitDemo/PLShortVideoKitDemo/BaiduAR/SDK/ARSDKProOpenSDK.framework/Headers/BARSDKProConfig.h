//
//  BARConfig.h
//  ARSDK
//
//  Created by LiuQi on 15/8/18.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "BARSDKPro.h"
#import "BARSDKFoundationDef.h"

//#define BARNSLocalizedString(key) [[BARConfig sharedInstance] getBARLocalString:key]

@interface BARSDKProConfig : NSObject

// 类方法
+ (BARSDKProConfig *)sharedInstance;

@property (nonatomic,copy) NSString* engineVersion;
@property (nonatomic,copy) NSString* baseServer;    //推荐接口，分布加载下载接口

@property (nonatomic,copy) NSString* appId;
@property (nonatomic,copy) NSString* targetInfo;

// ar统计接口
@property (nonatomic,copy) NSString* arValue;
@property (nonatomic,copy) NSString* arID;
@property (nonatomic, copy) NSString *arFrom;
@property (nonatomic, copy) NSString *CUID;

// 保存当前case包的路径
@property (nonatomic, copy) NSString* resPath;
@property (nonatomic, copy) NSString* videoPath;

// 不支持AR时跳转的URL
@property (nonatomic, copy) NSString* arUnsupportURL;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, copy) NSString *arType;

// basic版本的imu没有隔离，需要单独处理，在pro版本需要删有关此属性的逻辑
@property (nonatomic, assign) BOOL isImuType;

//本地调试使用字段
@property (nonatomic, assign) BOOL useAsShell;

@property (nonatomic, strong) NSString* previewAppInfo;

// opensdk字段

// openSDK 2.0 新增字段
@property (nonatomic, copy) NSString *opensdkAipAppID;
@property (nonatomic ,copy) NSString *apiKey;
@property (nonatomic, copy) NSString *opensdkISAip;
@property (nonatomic, copy) NSString *opensdkSecretKey;

@property (nonatomic, assign) BOOL timeStatisticsOpened;

// arplay 新增字段
@property (nonatomic, copy) NSString *extraInfo;

// 请求中需要携带的公共参数
- (NSDictionary *)composeCommonServerParameter;
- (NSString*)getIdentifier;
- (NSString*)getSystemVersion;
- (NSString*)getPlatform;
- (NSString*)getCommonARValue;


- (NSString *)arDeviceInfo:(NSString *)arValue;
- (NSString *)getBARLocalString:(NSString *)key;
- (NSString *)getBARLocalString:(NSString *)key defaultvalue:(NSString *)defaultvalue;
- (NSString *)opensdkSign:(NSString *)timestamp;
- (BOOL)isOpenSDK;
//- (NSString *)arPublishID;
- (NSString *)getTimestamp;

- (void)setCameraPreset:(NSString*)preset;
- (NSString*)getCameraPreset;
//- (kBARType)arTypeByArTypeStr:(NSString *)type;

+ (kBARType)arTypeFromServer:(NSString *)arType;

@end

