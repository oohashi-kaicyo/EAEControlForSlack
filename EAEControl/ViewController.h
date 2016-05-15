//
//  ViewController.h
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//


@interface ViewController : UIViewController
<
 UITextFieldDelegate,
 UIAlertViewDelegate
>

@property(nonatomic)UITextField *userNameTextField;
@property(nonatomic)UIButton    *registerUserNameButton;
@property(nonatomic)UILabel     *registerUserNameLabel;

@end

