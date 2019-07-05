//
//  DarFaceAlgoModleParse.h
//  ARAPP-OpenStandard
//
//  Created by Yan,Yijie on 2018/11/12.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DarFaceAlgoModleParse : NSObject

- (NSString *)detectPath;

- (NSArray *)trackPaths:(NSInteger )deviceType;

- (NSString *)trackingSmoothAlpha:(NSInteger )deviceType;

- (NSString *)trackingSmoothThreshold:(NSInteger )deviceType;

- (NSString *)imbinPath;

@end

NS_ASSUME_NONNULL_END
