//
//  TaskTableViewCell.h
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 18/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TaskModel;
typedef void(^senderBlock)(UIButton *sender);

@interface TaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic,copy) senderBlock block;

- (void)setCellWithModel:(TaskModel *)model;

@end
