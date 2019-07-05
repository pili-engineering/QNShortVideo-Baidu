//
//  DARFiltersController.m
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/5/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "DARFiltersController.h"
//#import "BARModelObj.h"

@interface DARFiltersController()

@end

@implementation DARFiltersController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filtersArray = [NSArray array];
    }
    return self;
}

- (void)queryFiltersResultWithFilterPath:(NSString *)filterPath queryFinishedBlock:(DARQueryFilterList)queryFinishedBlock {
    self.resourcePath = filterPath;
    //配置路径
    NSString *configPath = [filterPath stringByAppendingPathComponent:@"res/filter_config.json"];
    self.configPath = @"res/filter_config.json";
    //配置文件内容
    NSData *filterData = [[NSData alloc] initWithContentsOfFile:configPath];
    
    NSDictionary *configDic;
    
    NSArray *filterGroup = [NSArray array];
    if (filterData) {
        configDic = [NSJSONSerialization JSONObjectWithData:filterData options:NSJSONReadingMutableLeaves error:nil];
//        self.filterMgr.startID = [dic objectForKey:@"start_filter_group_id"];
        id tempFilterGroup = [configDic objectForKey:@"filter_group_set"];
        if (tempFilterGroup && [tempFilterGroup isKindOfClass:[NSArray class]]) {
            filterGroup = tempFilterGroup;
        }
    }
    
    for (NSDictionary *filter in filterGroup) {
        NSString *filterID = [[filter objectForKey:@"filter_group_id"] stringValue];
        if ([filterID isEqualToString:@"500001"]) {
            self.defaultFilterDict = filter;
        }
    }
    
    NSArray *iconArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face_filter" ofType:@"plist"]];
    
    NSMutableArray *tempFilterArr = [NSMutableArray array];
    for(NSDictionary * iconDic in iconArr)
    {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSDictionary *filter in filterGroup) {
            NSString *filterID = [[filter objectForKey:@"filter_group_id"] stringValue];
            if ([filterID isEqualToString:[iconDic objectForKey:@"id"]]) {
                [tempDic setObject:filter forKey:@"filter"];
                [tempDic setObject:[iconDic objectForKey:@"image"] forKey:@"image"];
                [tempDic setObject:[self filterNameWithId:filterID] forKey:@"name"];
                break;
            }
        }
        [tempFilterArr addObject:tempDic];
    }
    self.filtersArray = tempFilterArr;
    if (queryFinishedBlock) {
        queryFinishedBlock(tempFilterArr);
    }
}

- (void)switchFilterWith:(NSInteger)index {
    NSDictionary *decalDic = nil;
    if (index != -1) {
        decalDic = self.filtersArray[index];
    }
    self.filterSwitchBlock(decalDic);
}

-(NSString *)filterNameWithId:(NSString *)filterId
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"filter_name" ofType:@"plist"];
    NSDictionary *theDic = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSString *filterName = [theDic objectForKey:filterId];
    if(nil == filterName)
        filterName = @"";
    return filterName;
}

@end
