//
//  ViewController.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 12/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import "ViewController.h"
#import "NSURLConnectionManager.h"

@interface ViewController ()

//@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,strong) NSMutableURLRequest *urlRequest;
@property (nonatomic,strong) __block NSMutableData *fileData;
@property (nonatomic,assign) __block long long currentLength;
@property (nonatomic,assign) __block long long totalLength;
@property (nonatomic,strong) NSURLConnectionManager *connectionManager;
@property (nonatomic,strong) __block NSString *filePath;
@property (nonatomic,strong) __block NSFileHandle *fileHandle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.urlStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
//    self.urlStr = @"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg";
//    NSURL *url = [NSURL URLWithString:_urlStr];
//    self.urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickHandler:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:
            [self downloadRequest];
            break;
        case 101:
           [self stopRequest];
            break;
        case 102:
//            [self cancleRequest];
            break;
        default:
            break;
    }
    
}


- (void)downloadRequest {
   
//    self.urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self startImmediately:YES];
    self.connectionManager = [NSURLConnectionManager sharedManager];
    [self.connectionManager connectWithURL:_urlStr];
    
    __weak typeof(self) weakSelf = self;
    _connectionManager.receivedResponse = ^(NSURLConnection *connection,NSURLResponse *response) {
//        _fileData = [NSMutableData data];
        _totalLength = response.expectedContentLength;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        weakSelf.filePath = filePath;
        NSLog(@"File Path: %@",weakSelf.filePath);
    };
    
    
    _connectionManager.receivedData = ^(NSData *data,long long currentLength) {
        [weakSelf.fileData appendData:data];
        _currentLength = currentLength;
//        NSLog(@"Current Length:%zd",weakSelf.currentLength);
        weakSelf.progressView.progress = (double)weakSelf.currentLength/weakSelf.totalLength;
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.filePath];
        weakSelf.fileHandle = fileHandle;
        [weakSelf.fileHandle seekToEndOfFile];
        [weakSelf.fileHandle writeData:data];
    };
    
    _connectionManager.finishLoading = ^(BOOL isFinished) {
        if (isFinished) {
            [weakSelf.fileHandle closeFile];
            weakSelf.fileHandle = nil;
        }
    };
}



- (void)stopRequest {
//    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
//    [_urlRequest setValue:range forHTTPHeaderField:@"Range"];
    [_connectionManager connectionStop];
}

- (void)cancleRequest {
//    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",0];
//    [_urlRequest setValue:range forHTTPHeaderField:@"Range"];
//    self.fileData = nil;
    [_connectionManager connectionCancel];
}

//#pragma mark - NSURLConnectionDataDelegate
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    self.fileData = [NSMutableData data];
//    self.totalLength = response.expectedContentLength;
//    NSLog(@"Total bits %zd bytes",_totalLength);
//}
//
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.fileData appendData:data];
//    self.currentLength = _fileData.length;
//    self.progressView.progress = (float)_currentLength / _totalLength;
//    NSLog(@"%zd",_currentLength);
//    self.progressLabel.text = [NSString stringWithFormat:@"%.2f / 100",self.progressView.progress * 100];
//    
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *fullPath = [caches stringByAppendingPathComponent:@"abc.mp4"];
//    [self.fileData writeToFile:fullPath atomically:YES];
//    
//    NSLog(@"Directory:%@",fullPath);
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    NSLog(@"Error:%@",error.localizedDescription);
//}






@end
