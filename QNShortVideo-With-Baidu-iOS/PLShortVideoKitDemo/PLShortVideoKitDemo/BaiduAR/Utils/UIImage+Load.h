//
//  UIImage+BARLoad.h
//  ARSDK
//
//  Created by liubo on 26/07/2017.
//  Copyright © 2017 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BARLoad)
+ (UIImage *) imageNamedForBAR:(NSString *)name;
+ (UIImage *) imageWithContentOfFileForBAR:(NSString *)name;
@end
