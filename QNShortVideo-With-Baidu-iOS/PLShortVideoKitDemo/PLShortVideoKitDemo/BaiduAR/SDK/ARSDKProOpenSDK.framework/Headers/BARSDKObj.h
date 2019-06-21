//
//  BARProSDKObj.h
//  ARSDK-Pro
//
//  Created by yijieYan on 2017/10/21.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#ifndef BARSDKObj_h
#define BARSDKObj_h

typedef NS_ENUM(NSInteger,BARSDKUIState) {
    BARSDKUIState_UnKnown = -1,
    BARSDKUIState_TrackOn,
    BARSDKUIState_TrackLost_HideModel,
    BARSDKUIState_TrackLost_ShowModel,
    BARSDKUIState_TrackTimeOut,
    BARSDKUIState_DistanceNormal,
    BARSDKUIState_DistanceTooFar,
    BARSDKUIState_DistanceTooNear,
    BARSDKUIState_TipShow,
    BARSDKUIState_TipHide,
    BARSDKUIState_ShowRecordUI,
    BARSDKUIState_Enanle_Front_Camera,
    BARSDKUIState_Case_Initial_Click,
    BARSDKUIState_SetNativeUI_Visible,
    BARSDKUIState_Change_FrontBack_Camera,
    /*
      BARSDKUIState_Enanle_Front_Camera                   // 开启前置摄像头
     
      BARSDKUIState_Initial_Click                         // 引导页点击事件
      BARSDKUIState_View_Visible_Type                     // UI显示的类型
     */
};

typedef NS_ENUM(NSInteger,BARSDKShowAlertType) {
    BARSDKShowAlertType_UnKnown = -1,
    BARSDKShowAlertType_NetWrong,
    BARSDKShowAlertType_SDKVersionTooLow,
    BARSDKShowAlertType_Unsupport,
    BARSDKShowAlertType_ARError,
    BARSDKShowAlertType_BatchZipDownloadFail,
    BARSDKShowAlertType_ARError_OnlyNeedReturn,
    BARSDKShowAlertType_BARImageSearchError_NetWrong,               // 网络失败
    BARSDKShowAlertType_BARImageSearchError_DataWrong,              // 鉴权等
    BARSDKShowAlertType_BARImageSearchError_DownLoadFeaWrong,       // 下载特征库失败
    BARSDKShowAlertType_BARImageSearchError_ImageSearchTimeout,     // 识别超时
    BARSDKShowAlertType_BARLogoRecogError_NetWrong,                 // Logo识别网络失败
    BARSDKShowAlertType_LuaInvokeSDKAlert,                          // lua主动调起sdk的弹窗
    BARSDKShowAlertType_LuaInvokeSDKToast,                           // lua主动调起sdk的toast
    BARSDKShowAlertType_AuthenticationError,              // 启动AR，鉴权失败
    BARSDKShowAlertType_CaseVersion_Error,              // case版本与SDK版本不对称
};

/*
typedef NS_ENUM(NSInteger,BARQueryAndDownLoadCaseState) {
    BARCaseStateUnKnown = -1,
    BARCaseStateQueryStart,
    BARCaseStateQueryCompleted,
    BARCaseStateDownloadStart,
    BARCaseStateDownloadComplete,
    BARCaseStateUnzipStart,
    BARCaseStateUnzipComplete,
};*/

//typedef NS_ENUM(NSInteger,BARRenderState) {
//    BARRenderStateUnKnown = -1,
//    BARRenderStateNone,
//    BARRenderStateActived,
//    BARRenderStatePaused,
//};

typedef NS_ENUM(NSInteger,BARSDKStateError) {
    BARSDKStateError_UnKnown = -1,
    BARSDKStateError_NetWrong,
    BARSDKStateError_SDKVersionTooLow,
    BARSDKStateError_Unsupport,
    BARSDKStateError_ARError,
};

typedef NS_ENUM(NSInteger,BARImageSearchError) {
    BARImageSearchError_UnKnown = -1,
    BARImageSearchError_NetWrong = -101,//网络失败
    BARImageSearchError_DataWrong = -102, //鉴权等
    BARImageSearchError_DownLoadFeaWrong = -103, //下载特征库失败
    BARImageSearchError_ImageSearchTimeout = -104, //识别超时
};

//语音识别UI
typedef NS_ENUM(NSInteger, BARVoiceUIState) {
    BARVoiceUIState_ShowLoading,
    BARVoiceUIState_StopLoading,
    BARVoiceUIState_ShowWave,
    BARVoiceUIState_StopWave,
    BARVoiceUIState_WaveChangeVolume,
    BARVoiceUIState_ShowTips,
    BARVoiceUIState_HideVoice
};

typedef NS_ENUM(NSInteger , BARFaceBeautyType) {
    BARFaceBeautyTypeWhiten,
    BARFaceBeautyTypeSkin,
    BARFaceBeautyTypeEye,
    BARFaceBeautyTypeThinFace,
    BARFaceBeautyTypeNormalFilter,
    BARFaceBeautyTypeUnKnow
};

typedef NS_ENUM(NSInteger, BARFaceThinType) {
    //降低嘴巴的大小变化幅度，BARFaceThinTypeChinLeftAndRight作用最大
    BARFaceThinTypeChin, //下巴拉伸程度 默认0.9
    BARFaceThinTypeFaceLeftAndRight, //人脸拉伸程度 默认0.96
    BARFaceThinTypeChinLeftAndRight, //下巴靠上点的拉伸幅度 默认0.9
    BARFaceThinTypeChinLeftAndRightLower, //下巴靠下点的拉伸幅度 默认0.95
    BARFaceThinTypeChinRadius, //下巴拉伸作用半径 默认1.5
    BARFaceThinTypeChinCloseRadius, //下巴靠下点的作用半径 默认1.2
    BARFaceThinTypeChinUpRadius  //下班靠上点的作用半径 默认1.2
};

typedef enum : NSUInteger {
    BARUsageSceneTypeSmallVideo,   //小视频
    BARUsageSceneTypeStream        //直播
} BARUsageSceneType;

typedef void(^BARSDKUIStateEventBlock) (BARSDKUIState state,NSDictionary *info);

typedef void(^BARUpdateSLAMPos) (GLKMatrix4 rtMatrix);
typedef void(^BARUpdateIMUPos) (GLKMatrix4 rtMatrix);
typedef void(^BARUpdateTrackingPos) (GLKMatrix4 rtMatrix);
typedef void(^BAROnTackOnEventBlock)(void);
typedef void(^BAROnTackLostEventBlock)(void);

typedef float*(^BARGetCameraPos)(void);
typedef void(^BARRotateSceneToCameraBlock)(void);
typedef void(^BARsetWorldPosiotionToZeroBlock)(void);
typedef void(^BARSceneRelocateBlock)(void);


@interface BARSDKDownLoadObj : NSObject
@property (nonatomic,copy)NSString *err_code;
@property (nonatomic,copy)NSString *err_msg;
@property (nonatomic,copy)NSString *help_url;
@property (nonatomic,assign)BARSDKStateError error_state;
@end

@interface BARSDKObj : NSObject

@end
#endif
