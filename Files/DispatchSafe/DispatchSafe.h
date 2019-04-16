//
//  DispatchSafe.h
//  Files
//
//  Created by Whde on 2019/4/16.
//  Copyright © 2019年 Whde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DispatchSafe : UIView
typedef void(^block)(void);

/**
 将代码块放到主线程中执行,如果已经在主线程,将直接执行
 
 @param block 代码块
 */
void dispatch_main_async_safe_el(block block);

/**
 将代码块放到子线程中执行,如果已经在子线程中,将直接执行
 
 @param block 代码块
 */
void dispatch_global_async_safe_el(block block);

@end
