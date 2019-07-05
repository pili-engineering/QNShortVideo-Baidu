//
//  DARFaceAlgoModelTableViewController.h
//  ARAPP-OpenStandard
//
//  Created by V_,Lidongxue on 2018/12/10.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DARFaceAlgoModelTableViewController : UITableViewController
@property (nonatomic, copy) NSArray *modelArray;
@property (nonatomic, copy) void(^selectModelBlock)(NSString *modelPath);

@end

NS_ASSUME_NONNULL_END
