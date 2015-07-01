//
//  ResultViewController.m
//  Scanner
//
//  Created by workMac on 15/7/1.
//  Copyright © 2015年 Gree. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ResultViewController
{
    NSArray *_barCodeMessages;
    NSArray *_QRCodeMessages;
}

- (void)viewDidLoad
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self getSourceData];
}

- (void)getSourceData
{
    NSString *barCodeMessagesFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"barCodeMessages.archive"];
    _barCodeMessages = [NSKeyedUnarchiver unarchiveObjectWithFile:barCodeMessagesFilePath];
    NSString *QRCodeMessagesFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"QRCodeMessages.archive"];
    _QRCodeMessages = [NSKeyedUnarchiver unarchiveObjectWithFile:QRCodeMessagesFilePath];
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _barCodeMessages.count;
    }else{
        return _QRCodeMessages.count;
    }
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }else{
        return 0;
    }
}

- (UITableViewCell*)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%ld   %@",(long)indexPath.row + 1,_barCodeMessages[indexPath.row]];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%ld   %@",(long)indexPath.row + 1,_QRCodeMessages[indexPath.row]];
    }
    
    return cell;
}

@end
