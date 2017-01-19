//
//  TestViewController.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 13/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "ConnectionViewController.h"

@interface ConnectionViewController ()<NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong,nonatomic) NSURLConnection *connection;
@property (strong,nonatomic) NSMutableURLRequest *urlRequest;
@property (assign,nonatomic) long long currentLength;
@property (assign,nonatomic) long long totalLength;
@property (strong,nonatomic) NSFileManager *fileManager;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSFileHandle *fileHandle;
@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *urlStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    NSURL *url = [NSURL URLWithString:urlStr];
    self.urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnClick:(UIButton *)sender {
    switch (sender.tag) {
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
    self.connection = [NSURLConnection connectionWithRequest:_urlRequest delegate:self];
    
}

- (void)stopDownloadFile {
    NSString *range = [NSString stringWithFormat:@"bytes:%lld-",_currentLength];
    [_urlRequest setValue:range forHTTPHeaderField:@"Range"];
    NSLog(@"URL Request:%@",_urlRequest);
    NSLog(@"Range:%@",range);
    [_connection cancel];
    _connection = nil;
}

- (void)cancelDownloadFile {
    
}

#pragma mark -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!_totalLength) {
        self.totalLength = response.expectedContentLength;
        NSLog(@"Total Length:%lld",_totalLength);
    }
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        self.filePath = filePath;
        [_fileManager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"File Path:%@",self.filePath);
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
   
    if (!_fileHandle) {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
    
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    self.currentLength += data.length;
    self.progressView.progress = (double)_currentLength / _totalLength;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f / 100",(double)_currentLength/_totalLength * 100];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.connection cancel];
    self.connection = nil;
    [_fileHandle closeFile];
    self.fileHandle = nil;
    NSLog(@"Length After Loading:%lld",_currentLength);
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
