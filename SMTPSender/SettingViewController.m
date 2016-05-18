//
//  SettingViewController.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/4/21.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()


@property (nonatomic, strong) UITextField *subjectTextField;

@property (nonatomic, strong) UITextField *sendTextField;
@property (nonatomic, strong) UITextField *sendPassword;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(onOkTouch:)];
    [self initTextFields];
    [self configTextFieldValue];
}

- (void)configTextFieldValue{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _subjectTextField.text = [userDefault objectForKey:EmailSubject];
    _sendTextField.text = [userDefault objectForKey:EmailUserName];
    _sendPassword.text = [userDefault objectForKey:EmailPassword];
}

- (void)initTextFields{
    
    UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(20, 20+50+20, kScreenSize.width - 40, 25)];
    textfield1.placeholder = @"邮件标题";
    textfield1.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textfield1];
    self.subjectTextField = textfield1;
    
    UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(20, 50+50+5+20, kScreenSize.width - 40, 25)];
    textfield2.placeholder = @"邮箱账号";
    textfield2.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textfield2];
    self.sendTextField = textfield2;
    
    UITextField *textfield3 = [[UITextField alloc] initWithFrame:CGRectMake(20, 80+50+10+20, kScreenSize.width - 40, 25)];
    textfield3.placeholder = @"邮箱密码";
    textfield3.borderStyle = UITextBorderStyleRoundedRect;
    textfield3.secureTextEntry = YES;
    [self.view addSubview:textfield3];
    self.sendPassword = textfield3;
}

- (void)onOkTouch:(id)sender{
    
    if (!_subjectTextField.text.length) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邮件标题不能为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (!_sendTextField.text.length) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邮箱账号不能为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (!_sendPassword.text.length) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邮箱密码不能为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:_subjectTextField.text forKey:EmailSubject];
    [userDefault setObject:_sendTextField.text forKey:EmailUserName];
    [userDefault setObject:_sendPassword.text forKey:EmailPassword];
    [userDefault synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
