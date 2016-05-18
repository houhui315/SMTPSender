//
//  fileModel.h
//  CheckWorkAttendance
//
//  Created by 蓝泰致铭        on 16/4/13.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, assign) long long fileSize;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, assign) BOOL isProcessCompleted;
//邮件总数
@property (nonatomic, assign) NSUInteger totalNumber;

@property (nonatomic, strong) NSString *alreadySendArray;

@end
