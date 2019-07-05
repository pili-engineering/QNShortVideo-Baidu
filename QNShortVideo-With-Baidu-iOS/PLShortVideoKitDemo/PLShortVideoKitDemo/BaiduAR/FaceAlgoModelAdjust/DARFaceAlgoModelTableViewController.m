
//
//  DARFaceAlgoModelTableViewController.m
//  ARAPP-OpenStandard
//
//  Created by V_,Lidongxue on 2018/12/10.
//  Copyright © 2018年 Asa. All rights reserved.
//

#import "DARFaceAlgoModelTableViewController.h"

@interface DARFaceAlgoModelTableViewController ()

@end

@implementation DARFaceAlgoModelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.modelArray[indexPath.row];
 
    return cell;
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectModelBlock) {
        self.selectModelBlock(self.modelArray[indexPath.row]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
