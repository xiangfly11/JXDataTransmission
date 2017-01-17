//
//  NSURLConnectionManager.h
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 16/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLConnectionDownloader.h"

@interface NSURLConnectionManager : NSObject


/**
 Signelton way to get NSURLConnectionManager instance
 
 @return NSURLConnectionManager instance
 */
+ (instancetype)sharedManager;

- (void)downloadWithURLString:(NSString *) urlStr toPath:(NSString *) destinationPath progressBlock:(progressBlock) progress completionBlock:(completionBlock) completion failureBlock:(failureBlock) failure;

- (void)cancelDownloadWithURLStr:(NSString *)urlStr;

- (void)removeForURL:(NSString *)urlStr atPath:(NSString *) path;

- (void)cancelAllDownloadTasks;
@end
