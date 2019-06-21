//
//  DarFaceAlgoModleParse.m
//  ARAPP-OpenStandard
//
//  Created by Yan,Yijie on 2018/11/12.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "DarFaceAlgoModleParse.h"


@interface DarFaceAlgoModleParse()
@property (nonatomic, strong)NSDictionary *modelDic;
@property (nonatomic, strong)NSString *bundlePath;
@end

@implementation DarFaceAlgoModleParse

- (instancetype)init{
    self = [super init];
    [self loadFaceAlgoData];
    return self;
}

- (void)loadFaceAlgoData{
    
    NSString *jsonPath = [[[NSBundle mainBundle] pathForResource:@"faceAlgoResources" ofType:@"bundle"] stringByAppendingPathComponent:@"face_algo_config.json"];
    
    self.bundlePath = [[NSBundle mainBundle] pathForResource:@"faceAlgoResources" ofType:@"bundle"];
    
    if(jsonPath){
        NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if(dic){
                self.modelDic = dic;
            }
        }
    }
}

- (NSString *)detectPath{
    return [self.bundlePath stringByAppendingPathComponent:self.modelDic[@"detect_modle"]];
}

- (NSString *)modelInfoWithDeviceType:(NSInteger)deviceType key:(NSString *)key{
    
    NSString *deviceModle = @"heavy_device_modle";
    if(0 == deviceType){
        deviceModle = @"lite_device_modle";
    }
    else if(1 == deviceType){
        deviceModle = @"medium_device_modle";
    }
    return self.modelDic[deviceModle][key];
}

- (NSString *)trackingSmoothAlpha:(NSInteger )deviceType{
    
    return [self modelInfoWithDeviceType:deviceType key:@"trackingSmoothAlpha"] ? :@"";
}

- (NSString *)trackingSmoothThreshold:(NSInteger )deviceType{
    
    return [self modelInfoWithDeviceType:deviceType key:@"trackingSmoothThreshold"] ? :@"";
}


- (NSArray *)trackPaths:(NSInteger )deviceType{
    
    NSString *path0 = [self modelInfoWithDeviceType:deviceType key:@"track_param_0"] ? : @"";
    NSString *path1 = [self modelInfoWithDeviceType:deviceType key:@"track_param_1"] ? : @"";
    NSString *path2 = [self modelInfoWithDeviceType:deviceType key:@"track_param_2"] ? : @"";
    
    if(path0.length>0){
        path0 = [self.bundlePath stringByAppendingPathComponent:path0];
    }
    if(path1.length>0){
        path1 = [self.bundlePath stringByAppendingPathComponent:path1];
    }
    if(path2.length>0){
        path2 = [self.bundlePath stringByAppendingPathComponent:path2];
    }
    NSArray *array = @[path0,path1,path2];
    return array;
}

- (NSString *)imbinPath{
    return [self.bundlePath stringByAppendingPathComponent:self.modelDic[@"imbin"] ];
}


@end
