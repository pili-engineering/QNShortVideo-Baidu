//
//  BARShareViewController.h
//  ARSDK
//
//  Created by LiuQi on 16/9/21.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BARShareViewControllers : UIViewController

typedef void (^BARShareViewClickEventBlock)(NSString* url);
typedef void (^BARShareImageUrlBlock)(NSString* title, NSString* description, UIImage* thumbImg, NSString* url);

typedef void (^BAROpenSDKViewControllerShareBlock)(NSString* title, NSString* description, UIImage* thumbImg, NSString* h5Url,NSInteger shareType,NSString *videoOrImageUrl);

@property (nonatomic, copy) BARShareViewClickEventBlock clickEventBlock;
@property (nonatomic, copy) BARShareImageUrlBlock shareUrlBlock;
@property (nonatomic, copy) BAROpenSDKViewControllerShareBlock opensdkShareBlock;

@property (nonatomic, copy) NSString *arkey;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, assign) CGFloat angle;


- (id)initWithImage:(UIImage*)img;
- (id)initWithVideoPath:(NSString *)path;

@end
