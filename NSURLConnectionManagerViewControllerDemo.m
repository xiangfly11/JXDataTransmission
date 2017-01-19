//
//  NSURLConnectionManagerViewControllerDemo.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 18/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "NSURLConnectionManagerViewControllerDemo.h"
#import "TaskModel.h"
#import "TaskTableViewCell.h"
#import "NSURLConnectionManager.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface NSURLConnectionManagerViewControllerDemo ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *taskArr;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation NSURLConnectionManagerViewControllerDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareData];
    [self createTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareData {
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    self.taskArr = [NSMutableArray array];
    
    TaskModel *taskOne = [[TaskModel alloc] init];
    taskOne.name = @"minion_020.mp4";
    taskOne.urlStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    taskOne.destinationPath = [caches stringByAppendingPathComponent:taskOne.name];
    [_taskArr addObject:taskOne];
    NSLog(@"Task One Path:%@",taskOne.destinationPath);
    
    TaskModel *taskTwo = [[TaskModel alloc] init];
    taskTwo.name = @"GDT_iOS_SDK12.zip";
    taskTwo.urlStr = @"http://imgcache.qq.com/qzone/biz/gdt/dev/sdk/ios/release/GDT_iOS_SDK.zip";
    taskTwo.destinationPath = [caches stringByAppendingPathComponent:taskTwo.name];
    [_taskArr addObject:taskTwo];
    NSLog(@"Task Two Path:%@",taskTwo.destinationPath);
    
    TaskModel *taskThree = [[TaskModel alloc] init];
    taskThree.name = @"content12.jar";
    taskThree.urlStr = @"http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar";
    taskThree.destinationPath = [caches stringByAppendingPathComponent:taskThree.name];
    [_taskArr addObject:taskThree];
    NSLog(@"Task Three Path:%@",taskThree.destinationPath);
    
}


- (void) createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 66, SCREEN_WIDTH, SCREEN_HEIGHT - 66) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}


#pragma mark -- UITableViewDelegate

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

#pragma mark -- UITableViewDataSource 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell ID";
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TaskTableViewCell" owner:nil options:nil] lastObject];
    }
    
    TaskModel *model = _taskArr[indexPath.row];
    [cell setCellWithModel:model];
    
    __weak typeof(cell) weakCell = cell;
    cell.block = ^(UIButton *btn) {
        if ([btn.currentTitle isEqualToString:@"Download"] || [btn.currentTitle isEqualToString:@"Resume"]) {
            [btn setTitle:@"Pause" forState:UIControlStateNormal];
            
            [[NSURLConnectionManager sharedManager] downloadWithURLString:model.urlStr toPath:model.destinationPath progressBlock:^(float progress, NSUInteger currentLength, NSUInteger totalLength) {
                weakCell.progressView.progress = progress;
                NSString *currentSize = [self convertSize:currentLength];
                NSString *totalSize = [self convertSize:totalLength];
                weakCell.progressLabel.text = [NSString stringWithFormat:@"%@ / %@",currentSize,totalSize];
                weakCell.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",weakCell.progressView.progress * 100];
            } completionBlock:^{
                [btn setTitle:@"Done" forState:UIControlStateNormal];
                [btn setEnabled: NO];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Remind" message:[NSString stringWithFormat:@"%@Download Done✅",model.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            } failureBlock:^(NSError *error) {
                [[NSURLConnectionManager sharedManager] cancelDownloadWithURLStr:model.urlStr];
                [btn setTitle:@"Resume" forState:UIControlStateNormal];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
                [alert show];
            }];
        }else if ([btn.currentTitle isEqualToString:@"Pause"]) {
            [btn setTitle:@"Resume" forState:UIControlStateNormal];
            [[NSURLConnectionManager sharedManager] cancelDownloadWithURLStr:model.urlStr];
        }
    };
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskModel *model = _taskArr[indexPath.row];
    [[NSURLConnectionManager sharedManager] removeForURL:model.urlStr atPath:model.destinationPath];
    [_taskArr removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)convertSize:(NSUInteger) size {
    NSString *result;
    if (size < 1024) {
        result = [NSString stringWithFormat:@"%zdB",size];
    }else if (size >=1024 && size < 1024 * 1024) {
        result = [NSString stringWithFormat:@"%.1fKB",(float)size / 1024];
    }else if (size >= 1024 * 1024 && size < 1024 * 1024 * 1024) {
        result = [NSString stringWithFormat:@"%.1fMB",(float) size / (1024 * 1024)];
    }else {
        result = [NSString stringWithFormat:@"%.1fGB", (float) size / (1024 * 1024 * 1024)];
    }
    
    return result;
}

@end
