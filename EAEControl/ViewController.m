//
//  ViewController.m
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import "ViewController.h"
#import "UserData.h"
#define MAX_LENGTH 60

@interface ViewController ()
{
    UserData    *userName;
    UIAlertView *alert;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    userName = [UserData new];
    alert          = [UIAlertView new];
    alert.delegate = self;
    [self generateUI];
}

-(void)generateUI
{
    [self generateLabel];
    [self generateTextField];
    [self generateButton];
}

-(void)generateTextField
{
    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.userNameTextField.delegate = self;
    [self.view addSubview:self.userNameTextField];
    self.userNameTextField.center = self.view.center;
    NSString *resisteredUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (resisteredUserName) {
        self.userNameTextField.text = resisteredUserName;
    }
    self.userNameTextField.borderStyle = UITextBorderStyleLine;
}

-(void)generateLabel
{
    self.registerUserNameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_W * 0.5 - 100, SCREEN_H * 0.5 - 70, 100, 50)];
    self.registerUserNameLabel.text = @"ユーザネーム";
    [self.view addSubview:self.registerUserNameLabel];
}

/**
 * @brief ユーザネームを登録するためのボタンを生成する関数
 */
-(void)generateButton
{
    self.registerUserNameButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_W * 0.25),
                                                                              SCREEN_H * 0.7,
                                                                              SCREEN_W * 0.5,
                                                                              SCREEN_W * 0.5 * 0.35)
    ];
    [self.registerUserNameButton setTitle:@"ユーザ登録"
                                 forState:UIControlStateNormal];
    [self.registerUserNameButton addTarget:self
                                    action:@selector(registerUserName)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerUserNameButton];
    self.registerUserNameButton.backgroundColor = [UIColor redColor];
}

/**
 * @breif ユーザネームを登録する関数
 *
 */
-(void)registerUserName
{
    NSString *inputTextField = self.userNameTextField.text;
    if([inputTextField isEqual:@""]) {
        [self showMessage:@"警告" message:@"1文字以上入力してください"];
        return;
    }
    NSString *resisteredUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if([resisteredUserName isEqual:inputTextField]) {
        [self showMessage:@"警告" message:@"入力されたユーザー名は\n既に登録されています"];
        return;
    }
    [userName regiserUserName:inputTextField];
    if([resisteredUserName isEqual:@""]) {
        [self showMessage:@"確認" message:@"登録完了"];
        return;
    }
    [self showMessage:@"確認" message:@"更新完了"];
}

- (void)didReceiveMemoryWarning
{
    FUNC();
    [super didReceiveMemoryWarning];
}

#pragma mark-<textField>

/**
 * @breif キーボードでReturnキー選択時のイベントハンドラ
 *
 * @param textField イベントが発生したテキストフィールド
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    FUNC();
    [self.view endEditing:YES];
    return YES;
}

/**
 * @breif テキストが編集されたとき
 *
 * @param  textField イベントが発生したテキストフィールド
 * @param  range     文字列が置き換わる範囲(入力された範囲)
 * @param  string    置き換わる文字列(入力された文字列)
 * @retval YES 入力を許可する場合
 * @retval NO  許可しない場合
 */
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string
{
    FUNC();
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    return ([text length] <= MAX_LENGTH);
}

/**
 * @breif ユーザネームテキストフィールドの入力に関するポップアップメッセージを表示する関数
 *
 * @param title   ポップアップのタイトル
 * @param message ポップアップのメッセージ
 */
-(void)showMessage:(NSString *)title
           message:(NSString *)message
{
    alert.title   = title;
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}
@end
