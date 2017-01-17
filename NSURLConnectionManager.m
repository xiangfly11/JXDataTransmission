//
//  NSURLConnectionManager.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 16/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "NSURLConnectionManager.h"
#import <UIKit/UIKit.h>

static const NSUInteger MAX_NUM_COUNT = 3;

@interface NSURLConnectionManager ()
@property (nonatomic,strong) NSMutableDictionary *taskDict;
@property (nonatomic,strong) NSMutableArray *taskArr;
@property (nonatomic,assign) UIBackgroundTaskIdentifier bagroundTaskID;

@end

@implementation NSURLConnectionManager

+ (instancetype)sharedManager {
    static NSURLConnectionManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NSURLConnectionManager alloc] init];
    });
    
    return _instance;
}

- (instancetype) init{
    self = [super init];
    
    if (self) {
        _taskDict = [NSMutableDictionary dictionary];
        _taskArr = [NSMutableArray array];
        _bagroundTaskID = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidFinished:) name:JXConnectionDownloadFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidBecomeActivity:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadTaskDidFinished:(NSNotification *)notification {
    NSString *urlStr = [notification.userInfo objectForKey:urlStr];
    [_taskDict removeObjectForKey:urlStr];
    
    if (_taskDict.count < MAX_NUM_COUNT) {
        if (_taskArr.count > 0) {
            NSDictionary *task = [_taskArr objectAtIndex:0];
            [self downloadWithURLString:task[@"urlString"] toPath:task[@"destinationPath"] progressBlock:task[@"progress"] completionBlock:task[@"completion"] failureBlock:task[@"failure"]];
            [_taskArr removeObjectAtIndex:0];
        }
    }
    
}

- (void)downloadTaskWillResign:(NSNotification *)notification {
    if(_taskDic.count>0){
        
        _bagroundTaskID=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
        }];
    }
}

- (void)downloadTaskDidBecomeActivity:(NSNotification *)notification {
    if(_backgroudTaskId!=UIBackgroundTaskInvalid){
        
        [[UIApplication sharedApplication] endBackgroundTask:_backgroudTaskId];
        _backgroudTaskId=UIBackgroundTaskInvalid;
    }
}

- (void)downloadTaskWillTerminate:(NSNotification *)notification {
    [[NSURLConnectionManager sharedManager] cancelAllDownloadTasks];
}


/**
 The method can manage download tasks.

 @param urlStr download url string
 @param destinationPath destination path to store data
 @param progress progress block to pass progress value
 @param completion completion block to notify download completion
 @param failure failure block to notify download failure
 */
- (void)downloadWithURLString:(NSString *)urlStr toPath:(NSString *)destinationPath progressBlock:(progressBlock)progress completionBlock:(completionBlock)completion failureBlock:(failureBlock)failure {
    
    //Check whether total download tasks is more than the maximum number of tasks
    //create a dictionary to store key information about that task
    //use queue to store that task and excute that task later
    if (_taskDic.count > MAX_NUM_COUNT) {
        NSDictionary *task = @{@"urlString":urlStr,
                                                @"destinationPath":destinationPath,
                                                @"progress":progress,
                                                @"completion":completion,
                                                @"failure":failure};
        [_taskArr addObject:task];
        return;
    }
    
    //initialize a downloader and store it in the task dictionary
    NSURLConnectionDownloader *downloader = [NSURLConnectionDownloader downloader];
    @synchronized (self) {
        [_taskDict setObject:downloader forKey:urlStr];
    }
    
    [downloader downloadWithURLString:urlStr toPath:destinationPath progressBlock:progress completionBlock:completion failureBlock:failure];
    
}


/**
 Cancel download task,note this task can be resume later

 @param urlStr task url should be cancel
 */
- (void)cancelDownloadWithURLStr:(NSString *)urlStr {
    NSURLConnectionDownloader *downloader = [_taskDict objectForKey:urlStr];
    [downloader cancel];
    @synchronized (self) {
        [_taskDict removeObjectForKey:urlStr];
    }
    
    if (_taskArr.count > 0) {
        NSDictionary *task = [_taskArr objectAtIndex:0];
        [self downloadWithURLString:task[@"urlString"] toPath:task[@"destinationPath"] progressBlock:task[@"progress"] completionBlock:task[@"completion"] failureBlock:task[@"failure"]];
        [_taskArr removeObjectAtIndex:0];
    }
}


/**
 Remove file at specific path by the url string which is specified by the user

 @param urlStr url string
 @param path destination path
 */
- (void)removeForURL:(NSString *)urlStr atPath:(NSString *)path {
    NSURLConnectionDownloader *downloader = [_taskDict objectForKey:urlStr];
    if (downloader) {
        [downloader cancel];
    }
    @synchronized (self) {
        [_taskDict removeObjectForKey:urlStr];
    }
    NSString *totalLengthKey = [NSString stringWithFormat:@"%@totalLength",urlStr];
    NSString *progressKey = [NSString stringWithFormat:@"%@progress",urlStr];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:totalLengthKey];
    [userDefaults removeObjectForKey:progressKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    NSError *error = nil;
    if (isExist) {
        [fileManager removeItemAtPath:path error:&error];
    }
    if (error) {
        NSLog(@"File remove error:%@",error.localizedDescription);
    }
}

- (void)cancelAllDownloadTasks {
    [_taskDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSURLConnectionDownloader *downloader = obj;
        [downloader cancel];
        [_taskDict removeObjectForKey:key];
    }];
}

@end
