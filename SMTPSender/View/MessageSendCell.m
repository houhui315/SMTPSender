//
//  MessageSendCell.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/5/17.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "MessageSendCell.h"

@interface MessageSendCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation MessageSendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    nameLabel.font = [UIFont systemFontOfSize:18.f];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 90, 10, 70, 20)];
    statusLabel.font = [UIFont systemFontOfSize:14.f];
    statusLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:statusLabel];
    self.statusLabel = statusLabel;
}

- (void)configureForModel:(MessageModel*)model{
    
    self.nameLabel.text = model.name;
    switch (model.sendStatus) {
        case sendStatus_waiting:
        {
            self.statusLabel.text = @"等待发送...";
            self.statusLabel.textColor = [UIColor blackColor];
        }break;
        case sendStatus_success:
        {
            self.statusLabel.text = @"已发送";
            self.statusLabel.textColor = [UIColor blackColor];
        }break;
        case sendStatus_sending:
        {
            self.statusLabel.text = @"发送中...";
            self.statusLabel.textColor = [UIColor orangeColor];
        }break;
        case sendStatus_failed:
        {
            self.statusLabel.text = @"发送失败";
            self.statusLabel.textColor = [UIColor redColor];
        }break;
            
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
