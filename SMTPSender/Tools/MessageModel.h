//
//  MessageModel.h
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/5/17.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, sendStatus) {
    
    //等待发送
    sendStatus_waiting,
    //发送成功
    sendStatus_success,
    //发送中
    sendStatus_sending,
    //发送失败
    sendStatus_failed
};

@interface MessageModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *content;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) sendStatus sendStatus;

- (instancetype)initWithName:(NSString*)name email:(NSString*)email content:(NSString*)content index:(NSInteger)index;

@end
