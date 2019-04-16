//
//  MessageView.h
//  Files
//
//  Created by Whde on 2019/4/16.
//  Copyright © 2019年 Whde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

/**
 创建一个消息对象, 不包含显示部分

 @param msg 显示内容
 @return 消息对象
 */
+ (MessageView *)messageWith:(NSString *)msg;

+ (void)showMsg:(NSString *)msg;

/**
 *  创建消息提示
 *
 *  @param msg 提示内容
 *
 *  @return self
 */
- (id)initWithMsg:(NSString *)msg;

/**
 *  显示提示
 */
-(void)show;
-(void)showAtTop;
-(void)showInCenter;
-(void)showInBottomCenter;
-(void)showInBottom;

/**
 *  创建MessageView
 *
 *  @param msg    文字
 *  @param center 是否居中
 *
 *  @return MessageView
 */
- (id)initWithMsg:(NSString *)msg showInCenter:(BOOL)center;

/**
 *  显示-没有自动隐藏
 */
- (void)showNoDismiss;

/**
 *  隐藏
 */
- (void)dismiss;

@end
