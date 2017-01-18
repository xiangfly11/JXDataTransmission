//
//  TaskModel.h
//  JXDataTransmission
//
//  Created by Jiaxiang Li on 18/01/2017.
//  Copyright © 2017 jiaxiang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,strong) NSString *destinationPath;

@end
