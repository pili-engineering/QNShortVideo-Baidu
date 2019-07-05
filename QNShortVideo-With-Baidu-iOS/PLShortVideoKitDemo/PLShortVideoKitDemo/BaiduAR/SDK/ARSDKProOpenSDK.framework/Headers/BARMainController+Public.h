//
//  BARMainController+Public.h
//  AR-Base
//
//  Created by Asa on 2018/3/28.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#if !TARGET_OS_SIMULATOR

#import "BARMainController.h"
#import "BARImageMovieWriter.h"

//ARType：
/*
  kBARTypeLocalSameSearch || kBARTypeCloudSameSearch - - - Do same searching by yourself
  kBARTypeARKit == arType - - - Currently not supported
  Other - - -Call startAR
 */
typedef void(^BARLoadSuccessBlock)(NSString *arKey, kBARType arType);
typedef void(^BARLoadFailedBlock)(void);

@interface BARMainController (Public)

/**
 从网络加载AR

 @param arKey ARKey
 @param successBlock 加载成功回调
 @param failureBlock 加载失败回调
 */
- (void)loadAR:(NSString *)arKey success:(BARLoadSuccessBlock)successBlock
 failure:(BARLoadFailedBlock)failureBlock;


/**
 从本地路径加载AR

 @param filePath case资源包路径,下载并解压完后的路径：比如 ../bar_10070173/ar/...，传递的参数filePath为../bar_10070173
 @param arType case对应的artype
 @param successBlock 加载成功回调
 @param failureBlock 加载失败回调：case包有问题或者鉴权失败
 */
- (void)loadARFromFilePath:(NSString *)filePath arType:(NSString *)arType success:(BARLoadSuccessBlock)successBlock failure:(BARLoadFailedBlock)failureBlock;


/**
 从本地路径加载AR
 
 @param filePath case资源包路径,下载并解压完后的路径：比如 ../bar_10070173/ar/...，传递的参数filePath为../bar_10070173
 @param arType ARKey（case唯一标识）
 @param successBlock 加载成功回调
 @param failureBlock 加载失败回调：case包有问题或者鉴权失败
 */
- (void)loadARFromFilePath:(NSString *)filePath arKey:(NSString *)arKey arType:(NSString *)arType success:(BARLoadSuccessBlock)successBlock failure:(BARLoadFailedBlock)failureBlock;

/**
 录制视频时，需要设置movieWriter

 @param movieWriter 视频录制
 */
- (void)setRenderMovieWriter:(BARImageMovieWriter *)movieWriter;

- (kBARType)arTypeFromServer:(NSString *)arType;


/**
 设置非人脸算法模型总包路径：json配置文件+模型

 @param path 算法模型路径
 */
- (void)setAlgorithmModelsPath:(NSString *)path;

/**
 设置非人脸算法模型根路径

 @param path 根路径
 */
- (void)setAlgorithmModelsRootPath:(NSString *)path;

/**
 设置非人脸算法模型

 @param path json配置文件
 */
- (void)setAlgorithmConfigPath:(NSString *)path;

/**
 设置低端机型（可选）

 @param models 低端机型列表，eg：[@"iPhone 5s"]
                            传nil，清除低端机型列表
 */
- (void)setLowModels:(NSArray *)models;


/**
 SDK最低支持的版本号

 @return eg：240
 */
+ (NSString *)minimumVersion;


/**
 是否允许内部对AVAudioSession进行category设置(默认YES)

 @param enable YES/NO
 */
- (void)enableAVSessionInternalManage:(BOOL)enable;

@end

#endif
