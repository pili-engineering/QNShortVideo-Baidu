//
//  BARBusinessViewController.h
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/7/5.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^BARFaceBVCDisappear)(void);

@interface RecordViewController : UIViewController
@property (nonatomic, copy) NSString *plistPath;
@property (nonatomic, assign) BOOL disableDebugInfo;
@property (nonatomic, copy) NSDictionary *faceAlgoModelDic;
@property (nonatomic, assign) BOOL autoInOutAR;
@property (nonatomic, copy) BARFaceBVCDisappear disappearBlock;
@property (nonatomic, assign) BOOL cameraToAR;
@end
