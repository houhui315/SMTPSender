//
//  SendEmailTableViewController.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/4/22.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "SendEmailTableViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "WebViewController.h"
#import "MessageSendCell.h"


@interface SendEmailTableViewController ()<SKPSMTPMessageDelegate>{
    
    NSUInteger currentNumber;
    NSUInteger totalNumber;
    
    NSUInteger alreadySendNumber; //已发送
    NSUInteger sendFailedNumber; //发送失败
    NSUInteger sendIngNumber; //发送中
    
    BOOL isSending;
    
    NSTimer *timer;

}

@property (nonatomic, strong) NSMutableArray *allDataArray;

@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation SendEmailTableViewController

- (void)dealloc{
    
    [super dealloc];
    timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[MessageSendCell class] forCellReuseIdentifier:messageSendCell];
    
    if (_model.isProcessCompleted) {
        
        self.title = @"已发送完成";
    }else{
        
        self.title = @"等待发送";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始发送" style:UIBarButtonItemStyleDone target:self action:@selector(startToSendEmail)];
    }
    
    [self processData];
}


- (void)startToSendEmail{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *subject = [userDefault objectForKey:EmailSubject];
    if (!subject || !subject.length) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前不能发送" message:@"请前往设置里设置好后再发送" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (isSending) {
        return;
    }
    isSending = YES;
    
//    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送中" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    currentNumber = 0;
    sendFailedNumber = 0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendEmailTimer:) userInfo:nil repeats:YES];
}

- (void)updateStatusLabel{
    
    self.statusLabel.text = [NSString stringWithFormat:@"总数:%ld 已发送:%ld 发送失败:%ld 发送中:%ld",(unsigned long)totalNumber,alreadySendNumber,sendFailedNumber,sendIngNumber];
}

- (void)sendEmailTimer:(NSTimer*)tm {
    
    if (currentNumber < totalNumber) {
        
        BOOL needSend = YES;
        NSInteger tempNum = currentNumber - 1;
        do {
            tempNum++;
            if (tempNum < totalNumber) {
                MessageModel *msgModel =  self.allDataArray[tempNum];
                needSend = (msgModel.sendStatus == sendStatus_waiting) || (msgModel.sendStatus == sendStatus_failed);
            }else{
                needSend = NO;
                break;
            }
            
        } while (!needSend);
        
        if (needSend) { //需要发送
            currentNumber = tempNum;
            
            self.title = @"发送中";
            
            [self sendMessageWithIndex:currentNumber];
            currentNumber++;
        }else{ //不需要发送
            
            [timer invalidate];
            timer = nil;
            [self performSelector:@selector(showSendStatus) withObject:nil afterDelay:3];
        }
        
    }else{
        
        [timer invalidate];
        timer = nil;
        [self performSelector:@selector(showSendStatus) withObject:nil afterDelay:3];
    }
}

- (void)showSendStatus{
    
    NSInteger successNum = 0;
    NSInteger failedNum = 0;
    NSInteger sendingNum = 0;
    
    for (NSInteger i = 0; i < totalNumber; i++) {
        
        MessageModel *msgModel =  self.allDataArray[i];
        switch (msgModel.sendStatus) {
            case sendStatus_success:
            {
                successNum++;
            }break;
            case sendStatus_failed:
            {
                failedNum++;
            }break;
            case sendStatus_sending:
            {
                sendingNum++;
            }break;
                
            default:
                break;
        }
    }
    
    if (successNum == totalNumber){
        
        isSending = NO;
        
        self.title = @"已发送完成";
        self.navigationItem.rightBarButtonItem = nil;
        _model.isProcessCompleted = YES;
    }
    if (sendIngNumber == 0) {
        
        isSending = NO;
        
        self.title = @"等待发送";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始发送" style:UIBarButtonItemStyleDone target:self action:@selector(startToSendEmail)];
        
        
    }
//    [self.navigationItem setHidesBackButton:NO];
    
}



- (void)processData{
    
    self.allDataArray = [NSMutableArray array];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *senderUserEmail = [userDefault objectForKey:EmailUserName];
    
    NSArray *ziduanArray = @[@"DepartmentName",@"UserNumber",@"UserName",@"GangweiMoney",@"JixiaoMoney",@"KaoheWait",@"KaoheScore",@"KaoheMoney",@"JiabanMoney",@"KouQueqin",@"YingFaMoney",@"SocialSecurity",@"housingfund",@"PersonalIncomeTax",@"OtherMoney",@"RealMoney",@"ProvMonthDay",@"NowMonthDay",@"ProvMonthYearDay",@"NowMonthYearDay",@"Theirdistrict"];
    
    fileModelTool *tool = [fileModelTool new];
    NSString *path = [tool.inBoxDictionaryPath stringByAppendingPathComponent:_model.fileName];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"工资表2016. 3" ofType:@"csv"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!contents) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        contents = [[NSString alloc] initWithData:data encoding:enc];
    }
    
    contents = [contents stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    contents = [contents stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    contents = [contents stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray *dataArray = [contents componentsSeparatedByString:@"\n"];
    
    totalNumber = 0;
    
    NSArray *sendedAry = [_model.alreadySendArray componentsSeparatedByString:@","];
    
    for (NSUInteger i = 1; i < dataArray.count; i++) {
        
        NSString *myString = dataArray[i];
        if (myString && myString.length) {
            
            NSArray *myArray = [myString componentsSeparatedByString:@","];
            NSString *firstString = myArray[0];
            if (!firstString || !firstString.length) {
                continue;
            }
            NSString *contentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mail" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            NSString *name = @"";
            NSString *email = @"";

            for (NSUInteger j = 0; j < myArray.count; j++) {
                
                NSString *string = myArray[j];
                if (!string || !string.length) {
                    string = @"-";
                }
                if (j == 2) {
                    name = string;
                }
                if (j == myArray.count -1){
                    email = string;
                }else{
                    contentString = [contentString stringByReplacingOccurrencesOfString:ziduanArray[j] withString:string];
                }
            }
            //如果接受者里有发送者则不加进去
            if (![email isEqualToString:senderUserEmail]) {
                
                MessageModel *model = [[MessageModel alloc] initWithName:name email:email content:contentString index:totalNumber];
                if ([sendedAry containsObject:[NSString stringWithFormat:@"%ld",(unsigned long)totalNumber]]) {
                    model.sendStatus = sendStatus_success;
                }
                
                [self.allDataArray addObject:model];
                
                totalNumber ++;
            }
        }
    }
    
    _model.totalNumber = totalNumber;
    [self.tableView reloadData];
    
    if ([[sendedAry firstObject] isEqualToString:@""]) {
        alreadySendNumber = 0;
    }else{
        alreadySendNumber = [sendedAry count];
    }
    
    [self performSelector:@selector(updateStatusLabel) withObject:nil afterDelay:1];
}

- (NSString*)getSendSuccessArray{
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < self.allDataArray.count; i++) {
        
        MessageModel *msgModel =  self.allDataArray[i];
        if (msgModel.sendStatus == sendStatus_success) {
            
            [array addObject:@(i)];
        }
    }
    
    NSString *string = [array componentsJoinedByString:@","];
    return string;
}

- (void)saveStatus{
    
    _model.alreadySendArray = [self getSendSuccessArray];
    fileModelTool *tool = [fileModelTool new];
    [tool changeFileModelStatusWithModel:_model];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDEDFILENOTIFICATION object:nil];
}

- (void)sendMessageWithIndex:(NSUInteger)index {
    
    MessageModel *msgModel =  self.allDataArray[index];
    msgModel.sendStatus = sendStatus_sending;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    sendIngNumber++;
    [self updateStatusLabel];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *fromEmail = [userDefault objectForKey:EmailUserName];
    NSString *toEmail = msgModel.email;
    NSString *relayHost = @"smtp.exmail.qq.com";
    NSString *passwd = [userDefault objectForKey:EmailPassword];
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = fromEmail;
    testMsg.toEmail = toEmail;
    testMsg.relayHost = relayHost;
    testMsg.requiresAuth = YES;
    testMsg.login = fromEmail;
    testMsg.pass = passwd;
    testMsg.wantsSecure = YES;
    testMsg.index = index;
    
    testMsg.subject = [userDefault objectForKey:EmailSubject];
    //testMsg.bccEmail = @"testbcc@test.com";
    
    // Only do this for self-signed certs!
    // testMsg.validateSSLChain = NO;
    testMsg.delegate = self;
    NSString *contentString = msgModel.content;
    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/html",kSKPSMTPPartContentTypeKey,contentString,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [testMsg send];
    });
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    MessageModel *msgModel =  self.allDataArray[message.index];
    msgModel.sendStatus = sendStatus_success;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:message.index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    sendIngNumber --;
    alreadySendNumber++;
    
    [self saveStatus];
    [self showSendStatus];
    [self updateStatusLabel];
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    MessageModel *msgModel =  self.allDataArray[message.index];
    msgModel.sendStatus = sendStatus_failed;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:message.index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    sendIngNumber --;
    sendFailedNumber++;
    
    [self updateStatusLabel];
    [self showSendStatus];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.allDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageSendCell *cell = [tableView dequeueReusableCellWithIdentifier:messageSendCell forIndexPath:indexPath];
    
    MessageModel *model = self.allDataArray[indexPath.row];
    [cell configureForModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WebViewController *webViewVC = [WebViewController new];
    MessageModel *model = self.allDataArray[indexPath.row];
    webViewVC.title = model.name;
    webViewVC.contentString = model.content;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, 20)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14.f];
    self.statusLabel = label;
    [view addSubview:label];
    
    return view;
}

@end
