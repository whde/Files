//
//  IPHelper.h
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPHelper : NSObject

/** 获取ip地址 */
+ (NSString *)deviceIPAdress;

#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
