//
//  BARBeautyView.m
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BARBeautyView.h"
#import "BARTitleSliderView.h"
#import "UIImage+Load.h"
#import "BARFilterCollectionViewCell.h"
#import "BARBeautyCollectionViewCell.h"

@interface BARBeautyView()<BARTitleSliderViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *beautyView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) BARTitleSliderView *whiteSliderView;
//@property (nonatomic, strong) BARTitleSliderView *skinSliderView;

@property (nonatomic, strong) BARTitleSliderView *eyeSliderView;
@property (nonatomic, strong) BARTitleSliderView *faceSliderView;

@property (nonatomic, strong) BARTitleSliderView *alphaSliderView;
@property (nonatomic, strong) NSArray *filterGroup;
@property (nonatomic, strong) UICollectionView *filterCollectionView;
@property (nonatomic, strong) UICollectionView *beautyCollectionView;
@property (nonatomic, strong) UIImageView *containerView;
//@property (nonatomic, strong) UIView *dismissView;
@property (nonatomic, strong) UIButton * closeBtn;
@property (nonatomic, strong) NSIndexPath *currentFilterIndexPath;
@property (nonatomic, strong) NSIndexPath *currentBeautyIndexPath;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UILabel *resetLabel;
@property (nonatomic, strong) UIView *intervalLineView;
@property (nonatomic, strong) NSArray *beautyGroup;

@property (nonatomic, assign) BOOL isFirst;

@end

@implementation BARBeautyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        UIView *dismissView = [[UIView alloc] initWithFrame:CGRectZero];
//        dismissView.backgroundColor = [UIColor clearColor];
//        [self addSubview:dismissView];
//        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewTouch)];
//        touch.delegate = self;
//        [dismissView addGestureRecognizer:touch];
//        self.dismissView = dismissView;
        
        self.containerView = [[UIImageView alloc] init];
        self.containerView.userInteractionEnabled = YES;
        //self.containerView.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_渐变背景"];
        self.containerView.backgroundColor = [UIColor colorWithRed:3/255.0 green:3/255.0 blue:54/255.0 alpha:0.4/1.0];
        [self addSubview:self.containerView];
        
        UIButton *beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [beautyBtn setTitle:@"美型" forState:UIControlStateNormal];
        beautyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [beautyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [beautyBtn addTarget:self action:@selector(showBeauty:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:beautyBtn];
        self.beautyBtn = beautyBtn;
        
        UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
        filterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [filterBtn addTarget:self action:@selector(showFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:filterBtn];
        self.filterBtn = filterBtn;
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0];
        [self.containerView addSubview:self.lineView];
        
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBtn setImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_下拉箭头"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(dismissViewTouch) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.closeBtn];
        
        self.beautyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, beautyBtn.frame.origin.y)];
        //self.beautyView.backgroundColor = [UIColor yellowColor];
        [self.containerView addSubview:self.beautyView];
        
//        self.whiteSliderView = [[BARTitleSliderView alloc] initWithFrame:CGRectMake(28, 0, self.beautyView.frame.size.width - 56, 38) title:@"美白"];
//        self.whiteSliderView.tag = 10000;
//        self.whiteSliderView.delegate = self;
        
//        self.skinSliderView = [[BARTitleSliderView alloc] initWithFrame:CGRectMake(28, CGRectGetMaxY(self.whiteSliderView.frame) + 5, self.beautyView.frame.size.width - 56, 38) title:@"磨皮"];
//        self.skinSliderView.tag = 10001;
//        self.skinSliderView.delegate = self;
        
//        self.eyeSliderView = [[BARTitleSliderView alloc] initWithFrame:CGRectMake(28, CGRectGetMaxY(self.whiteSliderView.frame) + 5, self.beautyView.frame.size.width - 56, 38) title:@"大眼"];
//        self.eyeSliderView.tag = 10002;
//        self.eyeSliderView.delegate = self;
//
//        self.faceSliderView = [[BARTitleSliderView alloc] initWithFrame:CGRectMake(28, CGRectGetMaxY(self.eyeSliderView.frame) + 5, self.beautyView.frame.size.width - 56, 38) title:@"瘦脸"];
//        self.faceSliderView.tag = 10003;
//        self.faceSliderView.delegate = self;
        
//        [self.beautyView addSubview:self.whiteSliderView];
//        //[self.beautyView addSubview:self.skinSliderView];
//        [self.beautyView addSubview:self.eyeSliderView];
//        [self.beautyView addSubview:self.faceSliderView];
        
        self.beautyGroup = @[@{@"name":@"美肤", @"type":@"whiten", @"select": @"美肤_选中", @"unSelect":@"美肤_未选中"},
                             @{@"name":@"磨皮", @"type":@"skin", @"select": @"磨皮_选中", @"unSelect":@"磨皮_未选中"},
                             @{@"name":@"大眼", @"type":@"eye", @"select": @"大眼_选中", @"unSelect":@"大眼_未选中"},
                             @{@"name":@"瘦脸", @"type":@"thinFace", @"select": @"瘦脸_选中", @"unSelect":@"瘦脸_未选中"},
                             ];
        
        self.filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, filterBtn.frame.origin.y)];
        self.filterView.hidden = YES;
        [self.containerView addSubview:self.filterView];
        
        self.alphaSliderView = [[BARTitleSliderView alloc] initWithFrame:CGRectMake(28, 0, frame.size.width - 52, 20) title:@"程度"];
        [self.alphaSliderView showPercentLabWith:YES];
        self.alphaSliderView.tag = 10004;
        self.alphaSliderView.delegate = self;
        [self.alphaSliderView setSliderValue:0];
        [self addSubview:self.alphaSliderView];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(44, 97);
        layout.minimumInteritemSpacing = 12;
        
        self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.filterCollectionView.backgroundColor = [UIColor clearColor];
        self.filterCollectionView.showsHorizontalScrollIndicator = NO;
        self.filterCollectionView.delegate = self;
        self.filterCollectionView.dataSource = self;
        [self.filterView addSubview:self.filterCollectionView];
        [self.filterCollectionView registerClass:[BARFilterCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        
        UICollectionViewFlowLayout *beautyLayout = [[UICollectionViewFlowLayout alloc] init];
        beautyLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        beautyLayout.itemSize = CGSizeMake(48, 100);
        beautyLayout.minimumInteritemSpacing = 10;
        
        self.beautyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:beautyLayout];
        self.beautyCollectionView.backgroundColor = [UIColor clearColor];
        self.beautyCollectionView.showsHorizontalScrollIndicator = NO;
        self.beautyCollectionView.delegate = self;
        self.beautyCollectionView.dataSource = self;
        [self.beautyView addSubview:self.beautyCollectionView];
        [self.beautyCollectionView registerClass:[BARBeautyCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        
        self.intervalLineView = [[UIView alloc] initWithFrame:CGRectMake(76, 20, 1, 36)];
        self.intervalLineView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3/1.0];
        [self.beautyView addSubview:self.intervalLineView];
        
        self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.resetBtn.frame = CGRectMake(28, 7, 28, 28);
        [self.resetBtn setBackgroundImage:[UIImage imageNamed:@"重置按钮"] forState:UIControlStateNormal];
        self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resetBtn addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
        [self.beautyView addSubview:self.resetBtn];
        
        self.resetLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(self.resetBtn.frame) + 5, 22, 17)];
        self.resetLabel.text = @"重置";
        self.resetLabel.font = [UIFont systemFontOfSize:10];
        self.resetLabel.textColor = [UIColor whiteColor];
        [self.beautyView addSubview:self.resetLabel];
        
        [self updateUIFrame];
        self.isFirst = YES;
    }
    return self;
}

- (void)updateUIFrame {
    CGFloat containerH = 126;
    
    self.alphaSliderView.frame = CGRectMake(28, 0, self.frame.size.width - 52, 20);
    self.containerView.frame = CGRectMake(0, CGRectGetMaxY(self.alphaSliderView.frame) + 10, self.frame.size.width, containerH);
    
    self.beautyBtn.frame = CGRectMake(28, 12, 30, 20);
    self.filterBtn.frame = CGRectMake(CGRectGetMaxX(self.beautyBtn.frame) + 28, self.beautyBtn.frame.origin.y, 30, 20);
    
    self.lineView.frame = CGRectMake(self.beautyBtn.frame.origin.x + 1, CGRectGetMaxY(self.beautyBtn.frame), 28, 2);
    self.closeBtn.frame = CGRectMake(self.frame.size.width - 30 - 23, 14, 20, 20);
    
    self.beautyView.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 9, self.frame.size.width, containerH - CGRectGetMaxY(self.lineView.frame) - 9);
    
//    self.whiteSliderView.frame = CGRectMake(10, 10, self.beautyView.frame.size.width - 20, 48);
//    self.skinSliderView.frame = CGRectMake(10, CGRectGetMaxY(self.whiteSliderView.frame) + 10, self.beautyView.frame.size.width - 20, 48);
//    self.eyeSliderView.frame = CGRectMake(10, CGRectGetMaxY(self.skinSliderView.frame) + 10, self.beautyView.frame.size.width - 20, 48);
//    self.faceSliderView.frame = CGRectMake(10, CGRectGetMaxY(self.eyeSliderView.frame) + 10, self.eyeSliderView.frame.size.width - 20, 48);
    
    self.filterView.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 6, self.frame.size.width, containerH - CGRectGetMaxY(self.lineView.frame) - 5);
    
    self.filterCollectionView.frame = CGRectMake(10, 10, CGRectGetWidth(self.containerView.frame), 100);
    
    self.beautyCollectionView.frame = CGRectMake(CGRectGetMaxX(self.intervalLineView.frame), 7, CGRectGetWidth(self.containerView.frame), 100);
}

- (void)showBeauty:(UIButton *)btn {
    self.filterView.hidden = YES;
    self.beautyView.hidden = NO;
    [self updateUIFrame];
    CGRect lineFrame = self.lineView.frame;
    lineFrame.origin.x = self.beautyBtn.frame.origin.x + 1;
    self.lineView.frame = lineFrame;
    self.alphaSliderView.title = @"程度";
    self.alphaSliderView.hidden = NO;
    [self.beautyCollectionView reloadData];
    if (self.currentBeautyIndexPath) {
        if (self.changeBeautyBlock) {
            NSDictionary *beauty = self.beautyGroup[self.currentBeautyIndexPath.row];
            self.changeBeautyBlock([beauty objectForKey:@"type"]);
        }
    }
}

- (void)showFilter:(UIButton *)btn {
    self.filterView.hidden = NO;
    self.beautyView.hidden = YES;
    [self updateUIFrame];
    
    if (self.isFirst) {
        self.currentFilterIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.isFirst = NO;
    }
    
    if (self.currentFilterIndexPath && self.currentFilterIndexPath.row == 0) {
        self.alphaSliderView.hidden = YES;
    }
    
    CGRect lineFrame = self.lineView.frame;
    lineFrame.origin.x = self.filterBtn.frame.origin.x + 1;
    self.lineView.frame = lineFrame;
    self.alphaSliderView.title = @"透明度";
    [self.filterCollectionView reloadData];
    if (self.currentFilterIndexPath) {
        if (self.changeFilterBlock) {
            self.changeFilterBlock(self.currentFilterIndexPath.row);
        }
    }
}

- (void)reset:(UIButton *)btn {
    if (self.resetBeautyBlock) {
        self.resetBeautyBlock();
    }
}

- (void)dismissViewTouch {
    if (self.hideBeautyBlock) {
        self.hideBeautyBlock();
    }
}

- (void)setSliderValue:(CGFloat)value type:(NSInteger)type {
    [self.alphaSliderView setSliderValue:value];
}

- (void)setFilterAlphaWith:(CGFloat)value {
    [self.alphaSliderView setSliderValue:value];
}

- (void)setFilterGroupWith:(NSArray *)filterGroup {
    self.filterGroup = filterGroup;
    [self.filterCollectionView reloadData];
}

#pragma mark - BARTitleSliderViewDelegate
- (void)updateSliderValue:(CGFloat)value titleSliderView:(BARTitleSliderView *)titleSliderView {
    if (self.changeSliderValueBlock) {
        if (self.currentFilterIndexPath && self.beautyView.hidden) {
            self.changeSliderValueBlock(value, @"filter");
        }else if (self.currentBeautyIndexPath && !self.beautyView.hidden) {
            self.changeSliderValueBlock(value, [[self.beautyGroup objectAtIndex:self.currentBeautyIndexPath.row] objectForKey:@"type"]);

        }
    }
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.beautyView.hidden) {
        return self.filterGroup.count;
    }else {
        return self.beautyGroup.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.filterCollectionView == collectionView) {
        BARFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
        
        NSDictionary *filter = self.filterGroup[indexPath.row];
        [cell updateBgImgViewWith:[filter objectForKey:@"image"]];
        
        [cell updateSelectedStatusWith:self.currentFilterIndexPath && self.currentFilterIndexPath.row == indexPath.row];
        
        [cell setTitlaLabelWith:[filter objectForKey:@"name"]];
        
        return cell;
    }else {
        BARBeautyCollectionViewCell *cell = (BARBeautyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
        
        NSDictionary *beauty = self.beautyGroup[indexPath.row];
        
        [cell updateBgImgViewWith:(self.currentBeautyIndexPath && self.currentBeautyIndexPath.row == indexPath.row) ? [beauty objectForKey:@"select"] : [beauty objectForKey:@"unSelect"]];
        [cell updateTitleColorwith:(self.currentBeautyIndexPath && self.currentBeautyIndexPath.row == indexPath.row)];
        [cell setTitlaLabelWith:[beauty objectForKey:@"name"]];
        
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.beautyView.hidden) {
        if (indexPath.row == 0) {
            self.alphaSliderView.hidden = YES;
        }else {
            self.alphaSliderView.hidden = NO;
        }
        if (self.currentFilterIndexPath && indexPath.row == self.currentFilterIndexPath.row) {
            if (self.cancelFilterBlock) {
                self.cancelFilterBlock();
            }
            self.currentFilterIndexPath = nil;
            self.alphaSliderView.hidden = YES;
        }else if (!self.currentFilterIndexPath || self.currentFilterIndexPath.row != indexPath.row){
            BARFilterCollectionViewCell *cell = (BARFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [cell updateSelectedStatusWith:YES];
            if (self.changeFilterBlock) {
                self.changeFilterBlock(indexPath.row);
            }
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            self.currentFilterIndexPath = indexPath;
        }
    }else {
        if (self.currentBeautyIndexPath && indexPath.row == self.currentBeautyIndexPath.row) {
            if (self.cancelBeautyBlock) {
                self.cancelBeautyBlock();
            }
            self.currentBeautyIndexPath = nil;
        }else if (!self.currentBeautyIndexPath || self.currentBeautyIndexPath.row != indexPath.row){
            BARBeautyCollectionViewCell *cell = (BARBeautyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            NSDictionary *beauty = self.beautyGroup[indexPath.row];
            [cell updateBgImgViewWith:[beauty objectForKey:@"select"]];
            [cell updateTitleColorwith:YES];
            
            if (self.changeBeautyBlock) {
                self.changeBeautyBlock([beauty objectForKey:@"type"]);
            }
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            self.currentBeautyIndexPath = indexPath;
        }
    }
    [collectionView reloadData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 20);
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.alphaSliderView]) {
        return NO;
    }
    return YES;
}

@end
