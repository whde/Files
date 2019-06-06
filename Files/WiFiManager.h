//
//  WiFiManager.h
//  iOSHttpServer
//
//  Created by ziv on 2017/2/9.
//  Copyright © 2017年 ziv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiManager : NSObject
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *port;
- (BOOL)start;
- (void)stop;
@property(nonatomic, copy) void (^changed)(void);
@end
