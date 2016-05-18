//
//  MessageModel.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/5/17.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

- (instancetype)initWithName:(NSString*)name email:(NSString*)email content:(NSString*)content index:(NSInteger)index {
    
    if (self = [super init]) {
        
        self.name = name;
        self.email = email;
        self.content = content;
        self.index = index;
        self.sendStatus = sendStatus_waiting;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeInteger:self.index forKey:@"index"];
    [aCoder encodeInteger:self.sendStatus forKey:@"sendStatus"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.email = [aDecoder decodeObjectForKey:@"email"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.index = [aDecoder decodeIntegerForKey:@"index"];
    self.sendStatus = [aDecoder decodeIntegerForKey:@"sendStatus"];
    
    return self;
}

@end
