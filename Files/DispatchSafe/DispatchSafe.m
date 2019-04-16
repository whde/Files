//
//  DispatchSafe.m
//  Files
//
//  Created by Whde on 2019/4/16.
//  Copyright © 2019年 Whde. All rights reserved.
//

#import "DispatchSafe.h"

@implementation DispatchSafe

/**
 将代码块放到主线程中执行,如果已经在主线程,将直接执行
 
 @param block 代码块
 */
void dispatch_main_async_safe_el(block block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 将代码块放到子线程中执行,如果已经在子线程中,将直接执行
 
 @param block 代码块
 */
void dispatch_global_async_safe_el(block block) {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(0, 0), block);
    } else {
        block();
    }
}
@end
