//
//  ApiManager.m
//  common
//
//  Created by Yohei Sashikata on 2015/06/23.
//  Copyright (c) 2015年 Yohei Sashikata. All rights reserved.
//

#import "ApiManager.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

@interface ApiManager () <UIAlertViewDelegate>

@end

@implementation ApiManager
{
    void (^_callbackComplete)(NSDictionary *result);
    void (^_callbackError)(NSDictionary *result);

    NSMutableData *_receivedData;

    NSString *_url;
    
    int _apiErrorCode;

    NSString *_deviceInfo;
    NSString *_version;
    NSString *_installId;
    NSString *_token;
}

- (id)init:(NSString *)version installId:(NSString *)installId
{
	self = [super init];
	if(self != nil) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *tmpMachine = malloc(size);
        sysctlbyname("hw.machine", tmpMachine, &size, NULL, 0);
        NSString *machine = [NSString stringWithCString:tmpMachine encoding: NSUTF8StringEncoding];
        free(tmpMachine);
        _deviceInfo = [NSString stringWithFormat:@"%@ %@ %@", machine, [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
        _version   = version;
        _installId = installId;
        NSLog(@"       _version:%@", _version);
        NSLog(@"     _installId:%@", _installId);
        /*
        //token = md5(インストールID + 秘密鍵);
        _token = [[CONCAT(_installId, SECRET_KEY) dataUsingEncoding:NSUTF8StringEncoding] MD5];
        LOG(@"     CONCAT(_installId, SECRET_KEY):%@", CONCAT(_installId, SECRET_KEY));
        LOG(@"     _token:%@", _token);
        */
    }
	return self;
}

- (void)connect:(NSString *)url postData:(NSDictionary *)postData complete:(void (^)(NSDictionary *result))callbackComplete error:(void (^)(NSDictionary *result))callbackError
{
    FUNC();
    NSLog(@"【%@】", url);
    _url = url;
    _callbackComplete = callbackComplete;
    _callbackError = callbackError;
    
    NSString *param = @"";
    param = [param stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"install_id", _installId]];
    param = [param stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", @"device_info", _deviceInfo]];
    if(!postData[@"token"]) {
        param = [param stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", @"token", _token]];
    }
    
    for(id key in [postData keyEnumerator]) {
        NSString *value = [postData valueForKey:key];
        NSLog(@"        Key:%@ Value:%@", key, value);
        param = [param stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, value]];
    }
    NSLog(@"        param:%@", param);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:300];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(self.connection) {
        _receivedData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ApiManager Connection failed! Error - %@ %@",
    [error localizedDescription],
    [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    _callbackError(result);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *respons = [NSJSONSerialization JSONObjectWithData:_receivedData options:0 error:&error];
    if(error) {
        NSLog(@" api error:%@", error);
    }
    NSLog(@"receivedData: %@", _receivedData);
    int status;
    if(error) {
        status = 1;
    } else {
        status = [[respons objectForKey:@"status"] intValue];
    }
    NSLog(@"status:%d", status);

    if(status == 0) {
        NSDictionary *data = [respons objectForKey:@"data"];
        NSLog(@"major=%@", [data objectForKey:@"major"]);
        _callbackComplete(respons);

    } else {
        self.lastErrorStatus        = ITOSTR(status);
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"status"]           = ITOSTR(status);
        _callbackError(result);
    }
    _receivedData = [NSMutableData data];
}

@end
