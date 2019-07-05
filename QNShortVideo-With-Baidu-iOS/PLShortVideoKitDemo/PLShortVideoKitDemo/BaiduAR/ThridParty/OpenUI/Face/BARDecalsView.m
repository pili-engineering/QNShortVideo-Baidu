//
//  BARDecalsView.m
//  BDARClientSample
//
//  Created by Zhao,Xiangkai on 2018/4/4.
//  Copyright © 2018年 baidu. All rights reserved.
//

#import "BARDecalsView.h"
#import "BARDecalsCollectionViewCell.h"
#import "UIImage+Load.h"
#import "DARFaceDecalsModel.h"
#import "ZipArchive.h"
#import "BARFaceUtil.h"
#import "BARAlert.h"
#import "AFHTTPSessionManager.h"

typedef enum : NSUInteger {
    DecalDownloadStatusTypeDownloadTODO,
    DecalDownloadStatusTypeDownloading,
    DecalDownloadStatusTypeDownloadDone,
    DecalDownloadStatusTypeUnknown
} DecalDownloadStatusType;

@interface BARDecalsView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray *decalsData;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *selectedIdx;
@property (nonatomic, assign) BOOL alreadyCheckNetwork;
@property (nonatomic, strong) UIView *loadErrorView;
@property (nonatomic, assign) BOOL autoSwitch;
@property (nonatomic, copy) NSString *monkeyStartTime;
@property (nonatomic, assign) BOOL caseLoadFinished;
@property (nonatomic, strong) NSMutableArray *indexArray;

@end

@implementation BARDecalsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
//        CGFloat containerH = 246;
//        CGFloat containerY = frame.size.height - containerH;
        
//        UIView *dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, containerY)];
//        dismissView.backgroundColor = [UIColor clearColor];
//        [self addSubview:dismissView];
//        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
//        [dismissView addGestureRecognizer:touch];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        containerView.backgroundColor = [UIColor colorWithRed:3/255 green:3/255 blue:54/255 alpha:0.4];
        [self addSubview:containerView];
        
        UILabel *decalsLab = [[UILabel alloc] init];
        decalsLab.font = [UIFont systemFontOfSize:14];
        decalsLab.textColor = [UIColor whiteColor];
        decalsLab.text = @"贴图";
        [decalsLab sizeToFit];
        decalsLab.frame = CGRectMake(28, 12, decalsLab.bounds.size.width, decalsLab.bounds.size.height);
        decalsLab.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:decalsLab];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(28, CGRectGetMaxY(decalsLab.frame) + 4, 28, 2)];
        lineView.backgroundColor = [UIColor colorWithRed:9/255.0 green:251/255.0 blue:224/255.0 alpha:1.0];
        [containerView addSubview:lineView];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageWithContentOfFileForBAR:@"BaiduAR_Face_下拉箭头"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.frame = CGRectMake(frame.size.width - 20 - 28, 12, 20, 20);
        [containerView addSubview:closeBtn];
        
        CGFloat margin = 24;
        CGFloat minSpace = 27;
        CGFloat minLineSpace = 16;
        CGFloat sizeWidth = (frame.size.width - margin * 2 - minSpace * 4) / 5;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(sizeWidth, sizeWidth);
        layout.sectionInset = UIEdgeInsetsMake(0, margin, 5, margin);
        layout.minimumInteritemSpacing = minSpace;
        layout.minimumLineSpacing = minLineSpace;
        
        CGFloat collectionViewY = CGRectGetMaxY(lineView.frame) + 22;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, CGRectGetWidth(containerView.frame), frame.size.height - collectionViewY) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsVerticalScrollIndicator = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.alwaysBounceVertical = YES;
        [containerView addSubview:collectionView];
        [collectionView registerClass:[BARDecalsCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        self.collectionView = collectionView;
        
        CGFloat errorViewHeight = frame.size.height - CGRectGetMaxY(lineView.frame);
        CGFloat errorViewWidth = frame.size.width;
        self.loadErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), errorViewWidth, errorViewHeight)];
        self.loadErrorView.userInteractionEnabled = YES;
        self.loadErrorView.hidden = YES;
        [self addSubview:self.loadErrorView];
        
        UIImageView *errorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(errorViewWidth / 2 - 30, errorViewHeight / 2 - 45 , 60, 40)];
        errorIcon.image = [UIImage imageWithContentOfFileForBAR:@"BaiduAR_网络异常"];
        [self.loadErrorView addSubview:errorIcon];
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, errorViewHeight / 2 - 5, errorViewWidth, 50)];
        [errorLabel setText:@"网络异常\n请检查网络设置或稍后再试"];
        [errorLabel setFont:[UIFont systemFontOfSize:14.0f]];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.numberOfLines = 0;
        [self.loadErrorView addSubview:errorLabel];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSwitchCase:) name:@"aotoSwitchCase" object:nil];
        self.caseLoadFinished = YES;
        self.indexArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (NSString *)dateStr{
    NSDateFormatter *dateFormart = [[NSDateFormatter alloc]init];
    [dateFormart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormart.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString = [dateFormart stringFromDate:[NSDate date]];
    
    return dateString;
}

- (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *startDate =[date dateFromString:startTime];
    NSDate *endDdate = [date dateFromString:endTime];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [cal components:unitFlags fromDate:startDate toDate:endDdate options:0];
    
    // 天
    NSInteger day = [dateComponents day];
    // 小时
    NSInteger house = [dateComponents hour];
    // 分
    NSInteger minute = [dateComponents minute];
    // 秒
    NSInteger second = [dateComponents second];
    
    NSString *timeStr;
    
    if (day != 0) {
        timeStr = [NSString stringWithFormat:@"%zd天%zd小时%zd分%zd秒",day,house,minute,second];
    }
    else if (day==0 && house !=0) {
        timeStr = [NSString stringWithFormat:@"%zd小时%zd分%zd秒",house,minute,second];
    }
    else if (day==0 && house==0 && minute!=0) {
        timeStr = [NSString stringWithFormat:@"%zd分%zd秒",minute,second];
    }
    else{
        timeStr = [NSString stringWithFormat:@"%zd秒",second];
    }
    
    return timeStr;
}


- (void)autoSwitchCase:(NSNotification *)notify{
    
    static NSInteger cou = 0;
    if(notify){
        NSDictionary *dic = notify.object;
        self.autoSwitch = [dic[@"aotoSwitchCase"] boolValue];
    }
    if(!self.autoSwitch){
        cou = 0;
        self.monkeyStartTime = @"";
        return;
    }else{
        if(self.monkeyStartTime.length==0){
            self.monkeyStartTime = [self dateStr];
        }
    }
    
    cou++;
    static NSInteger index = 0;
    NSInteger maxCount = 40;
    NSLog(@"monkey info is count %d",cou);
    if(maxCount>self.decalsData.count){
        return;
    }
    
    NSString *nowTime = [self dateStr];
    NSString *diff = [self dateTimeDifferenceWithStartTime:self.monkeyStartTime endTime:nowTime];
    NSLog(@"monkey info is time-last %@",diff);
    
    NSIndexPath *paththt = [NSIndexPath indexPathForRow:index inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:paththt];
    index++;
    if(index>maxCount-1){
        index =0;
    }
    
    float timeInterval = 1+(arc4random() % 50); //1-50
    timeInterval = timeInterval / 10.0; //0.1-3 + 0.2 = 0.1-1.1
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoSwitchCase:nil];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"aotoSwitchCase" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissView {
    if (self.hideDecalsBlock) {
        self.hideDecalsBlock();
    }
}

- (void)setDecalsDataWith:(NSArray *)decalsData {
    if (decalsData == nil || decalsData.count == 0) {
        self.loadErrorView.hidden = NO;
        return;
    }
    self.loadErrorView.hidden = YES;
    self.decalsData = decalsData;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.decalsData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BARDecalsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.row = indexPath.row;
    DARFaceDecalsModel *decalModel = self.decalsData[indexPath.row];
    [cell setCellWithModel:decalModel];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.caseLoadFinished) {
        return;
    }
    
    if (self.indexArray.count >= 2) {
        [self.indexArray removeObjectAtIndex:0];
    }
    [self.indexArray addObject:indexPath];
    DARFaceDecalsModel *model = self.decalsData[indexPath.row];
    
    DARFaceDecalsModel *preModel;
    NSIndexPath *preIndex;
    if (self.indexArray.count == 2) {
        preIndex = self.indexArray[0];
        preModel = self.decalsData[preIndex.row];
    }
    switch (model.state) {
        case DARFaceDecalsStateNone:
        {
//            [self.decalsData enumerateObjectsUsingBlock:^(DARFaceDecalsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (obj.state == DARFaceDecalsStateSelected ) {
//                    obj.state = DARFaceDecalsStateNone;
//                }
//            }];
            
            if (preModel) {
                preModel.state = DARFaceDecalsStateNone;
                NSArray *arr = [NSArray arrayWithObject:preIndex];
                [collectionView reloadItemsAtIndexPaths:arr];
            }

            self.selectedIdx = indexPath;
            model.state = DARFaceDecalsStateSelected;
        
            if (self.changeDecalsBlock) {
                self.changeDecalsBlock(indexPath.row);
            }
//            [collectionView reloadData];
            NSArray *indexArray = [NSArray arrayWithObject:indexPath];
            [collectionView reloadItemsAtIndexPaths:indexArray];

        }
            break;
        case DARFaceDecalsStateUnDownload:
        case DARFaceDecalsStateUpdate:
        case DARFaceDecalsStateDownloadFail:
        {
            [self checkNetworkState];
            model.state = DARFaceDecalsStateDownloadDoing;
           
//            [collectionView reloadData];
            NSArray *indexArray = [NSArray arrayWithObject:indexPath];
            [collectionView reloadItemsAtIndexPaths:indexArray];
            self.caseLoadFinished = NO;
            [self startDownloadCase:indexPath];
        }
            break;
        case DARFaceDecalsStateDownloadDoing:
        {
            
        }
            break;
        case DARFaceDecalsStateLoading:
        {
            
        }
            break;
        case DARFaceDecalsStateSelected:
        {
//            [self.decalsData enumerateObjectsUsingBlock:^(DARFaceDecalsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (obj.state == DARFaceDecalsStateSelected) {
//                    obj.state = DARFaceDecalsStateNone;
//                }
//            }];
            
            
            model.state = DARFaceDecalsStateNone;
            if (self.cancelDecalsBlock) {
                self.cancelDecalsBlock(indexPath.row);
            }
            self.selectedIdx = nil;
//            [collectionView reloadData];
            NSArray *indexArray = [NSArray arrayWithObject:indexPath];
            [collectionView reloadItemsAtIndexPaths:indexArray];
            
        }
            break;
        default:
            break;
    }
}

- (void)handleSwitchDone {
//    [self.decalsData enumerateObjectsUsingBlock:^(DARFaceDecalsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.state == DARFaceDecalsStateSelected) {
//            obj.state = DARFaceDecalsStateNone;
//        }
//    }];
//
//    if(self.selectedIdx){
//        DARFaceDecalsModel *model = self.decalsData[self.selectedIdx.row];
//        model.state = DARFaceDecalsStateSelected;
//    }

    self.selectedIdx = nil;
//    [self.collectionView reloadData];
    self.caseLoadFinished = YES;
}

- (void)resetDecalsViewData {
    [self.decalsData enumerateObjectsUsingBlock:^(DARFaceDecalsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state == DARFaceDecalsStateSelected) {
            obj.state = DARFaceDecalsStateNone;
        }
    }];
    self.selectedIdx = nil;
    [self.collectionView reloadData];
    self.caseLoadFinished = YES;
}

- (void)startDownloadCase:(NSIndexPath *) indexPath{
    DARFaceDecalsModel *model = self.decalsData[indexPath.row];
    
    NSString *arPath = model.name;
    NSString *zipName = [NSString stringWithFormat:@"main_%@.zip",model.arkey];
    NSString *zipPath = [model.name stringByAppendingPathComponent:zipName];
    NSString *arPathAppendAr = [arPath stringByAppendingPathComponent:@"ar"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *removeItemError = nil;
    
    if([fileManager fileExistsAtPath:arPathAppendAr isDirectory:nil]){
        [fileManager removeItemAtPath:arPathAppendAr error:&removeItemError];
        if(removeItemError){
        }
    } else {
        [fileManager createDirectoryAtPath:arPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSURL *URL = [NSURL URLWithString:model.resourceUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask =[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if([zipPath length]){
            unlink([zipPath UTF8String]);
            return [NSURL fileURLWithPath:zipPath];
        }
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSString *errorStr = BARNSLocalizedString(@"bar_tip_server_error");
            if (error.code == NSURLErrorNotConnectedToInternet) {
                errorStr = BARNSLocalizedString(@"bar_tip_network_error");
            }
            [[BARAlert sharedInstance] showToastViewPortraitWithTime:1.0f title:nil message:errorStr dismissComplete:nil];
            self.selectedIdx = nil;
            model.state = DARFaceDecalsStateDownloadFail;
//            [self.collectionView reloadData];
            NSArray *indexArray = [NSArray arrayWithObject:indexPath];
            [self.collectionView reloadItemsAtIndexPaths:indexArray];
            return;
        }
        
        //下载完成开始解压
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self unzipDownloadCase:indexPath zipPath:zipPath arPath:arPath model:model];
        });
    }];
    [downloadTask resume];
    
    
}

-(void)unzipDownloadCase:(NSIndexPath *) indexPath zipPath:(NSString *)zipPath arPath:(NSString *)arPath model:(DARFaceDecalsModel *) model{
    BOOL done = [SSZipArchive unzipFileAtPath:zipPath toDestination:arPath];
    if (done) {
        //解压成功开始加载case
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //先去重置前一个case的旋转状态，如果有的话
            DARFaceDecalsModel *preModel;
            NSIndexPath *preIndex;
            if (self.indexArray.count == 2) {
                preIndex = self.indexArray[0];
                preModel = self.decalsData[preIndex.row];
            }
            if (preModel) {
                preModel.state = DARFaceDecalsStateNone;
                NSArray *arr = [NSArray arrayWithObject:preIndex];
                [self.collectionView reloadItemsAtIndexPaths:arr];
            }
            
            
            
            self.selectedIdx = indexPath;
            model.state = DARFaceDecalsStateSelected;
        
            if (self.changeDecalsBlock) {
                self.changeDecalsBlock(indexPath.row);
            }
            
            NSArray *indexArray = [NSArray arrayWithObject:indexPath];
            [self.collectionView reloadItemsAtIndexPaths:indexArray];
        });
                
        
        
    } else {
        self.selectedIdx = nil;
        model.state = DARFaceDecalsStateDownloadFail;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void)checkNetworkState{
    if (self.alreadyCheckNetwork) {
        return;
    }
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            self.alreadyCheckNetwork = YES;
            //提示网络流量
            NSString *noWifiString = BARNSLocalizedString(@"bar_tips_on_wwan");
            [[BARAlert sharedInstance] showToastViewPortraitWithTime:2.0f title:nil message:noWifiString dismissComplete:nil];
        }
    }];
    
}

@end
