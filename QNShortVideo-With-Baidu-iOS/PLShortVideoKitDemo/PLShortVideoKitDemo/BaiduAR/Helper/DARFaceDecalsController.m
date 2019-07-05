//
//  DARFaceDecalsController.m
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/5/9.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "DARFaceDecalsController.h"
#import "ZipArchive.h"
#include <CommonCrypto/CommonDigest.h>
#import "AFHTTPSessionManager.h"

#define GETARFACELISURL @"http://duar.baidu.com/recommend/GetArFaceList"// @"http://hz01-ar-server01.hz01.baidu.com:8669/recommend/GetArFaceList"//测试环境 线上环境 http://duar.baidu.com/recommend/GetArFaceList

@interface DARFaceDecalsController()

@property (nonatomic, weak) NSURLSessionTask *queryDecalsTask;
@property (nonatomic, strong) NSString *arfacePath;
@end

@implementation DARFaceDecalsController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.decalsArray = [NSArray array];
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        self.arfacePath = [libraryPath stringByAppendingPathComponent:@"baiduarface"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:self.arfacePath isDirectory:nil]){
            
            [fileManager createDirectoryAtPath:self.arfacePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

-(void)dealloc {
    if (self.queryDecalsTask) {
        [self.queryDecalsTask cancel];
        self.queryDecalsTask = nil;
    }
}

- (void)queryDecalsListWithFinishedBlock:(DARQueryDecalsList)queryFinishedBlock {
    self.queryDecalsListBlock = queryFinishedBlock;
    
    if(NO)
    {
        
     //原来的走读取本地case的逻辑，先注释掉
        NSArray *tempDecalsArray = [NSArray arrayWithContentsOfFile:self.plistPath];

        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:tempDecalsArray.count];
        NSMutableArray *tempModelsArray = [NSMutableArray array];

        for (int i = 0; i < tempDecalsArray.count; i++) {

            NSMutableDictionary *dict = [[tempDecalsArray objectAtIndex:i] mutableCopy];
            DARFaceDecalsModel *model = [DARFaceDecalsModel modelWithDic:dict];
            [tempModelsArray addObject:model];

            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[dict objectForKey:@"name"] ofType:@"bundle"];
            if(bundlePath){
                [dict setObject:bundlePath forKey:@"name"];
                [tempArr addObject:dict];
            }
            else{
                NSLog(@"找不到%@.bundle",[dict objectForKey:@"name"]);
            }
        }
        self.decalsArray = tempModelsArray;
        if (queryFinishedBlock) {
            queryFinishedBlock(self.decalsArray);
        }
        return;
    }
    
    NSMutableArray *tempModelsArray = [NSMutableArray array];
    NSURLSessionDataTask *dataTask;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[NSNumber numberWithInt:3] forKey:@"os_type"];
    [param setObject:@"240" forKey:@"sdk_version"];
    dispatch_queue_t queue = dispatch_queue_create("findDecalsList", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    //开始下载case,先去读取平台case
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:GETARFACELISURL parameters:param progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //放到子线程，修改进入相机黑屏时间较上一版本变长的问题
        dispatch_async(queue, ^{
          
            NSMutableArray *dataArray = [[responseObject valueForKey:@"data"] mutableCopy];
            
            for (int i = 0; i < dataArray.count; i ++) {
                if ([dataArray[i] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = dataArray[i];
                    DARFaceDecalsModel *model = [self analysisModelWithDic:dic];
                    
                    [tempModelsArray addObject:model];
                }
            }
            self.decalsArray = tempModelsArray;
            if (queryFinishedBlock) {
                queryFinishedBlock(self.decalsArray);
            }
            
            dispatch_group_leave(group);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];


//再去读取ituns分享case
    
    dispatch_group_notify(group, queue, ^{
        [self findDecalsListFromDocumentPath:tempModelsArray];

    });


//    self.decalsArray = tempModelsArray;
//    if (queryFinishedBlock) {
//        queryFinishedBlock(self.decalsArray);
//    }
}

-(void)findDecalsListFromDocumentPath:(NSMutableArray *)tempModelsArray{
    
    NSMutableArray *documentArray = [tempModelsArray mutableCopy];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *removeItemError = nil;
    NSString *arPathAppendAr = [documentPath stringByAppendingPathComponent:@"facear"];
    //有facear文件就先删除
    if([fileManager fileExistsAtPath:arPathAppendAr isDirectory:nil]){
        [fileManager removeItemAtPath:arPathAppendAr error:&removeItemError];
        
    }
    
    /*开始遍历所有zip文件 并解压到facear文件夹下*/
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:documentPath];
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        
        if ([[filePath pathExtension] isEqualToString:@"zip"]) {
            BOOL done = [SSZipArchive unzipFileAtPath:[documentPath stringByAppendingPathComponent:filePath] toDestination:arPathAppendAr];
            if (!done) {
                NSLog(@"DecalsList unzip fail!");
            }
        }
      
        
    }
    /*遍历所有zip文件---结束*/
    
    /*开始遍历所有case文件 */
    NSDirectoryEnumerator *enumeratorDecals = [fileManager enumeratorAtPath:arPathAppendAr];
    
    NSString *decalsPath;
    
    while ((decalsPath = [enumeratorDecals nextObject]) != nil) {
        
        if([[decalsPath pathExtension] isEqualToString:@"bundle"]){
            
            DARFaceDecalsModel *model = [[DARFaceDecalsModel alloc] init];
            BOOL extraError = YES;
            
            //获取case配置的参数 artype 和默认图片
            NSString *namePath = [arPathAppendAr stringByAppendingPathComponent:decalsPath];
            NSString *extraPath = [namePath stringByAppendingPathComponent:@"case_extra"] ;
            
            if ([fileManager fileExistsAtPath:extraPath isDirectory:nil]) {
                NSError * error = nil;
                NSArray * extraContents = [fileManager subpathsOfDirectoryAtPath:extraPath error:&error];
                
                if (error) {
                   
                } else {
                    for (NSString * name in extraContents) {
                        NSString * fullPath = [extraPath stringByAppendingPathComponent:name];
                        
                        BOOL isDir;
                        
                        [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
                        if (isDir) {
                            continue;
                        }
                        NSString * extension = [fullPath pathExtension];
                        
                        if ([extension isEqualToString:@"png"]) {
                            model.imagePath = fullPath;
                        }
                        
                        if ([extension isEqualToString:@"json"]) {
                            NSData *data = [[NSData alloc] initWithContentsOfFile:fullPath];
                            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            
                            if (dic) {
                                model.type = [dic valueForKey:@"artype"];
                            }
                            
                        }
                    }
                    
                    model.name = namePath;
                    
                    if (model.imagePath.length == 0) {
                        model.image = @"face";
                        
                    }
                    
                    if (model.type.length == 0) {
                        model.type = @"10";
                    }
                    
                    extraError = NO;
                }
                
            }
            if (extraError) {
                model.name = namePath;
                model.image = @"face";
                model.type = @"10";
            }
            model.state = DARFaceDecalsStateNone;
            
            [documentArray addObject:model];
        }
    }
    /*遍历所有case文件---结束 */
    if (documentArray.count > self.decalsArray.count) {//有变化去更新
        self.decalsArray = documentArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.updateDecalsArray();
        });
        
    }
    
}

- (void)switchDecalWithIndex:(NSInteger)index {
    DARFaceDecalsModel *model = nil;
    if (index != -1) {
        model = self.decalsArray[index];
    }
    self.decalsSwitchBlock(model);
}

- (DARFaceDecalsModel *)analysisModelWithDic:(NSDictionary *)dic{
    DARFaceDecalsModel *model = [[DARFaceDecalsModel alloc] init];
    
    model.arkey = [dic valueForKey:@"id"];
    model.resourceUrl = [dic valueForKey:@"resource_url"];
    model.thumbUrl = [dic valueForKey:@"thumb_url"];
    model.name = [self.arfacePath stringByAppendingPathComponent:[dic valueForKey:@"id"]];
    model.resourceMd5 = [dic valueForKey:@"resource_md5"];
    model.state = [self caseExist:[dic valueForKey:@"id"] case_md5:[dic valueForKey:@"resource_md5"]];
    model.type = [dic valueForKey:@"ar_type"];
    
    
    return model;
}

- (DARFaceDecalsState)caseExist:(NSString *)caseID case_md5:(NSString *)case_md5{
    if (caseID.length == 0 || case_md5 .length == 0) {
        return DARFaceDecalsStateUnDownload;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *casePath = [self.arfacePath stringByAppendingPathComponent:caseID];

    if(![fileManager fileExistsAtPath:casePath isDirectory:nil]){
        return DARFaceDecalsStateUnDownload;
    }
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:casePath];
    
    NSString *filePath;
    BOOL caseExist = NO;
    BOOL caseUpdate = NO;
    while ((filePath = [enumerator nextObject]) != nil){
        if ([[filePath pathExtension] isEqualToString:@"zip"]) {
            NSString *zipPath = [casePath stringByAppendingPathComponent:filePath];
            if ([case_md5 isEqualToString:[self md5HashOfPath:zipPath]]) {
                //ar目录不存在：解压失败 || 未解压
                if ([[NSFileManager defaultManager] fileExistsAtPath:[casePath stringByAppendingPathComponent:@"ar"]]) {
                    caseExist = YES;
                }else {
                    caseExist = NO;
                }
            } else {
                caseUpdate = YES;
            }
            
        }
    }
    //先去判断有没有
    if (caseExist) {
        return DARFaceDecalsStateNone;
    }
    
    if (caseUpdate) {
        return DARFaceDecalsStateUpdate;
    }
    
    return DARFaceDecalsStateUnDownload;
}


- (NSString *)md5HashOfPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Make sure the file exists
    if([fileManager fileExistsAtPath:path isDirectory:nil]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    } else {
        return @"";
    }
}

@end
