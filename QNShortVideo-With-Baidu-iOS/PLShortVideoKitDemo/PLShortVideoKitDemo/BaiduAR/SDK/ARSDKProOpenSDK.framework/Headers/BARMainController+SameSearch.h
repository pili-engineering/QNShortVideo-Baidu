//
//  BARMainController+SameSearch.h
//  ARSDKPro
//
//  Created by Asa on 2018/8/3.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARMainController.h"

@interface BARMainController (SameSearch)

/**
 识图组件是否存在

 @return YES：已经存在 NO：不存在
 */
- (BOOL)imageSearch_searchModuleExist;

/**
 初始化识图组件

 @param type kBARTypeLocalSameSearch本地识图 kBARTypeCloudSameSearch云端识图
 @param block 组件设置完成回调；组件初始化为异步操作。初始化完成后，才可进行加载、设置回调等操作。YES：鉴权成功 NO：鉴权失败
 */
- (void)imageSearch_setUpWithARType:(NSInteger)type completion:(void (^_Nonnull)(BOOL success))block;

/**
 加载组件
 */
- (void)imageSearch_loadSameSearch;

/**
 本地识图下载特征库成功回调

 @param block 成功回调
 */
- (void)imageSearch_setDownloadSuccessBlock:(nullable void (^)(void))block;

/**
 识图结果回调

 @param block 回调Block：result：@{@"arKey":@"",@"arType":@""}
 */
- (void)imageSearch_setResultBlock:(nullable void (^)(id  _Nullable result))block;

/**
 识图错误回调

 @param block 错误回调，具体Code值请参考BARImageSearchError
 */
- (void)imageSearch_setErrorBlock:(nullable void (^)(NSError * _Nullable error))block;

/**
 开始识图
 */
- (void)imageSearch_startImageSearch;

/**
 停止识图
 */
- (void)imageSearch_stopImageSearch;

/**
 设置相机buffer

 @param sampleBuffer 相机buffer
 */
- (void)imageSearch_setBufferFrame:(id _Nonnull )sampleBuffer;

/**
 切换本地识图/云端识图
 
 @param type kBARTypeLocalSameSearch本地识图 kBARTypeCloudSameSearch云端识图
 */
- (void)imageSearch_switchARType:(NSInteger)type ;

@end
