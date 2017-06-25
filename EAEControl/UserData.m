//
//  UserData.m
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import "UserData.h"

@implementation UserData

-(id)init
{
    if(self = [super init]) {
        self.userInfo = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(void)regiserUserName:(NSString *)userName
{
    FUNC();
    [self.userInfo setObject:userName forKey:@"userName"];
    [self postRegiserUserName];
}

-(void)removeUserName
{
    FUNC();
    [self.userInfo removeObjectForKey:@"userName"];
    [self postRemoveUserName];
}

/**
 * @brief サーバーと連携する場合，登録及び更新を行うユーザネームを送信するメソッド
 *
 * @to-do すべて未実装
 */
-(void)postRegiserUserName
{
    FUNC();
}

/**
 * @brief サーバーと連携する場合，削除を行うユーザネームを送信するメソッド
 *
 * @to-do すべて未実装
 */
-(void)postRemoveUserName
{
    FUNC();
}
@end
