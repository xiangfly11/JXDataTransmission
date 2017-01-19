//
//  NSURLConnectionDownloader.m
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 16/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//



#import "NSURLConnectionDownloader.h"

static const NSString *totalLengthKey = @"totalLength";

@interface NSURLConnectionDownloader ()
@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,strong) NSString *destinationPath;
@property (nonatomic,copy,readwrite) progressBlock pregress;
@property (nonatomic,copy,readwrite) completionBlock completion;
@property (nonatomic,copy,readwrite) failureBlock failure;
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableURLRequest *request;
@property (nonatomic,strong) NSFileHandle *fileHandle;
@end

@implementation NSURLConnectionDownloader

- (instancetype)init {
    return self = [super init];
}


+ (instancetype)downloader {
    return [[[self class ]alloc] init];
}


- (void)downloadWithURLString:(NSString *)urlStr toPath:(NSString *)destinationPath progressBlock:(progressBlock)progress completionBlock:(completionBlock)completion failureBlock:(failureBlock)failure {
    if (urlStr && destinationPath) {
        self.urlStr = urlStr;
        self.destinationPath = destinationPath;
        self.pregress = progress;
        self.completion = completion;
        self.failure = failure;
    }
    
    NSURL *url = [NSURL URLWithString: urlStr];
    self.request = [NSMutableURLRequest requestWithURL:url];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:destinationPath];
    
    if (isExist) {
        NSError *error = nil;
        NSUInteger length = [[[fileManager attributesOfItemAtPath:destinationPath error:&error] objectForKey:NSFileSize] integerValue];
        NSString *range = [NSString stringWithFormat:@"bytes:%zd-",length];
        [self.request setValue:range forHTTPHeaderField:@"Range"];
    }
    
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
}



#pragma mark -- NSURLConnectionDelegate && NSURLConnectionDataDelegate

/**
  *System will call this method after download failed
  *Failure Block will be called in here to pass error information
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_failure) {
        _failure(error);
    }
}


/**
 *System will call this method after recevie response from server
 *1, get the total length of data from response.
 *2, create file at destination path to store download data if that file is not exist at the destination path.
 *3, create file handler to indicate download data offset for data re-download after download pause.
*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSString *key = [NSString stringWithFormat:@"%@%@",_urlStr,totalLengthKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger totalLength = [defaults integerForKey:key];
    
    if (totalLength == 0) {
        totalLength = response.expectedContentLength;
        [defaults setInteger:totalLength forKey:key];
        [defaults synchronize];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:_destinationPath];
    if (!isExist) {
        [fileManager createFileAtPath:_destinationPath contents:nil attributes:nil];
    }
    
     self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_destinationPath];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data {
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    
    NSUInteger currentLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:_destinationPath error:nil] objectForKey:NSFileSize] integerValue];
    NSUInteger totalLength = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@",_urlStr,totalLengthKey]];
    
    float progress = (float) currentLength / totalLength;
    
    if (_pregress) {
         self.pregress(progress,currentLength,totalLength);
    }
    
    NSDictionary *downloadInfo = @{@"url_str":_urlStr,@"progress":@(progress)};
    [[NSNotificationCenter defaultCenter] postNotificationName:JXConnectionDownloadProgressChangedNotification object:nil userInfo:downloadInfo];
    
    [[NSUserDefaults standardUserDefaults] setFloat:progress forKey:[NSString stringWithFormat:@"%@progresss",_urlStr]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:JXConnectionDownloadFinishedNotification object:nil userInfo:@{@"url_str":_urlStr}];
    if (_completion) {
        self.completion();
    }
    
    
}


+ (float)lastProgressWithURL:(NSString *)urlStr {
    if (urlStr) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"%@progress",urlStr]];
    }
    return 0.0;
}

+ (NSString *)convertSize:(NSUInteger) size {
    NSString *sizeString = nil;
    if (size < 1024) {
        sizeString = [NSString stringWithFormat:@"%ldB",(NSUInteger)size];
    }else if (size >= 1024 && size < 1024 * 1024) {
        sizeString = [NSString stringWithFormat:@"%.1fKB",(float)size / 1024];
    }else if (size >= 1024 * 1024 && size < 1024 * 1024 * 1024){
        sizeString = [NSString stringWithFormat:@"%.1fMB",(float)size / (1024 * 1024)];
    }else {
        sizeString = [NSString stringWithFormat:@"%.1fGB",(float)size / (1024 * 1024 *1024)];
    }
    
    return sizeString;
}

+ (NSString *)fileSizeWithURL:(NSString *)urlStr {
    float progress = [[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"%@progress",urlStr]];
    NSUInteger totalLength = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@totalLength",urlStr]];
    
    NSUInteger currentLength = progress * totalLength;
    NSString *currentSize = [self convertSize:currentLength];
    NSString *totalSize = [self convertSize:totalLength];
    
    return [NSString stringWithFormat:@"%@/%@",currentSize,totalSize];
}



@end
