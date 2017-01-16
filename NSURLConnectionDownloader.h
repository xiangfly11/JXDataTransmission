//
//  NSURLConnectionDownloader.h
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 16/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 * The notification of downloading is finished.
 */
static NSString *const JXConnectionDownloadFinishedNotification = @"ConnectionDownloadFinished";


/**
 *The notification of downloading progress is changed.
*/
static NSString *const JXConnectionDownloadProgressChangedNotification = @"ConnnectionDownloadProgressChanged";



/**
 The block is called after downloading is finished.
 */
typedef void(^completionBlock)();

/**
 The block is called while downloading is processing.

 @param progress float value between 0 to 1.0 which indicate currentLength / totalLength
 @param currentLength the size of data is already download
 @param totalLength the total size of data should be download
 */
typedef void(^progressBlock)(float progress,NSUInteger currentLength,NSUInteger totalLength);


/**
 The block is called while downloading error.

 @param error error information come from system.
 */
typedef void(^failureBlock)(NSError *error);

@interface NSURLConnectionDownloader : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic,copy,readonly) completionBlock completion;
@property (nonatomic,copy,readonly) progressBlock progress;
@property (nonatomic,copy,readonly) failureBlock failure;


/**
 Class method to get downloader instance

 @return NSURLConnectionDownloader instance.
 */
+ (instancetype)downloader;


/**
 Start download or resume download.

 @param urlStr download url string.
 @param destinationPath destination path to store download data.
 @param progress progress block to indicate download processing.
 @param completion completion block to indicate download completion.
 @param failure failure block to indicate download failure.
 */
- (void)downloadWithURLString:(NSString *) urlStr toPath:(NSString *) destinationPath progressBlock:(progressBlock) progress completionBlock:(completionBlock) completion failureBlock:(failureBlock) failure;


/**
 Cancel downloading.
 */
- (void)cancel;

@end
