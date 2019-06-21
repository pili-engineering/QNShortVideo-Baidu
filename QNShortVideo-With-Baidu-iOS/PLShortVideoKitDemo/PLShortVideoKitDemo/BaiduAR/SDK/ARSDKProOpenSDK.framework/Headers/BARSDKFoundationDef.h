//
//  BARSDKFoundationDef.h
//  BARSDKBaseFoundation
//
//  Created by yijieYan on 2018/8/30.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#ifndef BARSDKFoundationDef_h
#define BARSDKFoundationDef_h
#import "BARSDKObj.h"
#import "BARSDKDef.h"


typedef NS_ENUM(NSInteger,BARFunctionType) {
    BARFunctionTypeUnknown = 0,
    BARFunctionTypeSlam = 101,//Slam
    BARFunctionType2DTrack ,//2D跟踪
    BARFunctionTypeLocalSameSearch,//本地识图
    BARFunctionTypeCloudSameSearch,//云端识图
    BARFunctionTypeGestureRecognition,//手势识别
    BARFunctionTypeBodyRecognition,//肢体识别
};

//typedef NS_ENUM(NSInteger,BARBARAlgoType) {
//    kBARTypeUnkonw = -1,
//    kBARTypeTracking = 0,
//    kBARTypeSlam = 5,
//    kBARTypeLocalSameSearch = 6,
//    kBARTypeCloudSameSearch = 7,
//    kBARTypeIMU = 8,
//    kBARTypeARKit = 9,
//};
#define BARBARAlgoType kBARType

//typedef NS_ENUM(NSInteger,BARImageSearchError) {
//    BARImageSearchError_UnKnown = -1,
//    BARImageSearchError_NetWrong = -101,//网络失败
//    BARImageSearchError_DataWrong = -102, //鉴权等
//    BARImageSearchError_DownLoadFeaWrong = -103, //下载特征库失败
//    BARImageSearchError_ImageSearchTimeout = -104, //识别超时
//};

////语音识别UI
//typedef NS_ENUM(NSInteger, BARVoiceUIState) {
//    BARVoiceUIState_ShowLoading,
//    BARVoiceUIState_StopLoading,
//    BARVoiceUIState_ShowWave,
//    BARVoiceUIState_StopWave,
//    BARVoiceUIState_WaveChangeVolume,
//    BARVoiceUIState_ShowTips,
//    BARVoiceUIState_HideVoice
//};


#endif /* BARSDKFoundationDef_h */
