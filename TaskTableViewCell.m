//
//  TaskTableViewCell.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 18/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "TaskModel.h"
#import "NSURLConnectionManager.h"
@implementation TaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)clickActionHandle:(id)sender {
    UIButton *btn = (UIButton *) sender;
    if (_block) {
        self.block(btn);
    }else {
        NSLog(@"There is no block implementation to respond the click action!");
    }
}


- (void)setCellWithModel:(TaskModel *)model {
    self.nameLabel.text = model.name;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:model.destinationPath];
    
    if (isExist) {
        self.progressView.progress = [NSURLConnectionManager lastProgressForURL:model.urlStr];
        self.progressLabel.text = [NSURLConnectionManager fileSizeForURL:model.urlStr];
        self.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",_progressView.progress * 100];
    }
    
    if (_progressView.progress == 1.0) {
        [self.downloadBtn setTitle:@"Done" forState:UIControlStateNormal];
        self.downloadBtn.enabled = NO;
    }else if (_progressView.progress > 0.0) {
        [self.downloadBtn setTitle:@"Resume" forState:UIControlStateNormal];
    }else {
        [self.downloadBtn setTitle:@"Download" forState:UIControlStateNormal];
    }
    
}

@end
