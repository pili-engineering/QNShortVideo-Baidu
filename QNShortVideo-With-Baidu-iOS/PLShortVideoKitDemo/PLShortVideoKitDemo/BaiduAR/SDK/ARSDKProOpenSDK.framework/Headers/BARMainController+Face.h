//
//  BARMainController+Face.h
//  AR-Base
//
//  Created by Zhao,Xiangkai on 2018/8/2.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARMainController.h"

typedef enum : NSUInteger {
    BAROutConfigurationTypeDefault = 0,
    BAROutConfigurationTypeBaseAR,
    BAROutConfigurationTypeFaceAR,
} BAROutConfigurationType;

/**
 人脸每帧的数据回调
 
 @param frameDict 数据字典，字典的数据为：
 @{@"trackingSucceeded":@(是否跟上)}
 */
typedef void(^BARFaceFrameAvailableBlock)(NSDictionary *frameDict,CMSampleBufferRef originBuffer);

/**
 贴纸加载完成之后回调
 
 @param triggerList 模型中配置的可以处理的数据
 */
typedef void(^BARFaceAssetLoadingFinishedBlock)(NSArray *triggerList);

/**
 人脸触发的trigger数据回调
 
 @param triggerList 算法识别的trigger数据
 */
typedef void(^BARFaceTriggerListLogBlock)(NSArray *triggerList);

/**
 算法计算得到的数据回调
 
 @param box 算法得到的人脸数据 默认CGRectZero
 @param facePoints 算法得到的人脸特征点
 @param isTracking YES:跟上 NO 跟丢
 */
typedef void(^BARFaceDrawFaceBoxRectangleBlock)(CGRect box, NSArray *facePoints, BOOL isTracking);


@interface BARMainController()

@property (nonatomic, copy) BARFaceFrameAvailableBlock faceFrameAvailableBlock;

@property (nonatomic, copy) BARFaceAssetLoadingFinishedBlock faceAssetLoadingFinishedBlock;
@property (nonatomic, copy) BARFaceTriggerListLogBlock faceTriggerListLogBlock;
@property (nonatomic, copy) BARFaceDrawFaceBoxRectangleBlock faceDrawFaceBoxRectangleBlock;


@property (nonatomic, copy) NSString *faceDetectPath;
@property (nonatomic, assign) BOOL faceSyncProcess;
@property (nonatomic, strong) NSArray *faceTrackPaths;//track paths
@property (nonatomic, assign) BOOL printLog;

@property (nonatomic, strong) NSDictionary *faceActiveInfo;


@end

@interface BARMainController(Face)

#pragma mark - 人脸算法
/**
 人脸算法初始化，需要在创建controler之后调用
 */
- (void)initFaceData;

/**
 设置算法imbin路径

 @param imbinPath imbinPath
 */
- (void)setImbin:(NSString *)imbinPath;

/**
 设置人脸检测模型路径

 @param detectPath 模型路径
 */
- (void)setFaceDetectModelPath:(NSString *)detectPath;

/**
 设置人脸跟踪模型路径（数组）

 @param trackPaths 跟踪路径
 */
- (void)setFaceTrackModelPaths:(NSArray *)trackPaths;

#pragma mark - 人脸渲染
#pragma mark - 滤镜

/**
 加载滤镜配置文件
 
 @param path 配置文件绝对路径
 */
- (void)loadFaceFilterDefaultConfigWith:(NSString *)path;

/**
设置滤镜资源路径和配置路径
 @param bundlePath 资源路径
 @param configPath 配置路径
 */
- (void)setFilterBundlePath:(NSString *)bundlePath configPath:(NSString *)configPath;

/**
 切换滤镜
 @param filterId 滤镜id
 */
- (void)switchFilter:(NSString *)filterId;

/**
 获取滤镜默认值
 @return 默认值
 */
- (CGFloat)getFilterDefaultValue;

/**
 修改滤镜透明度
 @param value 透明度
 */
- (void)adjustFilterType:(BARFaceBeautyType)type value:(CGFloat)value;

/**
 自定义滤镜

 @param dic :
        @"target":@"mix_target"
        @"pass_id":@"1111"
        @"adjust_params":@"dic"
 */

- (void)adjustCustomFilter:(NSDictionary *)dic ;

/**
 获取滤镜配置信息
 @return 配置信息
 */
- (NSDictionary *)getFilterConfigsDic;

/**
 调整瘦脸关键点
 */
- (void)adjustFaceThinPoints:(NSArray *)array;

/**
 调整瘦脸关键点程度
 */
- (void)adjustFaceThinType:(BARFaceThinType)type value:(CGFloat)value;

/**
 调整使用场景 小视频/直播
 */
- (void)updateUsageScene:(BARUsageSceneType)type;

#pragma mark - 贴纸

/**
 获取人脸配置信息
 @return 配置信息
 */
- (NSDictionary *)getFaceConfigDic;

/**
 人脸算法配置信息
 @param dic @{@"faceSyncProcess":(同步/异步)，@"printLog":@"(打印/不打印)"};
 */

- (void)setFaceAlgoInfo:(NSDictionary *)dic;

/**
 清除人脸贴纸
 */
- (void)clearAssets;


/**
 设置引擎配置：0：基础AR 1：Face

 @param configurationType 默认人脸
 */
- (void)setConfigurationType:(BAROutConfigurationType)configurationType;

/**
 开启人脸算法
 */
- (void)startFaceAR;

- (void)clearFaceData;

- (void)lowDeviceStopAlgoWhenRender:(BOOL)stopEnable;

@end
