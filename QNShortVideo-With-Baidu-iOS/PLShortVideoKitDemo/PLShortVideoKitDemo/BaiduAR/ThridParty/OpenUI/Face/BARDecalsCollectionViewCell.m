//
//  BARCollectionViewCell.m
//  ARAPP-FaceDemo
//
//  Created by Zhao,Xiangkai on 2018/4/10.
//  Copyright © 2018年 Zhao,Xiangkai. All rights reserved.
//

#import "BARDecalsCollectionViewCell.h"
#import "UIImage+Load.h"
#import "UIImageView+WebCache.h"
#import "DARFaceDecalsModel.h"

@interface BARDecalsCollectionViewCell()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *selectedImgView;
//@property (nonatomic, strong) UIImageView *imageViewLoading;

@property (nonatomic, strong) CABasicAnimation *loadingAnimation;

@property (nonatomic, strong) UIImageView *caseDownloadStateView;
@property (nonatomic, strong) CABasicAnimation *downloadingAnimation;
@property (nonatomic, strong) UIView *updateView;;


@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) DARFaceDecalsState state;

@end

@implementation BARDecalsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    [self buildImageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSwitchDone) name:BARSWITCHDECALSDONE object:nil];
    
}

- (void)buildImageView {
    if(self.imageView){
        return ;
    }
    {
        CGFloat imageWidth = self.contentView.bounds.size.width;
        CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageWidth);
        
        self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = imageWidth/2.0;
        
        self.imageView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"];
        [self.contentView addSubview:self.imageView];
    }
    {
        CGFloat imageWidth = self.contentView.bounds.size.width;
        CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageWidth);
        
        self.selectedImgView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.selectedImgView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_贴纸选中"];
        self.selectedImgView.hidden = YES;
        [self.contentView addSubview:self.selectedImgView];
    }
    {
//        CGFloat imageWidth = self.contentView.bounds.size.width;
//        CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageWidth);
//
//        self.imageViewLoading = [[UIImageView alloc] initWithFrame:imageFrame];
//        self.imageViewLoading.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageViewLoading.clipsToBounds = YES;
//        self.imageViewLoading.layer.cornerRadius = imageWidth/2.0;
//        self.imageViewLoading.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case加载框"];
//        [self.contentView addSubview:self.imageViewLoading];
//        self.imageViewLoading.hidden = YES;
        {
            CABasicAnimation *animation = nil;
            if(!animation) {
                animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
                animation.duration = 1.0f;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                //animation.cumulative = NO;
                animation.removedOnCompletion = NO; //No Remove
                animation.fillMode = kCAFillModeForwards;
                animation.repeatCount = FLT_MAX;
                [animation setValue:@"loadingRotation" forKey:@"loadingRotation"];
            }
            self.loadingAnimation = animation;
        }
    }
    
    {
        CGFloat imageWidth = self.contentView.bounds.size.width / 4 ;
        CGRect imageFrame = CGRectMake(3 * imageWidth, 3 * imageWidth - 4, imageWidth + 3, imageWidth + 3);
        self.caseDownloadStateView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.caseDownloadStateView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_待下载"];
        [self.contentView addSubview:self.caseDownloadStateView];
        self.caseDownloadStateView.hidden = YES;
        
    }
    
    {
        
        CGFloat contentViewWidth = self.contentView.bounds.size.width;
        CGFloat width = contentViewWidth / 8;
        CGFloat radius = width / 2;
        self.updateView = [[UIView alloc] initWithFrame:CGRectMake(contentViewWidth - width, 2, width, width) ];
        [self.updateView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.updateView];
    
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(radius , 0)];
        [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        CAShapeLayer *updateLayer = [CAShapeLayer layer];
        updateLayer.strokeColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0].CGColor;
        updateLayer.fillColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0].CGColor;
        updateLayer.lineWidth = 1;
        updateLayer.path = path.CGPath;
        [self.updateView.layer addSublayer:updateLayer];
        self.updateView.hidden = YES;
      
    }
}

- (void)setCellWithModel:(id)model {
    
    if (model && [model isKindOfClass:[DARFaceDecalsModel class]]) {
    
        DARFaceDecalsModel *faceModel = model;
        
        if (faceModel.thumbUrl.length > 0) {//网络加载缩率图
            NSURL *imageUrl = [NSURL URLWithString:faceModel.thumbUrl];
            UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:faceModel.thumbUrl];
            [self.imageView sd_setImageWithURL:imageUrl placeholderImage:cacheImage ? cacheImage : [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"]];

            
        } else {
            NSString *path ;
            if (faceModel.image.length == 0) {//itues加载缩率图
                path = faceModel.imagePath;
            } else {//本地加载缩率图
                path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:faceModel.image];
            }
            
            if (path.length == 0) {//网络资源未解析完成加载缩率图
                self.imageView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"];
            } else {
                self.imageView.image = [UIImage imageWithContentsOfFile:path];
            }
            
        }
        
        [self stopAnimation];
        
        
        if (self.state == faceModel.state) {
            return;
        }
        self.state = faceModel.state;
        
        switch (faceModel.state) {
            case DARFaceDecalsStateNone:
                {
                    self.selectedImgView.hidden = YES;
//                    self.imageViewLoading.hidden = YES;
                    self.caseDownloadStateView.hidden = YES;
                    self.updateView.hidden = YES;
                }
                break;
            case DARFaceDecalsStateUnDownload:
            {
                self.selectedImgView.hidden = YES;
//                self.imageViewLoading.hidden = YES;
                self.updateView.hidden = YES;
                self.caseDownloadStateView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_待下载"];
                self.caseDownloadStateView.hidden = NO;
            }
                break;
            case DARFaceDecalsStateDownloadDoing:
            {
                self.selectedImgView.hidden = YES;
//                self.imageViewLoading.hidden = YES;
                self.updateView.hidden = YES;
                self.caseDownloadStateView.hidden = NO;
                self.caseDownloadStateView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_loading"];
                [self startAnimation:self.caseDownloadStateView];
            }
                break;
            case DARFaceDecalsStateDownloadFail:
            {
                self.selectedImgView.hidden = YES;
//                self.imageViewLoading.hidden = YES;
                self.updateView.hidden = YES;
                self.caseDownloadStateView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_重试"];
                self.caseDownloadStateView.hidden = NO;
            }
                break;
            case DARFaceDecalsStateUpdate:
            {
                self.selectedImgView.hidden = YES;
//                self.imageViewLoading.hidden = YES;
                self.updateView.hidden = NO;
                self.caseDownloadStateView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_待下载"];
                self.caseDownloadStateView.hidden = NO;
                
            }
                break;
            case DARFaceDecalsStateLoading:
            {
                self.selectedImgView.hidden = YES;
                self.caseDownloadStateView.hidden = YES;
//                self.imageViewLoading.hidden = NO;
                self.updateView.hidden = YES;
//                [self startAnimation:self.imageViewLoading];
            }
                break;
            case DARFaceDecalsStateSelected:
            {
                self.selectedImgView.hidden = NO;
//                self.imageViewLoading.hidden = YES;
                self.updateView.hidden = YES;
                self.caseDownloadStateView.hidden = YES;
            }
                break;
            default:
                break;
        }

    }
}

- (void)updateImageUrl:(NSString *)url{
    if ([url hasPrefix:@"http"]) {
//        UIImage * holderImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_case缺省图"];
//        if([url length]) {
//            [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:holderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                if(error){
//                    NSLog(@"url :%@\nerror:%@ ",imageURL,error);
//                }
//                if(!image){
//                    NSLog(@"url :%@\nerror:%@ imageisnull",imageURL,error);
//                }
//            }];
//        }else{
//            [self.imageView sd_cancelCurrentImageLoad];
//        }
    }else{
        self.imageView.image = [UIImage imageNamed:url];
    }
    
}

- (void)resetStatus {
    [self stopAnimation];
    self.selectedImgView.hidden = YES;
}

- (void)resumeAnimationWith:(BOOL)resume {
    if (resume) {
        [self startAnimation];
    } else {
        self.selectedImgView.hidden = NO;
    }
}

- (void)startAnimation:(UIImageView *)imageView {
    self.isAnimationing = YES;
    [self startLoadingAnimation:imageView];
}

- (void)stopAnimation {
    if (self.isAnimationing) {
//        self.imageViewLoading.layer.speed = 0.0;
//        [self.imageViewLoading.layer removeAllAnimations];
        self.caseDownloadStateView.layer.speed = 0.0;
        [self.caseDownloadStateView.layer removeAllAnimations];
        self.isAnimationing = NO;
//        self.imageViewLoading.hidden = YES;
//        self.selectedImgView.hidden = NO;
        self.caseDownloadStateView.hidden = YES;
    }
}

- (void)handleSwitchDone {
    [self stopAnimation];
}

#pragma mark - 加载动画
- (void)startLoadingAnimation:(UIImageView *) imageView{
    imageView.hidden = NO;
    CABasicAnimation *animation = (CABasicAnimation *)[imageView.layer animationForKey:@"loadingRotation"];
    if(animation){
        [imageView.layer removeAllAnimations];
    }
    [imageView.layer addAnimation:self.loadingAnimation forKey:@"loadingRotation"];
    imageView.layer.speed = 1.0;
}

- (void)setLandscapeMode:(UIDeviceOrientation)direction {
    self.deviceOrientation = direction;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat angle = 0;
        if(self.deviceOrientation == UIDeviceOrientationLandscapeLeft){
            angle = M_PI/2;
        }else if(self.deviceOrientation == UIDeviceOrientationLandscapeRight){
            angle = -(M_PI/2);
        }else{
            angle = 0;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(angle);
        }];
    });
}

@end
