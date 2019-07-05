//
//  BARBaseImageVideoSwtichView.m
//  ARSDK
//
//  Created by liubo on 13/03/2017.
//  Copyright © 2017 Baidu. All rights reserved.
//

#import "BARBaseImageVideoSwitchView.h"
#import "BARFaceUtil.h"
#import "UIImage+Load.h"

@interface BARBaseImageVideoSwitchView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftToRightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightToLeftSwipe;
@property (nonatomic, strong) UIButton *takePictureButton;
@property (nonatomic, strong) UIButton *shootVideoButton;
@end

@implementation BARBaseImageVideoSwitchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void) customInit {
//    if(!self.bgImageView) {
//        UIImage *bgImage = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_拍屏视频_背景"];
//        self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.bgImageView.clipsToBounds = YES;
//        self.bgImageView.image = bgImage;
//        [self addSubview:self.bgImageView];
//    }
    
    UIFont * font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    if(font){
        font = [UIFont systemFontOfSize:14];
    }
    
    if(!self.leftToRightSwipe){
        self.leftToRightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftToRightAction:)];
        self.leftToRightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        self.leftToRightSwipe.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:self.leftToRightSwipe];
    }
    if (!self.rightToLeftSwipe){
        self.rightToLeftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightToLeftAction:)];
        self.rightToLeftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        self.rightToLeftSwipe.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:self.rightToLeftSwipe];
    }
    if(!self.takePictureButton){
        self.takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.takePictureButton setTitle:BARNSLocalizedString(@"录制") forState:UIControlStateNormal];
        [self.takePictureButton.titleLabel setFont:font];
        [self.takePictureButton addTarget:self action:@selector(takePictureActon:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.takePictureButton];
        
        self.takePictureButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.takePictureButton.layer.shadowOpacity = 0.4;
        self.takePictureButton.layer.shadowRadius = 3;
        self.takePictureButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);

    }
    if(!self.shootVideoButton){
        self.shootVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shootVideoButton setTitle:BARNSLocalizedString(@"拍照") forState:UIControlStateNormal];
        [self.shootVideoButton.titleLabel setFont:font];
        [self.shootVideoButton addTarget:self action:@selector(shootVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shootVideoButton];
        
        self.shootVideoButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shootVideoButton.layer.shadowOpacity = 0.4;
        self.shootVideoButton.layer.shadowRadius = 3;
        self.shootVideoButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        
    }
    self.isForFirst = YES;
    [self layoutPictureVideoButton:YES];

}

- (void) layoutPictureVideoButton:(BOOL) forPiture {
    
    CGFloat leftOffset = 0;
    CGFloat viewWidth = self.bounds.size.width;
//    CGFloat ViewHeight = self.bounds.size.height;
    
    CGFloat buttonWidth = 30+32;
    CGFloat buttonHeight = 27 ;
    CGFloat buttonInterval = 1;
    CGFloat buttonY = self.bounds.size.height - buttonHeight  ;

    if(forPiture) {
        leftOffset = viewWidth/2.0 - buttonWidth /2.0;
    }else{
        leftOffset = viewWidth/2.0 - buttonWidth/2.0 - buttonInterval - buttonWidth;
    }    
    CGRect pictureRect = CGRectMake(leftOffset, buttonY, buttonWidth, buttonHeight);
    CGRect videoRect = CGRectMake( leftOffset + buttonWidth + buttonInterval , buttonY, buttonWidth, buttonHeight);
    
    self.takePictureButton.frame = pictureRect;
    CGFloat insetOffset = 6;
    self.takePictureButton.titleEdgeInsets = UIEdgeInsetsMake(-1 * insetOffset, 0, insetOffset, 0);
    self.shootVideoButton.frame = videoRect;
    self.shootVideoButton.titleEdgeInsets = UIEdgeInsetsMake(-1 * insetOffset, 0, insetOffset, 0);
    
    UIColor *selectedColor = [UIColor whiteColor];
    UIColor *unselectedColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    [self.takePictureButton setTitleColor:forPiture?selectedColor:unselectedColor forState:UIControlStateNormal];
    [self.shootVideoButton setTitleColor:!forPiture?selectedColor:unselectedColor forState:UIControlStateNormal];
}


-(void) takePictureActon:(id) sender {
    if([self.delegate respondsToSelector:@selector(imageVideoSwitchDoingAnimation:)]){
        [self.delegate imageVideoSwitchDoingAnimation:YES];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutPictureVideoButton:YES];
    } completion:^(BOOL finished) {
        [self onSwitchedToFirst:YES];
    }];
    
}

- (void)shootVideoAction:(id) sender {
    if([self.delegate respondsToSelector:@selector(imageVideoSwitchDoingAnimation:)]){
        [self.delegate imageVideoSwitchDoingAnimation:YES];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutPictureVideoButton:NO];
    } completion:^(BOOL finished) {
        [self onSwitchedToFirst:NO];
    }];
    
}

- (void) leftToRightAction:(id)sender {
    //BARLog(@"leftToRightAction");
    [self takePictureActon:nil];
}

- (void) rightToLeftAction:(id)sender {
    //BARLog(@"rightToLeftAction");
    [self shootVideoAction:nil];
}

- (void) onSwitchedToFirst:(BOOL) toFirst {
    if([self.delegate respondsToSelector:@selector(imageVideoSwitchDoingAnimation:)]){
        [self.delegate imageVideoSwitchDoingAnimation:NO];
    }
    if(toFirst != self.isForFirst){
        self.isForFirst = toFirst;
        if([self.delegate respondsToSelector:@selector(imageVideoSwitchToFirst:)]){
            [self.delegate imageVideoSwitchToFirst:toFirst];
        }
    }
}



@end
