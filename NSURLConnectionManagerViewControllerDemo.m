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
    taskOne.name = @"Task One";
    taskOne.urlStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    taskOne.destinationPath = [caches stringByAppendingString:taskOne.name];
    [_taskArr addObject:taskOne];
    
    TaskModel *taskTwo = [[TaskModel alloc] init];
    taskTwo.name = @"Task Two";
    taskTwo.urlStr = @"http://imgcache.qq.com/qzone/biz/gdt/dev/sdk/ios/release/GDT_iOS_SDK.zip";
    taskTwo.destinationPath = [caches stringByAppendingString:taskTwo.name];
    [_taskArr addObject:taskTwo];
    
    TaskModel *taskThree = [[TaskModel alloc] init];
    taskThree.name = @"Task Three";
    taskThree.urlStr = @"http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar";
    taskThree.destinationPath = [caches stringByAppendingString:taskThree.name];
    [_taskArr addObject:taskThree];
    
}


- (void) createTableView {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
