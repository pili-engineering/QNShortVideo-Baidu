//
//  DARFaceDecalsModel.h
//  ARAPP-OpenStandard
//
//  Created by Asa on 2018/10/11.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DARFaceDecalsState) {
    DARFaceDecalsStateNone = 0,
    DARFaceDecalsStateUnDownload,
    DARFaceDecalsStateDownloadDoing,
    DARFaceDecalsStateDownloadFail,
    DARFaceDecalsStateUpdate,
    DARFaceDecalsStateLoading,
    DARFaceDecalsStateSelected,
};

NS_ASSUME_NONNULL_BEGIN

@interface DARFaceDecalsModel : NSObject

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *thumbUrl;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *arkey;
@property (nonatomic, copy) NSString *resourceUrl;
@property (nonatomic, copy) NSString *resourceMd5;

@property (nonatomic, assign) DARFaceDecalsState state;

+ (DARFaceDecalsModel *)modelWithDic:(NSDictionary *)dic;
- (NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
