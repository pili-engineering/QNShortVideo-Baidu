//
//  BARLightsView.m
//  ARSDK
//
//  Created by 雪岑申 on 2017/3/6.
//  Copyright © 2017年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import "BARLightsView.h"
#import "BARFaceUtil.h"
#import "UIImage+BARLoad.h"


#define LIGHT_UNIT_WIDTH 15.f
#define LIGHT_UNIT_HEIGHT 18.f
#define LIGTH_UNIT_GAP 20.f

@interface BARLightsView()
@property (strong, nonatomic) NSArray* lights;
@end

@implementation BARLightsView

- (id)init:(NSInteger)num{
    self = [super initWithFrame:CGRectMake(0, 0, (num - 1) * LIGTH_UNIT_GAP + LIGHT_UNIT_WIDTH, LIGHT_UNIT_HEIGHT)];
    if (self) {
        [self setup:num];
    }
    return self;
}

- (void)lightUp:(NSInteger)lights {
    for (int i = 0; i < [self.lights count]; i++) {
        UIImageView *light = [self.lights objectAtIndex:i];
        if (i < lights) {
            light.image = [self imageLigth];
        } else {
            light.image = [self imageDark];
        }
    }
}

- (void)setup:(NSInteger)num {
    NSMutableArray* lights = [NSMutableArray array];
    self.backgroundColor = [UIColor clearColor];
    for (int i = 0; i < num; i++) {
        UIView* light = [self ligth];
        light.layer.position = CGPointMake(LIGTH_UNIT_GAP * i + LIGHT_UNIT_WIDTH/2, LIGHT_UNIT_HEIGHT/2);
        [lights addObject:light];
        [self addSubview:light];
    }
    self.lights = [lights copy];
}

- (UIImageView *)ligth{
    UIImageView* light = [[UIImageView alloc] initWithImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_灯_灭"]];
    return light;
}

- (UIImage *)imageLigth {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_灯_亮"];
}

- (UIImage *)imageDark {
    return [UIImage imageWithContentOfFileForBAR:@"BaiduAR_灯_灭"];
}
@end
#endif
