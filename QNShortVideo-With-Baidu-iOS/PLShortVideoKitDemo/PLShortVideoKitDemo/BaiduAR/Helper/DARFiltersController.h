//
//  DARFiltersController.h
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/5/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DARQueryFilterList)(NSArray *filterList);
typedef void(^DARFilterSwitch)(NSDictionary *dic);

@interface DARFiltersController : NSObject

@property (nonatomic, copy) NSArray *filtersArray;
@property (nonatomic, copy) DARFilterSwitch filterSwitchBlock;
@property (nonatomic, strong) NSString *configPath;
@property (nonatomic, strong) NSString *resourcePath;
@property (nonatomic, copy) NSDictionary *defaultFilterDict;

- (void)queryFiltersResultWithFilterPath:(NSString *)filterPath queryFinishedBlock:(DARQueryFilterList)queryFinishedBlock;

- (void)switchFilterWith:(NSInteger)index;

@end
