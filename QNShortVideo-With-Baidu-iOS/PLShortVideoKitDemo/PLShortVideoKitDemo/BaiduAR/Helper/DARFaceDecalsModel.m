//
//  DARFaceDecalsModel.m
//  ARAPP-OpenStandard
//
//  Created by Asa on 2018/10/11.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "DARFaceDecalsModel.h"

@implementation DARFaceDecalsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.type = @"";
        self.arkey = @"";
        self.thumbUrl = @"";
        self.resourceUrl = @"";
        self.resourceMd5 = @"";
    }
    return self;
}

+ (DARFaceDecalsModel *)modelWithDic:(NSDictionary *)dic {
    DARFaceDecalsModel *model = [[DARFaceDecalsModel alloc] init];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[dic objectForKey:@"name"] ofType:@"bundle"];
        model.name = bundlePath;
        model.image = dic[@"image"];
        model.type = dic[@"type"];
        model.arkey = dic[@"arkey"];
    }
    model.state = DARFaceDecalsStateNone;
    return model;
    
}

- (NSDictionary *)dic {
    return @{@"name":self.name?:@"",
             @"type":self.type?:@"",
             @"arkey":self.arkey?:@""
             };
}

@end
