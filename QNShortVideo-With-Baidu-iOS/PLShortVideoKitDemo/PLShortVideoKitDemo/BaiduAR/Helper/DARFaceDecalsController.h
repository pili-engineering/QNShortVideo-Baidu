//
//  DARFaceDecalsController.h
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/5/9.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DARFaceDecalsModel.h"

typedef void(^DARQueryDecalsList)(NSArray *decalsList);
typedef void(^DARDecalsSwitch)(DARFaceDecalsModel *model);

@interface DARFaceDecalsController : NSObject

@property (nonatomic, copy) DARQueryDecalsList queryDecalsListBlock;
@property (nonatomic, copy) DARDecalsSwitch decalsSwitchBlock;
@property (nonatomic, copy) dispatch_block_t updateDecalsArray;
@property (nonatomic, copy) NSArray *decalsArray;
@property (nonatomic, copy) NSString *plistPath;

- (void)queryDecalsListWithFinishedBlock:(DARQueryDecalsList)queryFinishedBlock;
- (void)switchDecalWithIndex:(NSInteger)index;

@end
