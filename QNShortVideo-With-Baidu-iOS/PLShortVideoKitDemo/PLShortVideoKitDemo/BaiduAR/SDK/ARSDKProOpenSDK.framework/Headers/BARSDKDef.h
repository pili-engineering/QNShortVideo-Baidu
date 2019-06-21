//
//  BARSDKDef.h
//  ARSDKPro
//
//  Created by liubo on 27/02/2018.
//  Copyright © 2018 Baidu. All rights reserved.
//

#ifndef BARSDKDef_h
#define BARSDKDef_h

typedef enum {
    kBARTypeUnkonw = -1,
    kBARTypeTracking = 0,
    kBARTypeSlam = 5,
    kBARTypeLocalSameSearch = 6,
    kBARTypeCloudSameSearch = 7,
    kBARTypeIMU = 8,
    kBARTypeARKit = 9,
    kBARTypeFace= 10,

} kBARType;

#define kARKitSceneCameraFiledOfView (60.0f)
#define kARNormalSceneCameraFiledOfView (56.1449776f)

#endif /* BARSDKDef_h */
