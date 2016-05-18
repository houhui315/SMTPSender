//
//  MessageSendCell.h
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/5/17.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"


static NSString *messageSendCell = @"MessageSendCell";

@interface MessageSendCell : UITableViewCell

- (void)configureForModel:(MessageModel*)model;

@end
