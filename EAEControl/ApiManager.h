//
//  ApiManager.h
//  common
//
//  Created by Yohei Sashikata on 2015/06/23.
//  Copyright (c) 2015年 Yohei Sashikata. All rights reserved.
//

@interface ApiManager : NSObject

@property (readwrite, strong, nonatomic) NSURLConnection *connection;
@property (readwrite, strong, nonatomic) NSString *lastErrorStatus;

- (id)init:(NSString *)version installId:(NSString *)installId;
- (void)connect:(NSString *)apiName postData:(NSDictionary *)postData complete:(void (^)(NSDictionary *result))callbackComplete error:(void (^)(NSDictionary *result))callbackError;

@end
