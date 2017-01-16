//
//  SessionViewController.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 14/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "SessionViewController.h"

@interface SessionViewController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong,nonatomic) NSData *resumeData;
@property (assign,nonatomic) BOOL isResume;

@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
       
    }
    
    return _session;
}


- (IBAction)btnClickHandle:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 100:
            [self startDownloadFile];
            break;
        case 101:
            [self stopDownloadFile];
            break;
        case 102:
            [self cancelDownloadFile];
            break;
        default:
            break;
    }
}


- (void)startDownloadFile {
    NSString *urlStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    NSURL *url = [NSURL URLWithString:urlStr];
    if (_isResume) {
        self.downloadTask = [ self.session downloadTaskWithResumeData:self.resumeData];
        self.isResume = NO;
    }else {
         self.downloadTask = [self.session downloadTaskWithURL:url];
    }
   [_downloadTask resume];
}

- (void)stopDownloadFile {
    __weak typeof(self) weakSelf = self;
    [_downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        weakSelf.downloadTask = nil;
        weakSelf.isResume = YES;
    }];
}

- (void)cancelDownloadFile {
    [_downloadTask cancel];
}

#pragma  mark -- NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"File Path: %@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager moveItemAtPath:location.path toPath:filePath error:&error];
    
    if (error) {
        NSLog(@"File Store Error:%@",error.localizedDescription);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    if (_isResume) {
//        self.progressView.progress = (double) fileOffset / expectedTotalBytes;
//        self.progressLabel.text = [NSString stringWithFormat:@"%.2f / 100",(double) fileOffset / expectedTotalBytes * 100];
//    }
   
    
   
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.progressView.progress = (double) totalBytesWritten / totalBytesExpectedToWrite;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f / 100",(double) totalBytesWritten / totalBytesExpectedToWrite * 100];
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
