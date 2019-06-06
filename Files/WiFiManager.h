//
//  WiFiManager.h
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiManager : NSObject
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *port;
- (BOOL)start;
- (void)stop;
@property(nonatomic, copy) void (^changed)(void);
@end
