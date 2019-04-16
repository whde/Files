//
//  MessageView.m
//  Files
//
//  Created by Whde on 2019/4/16.
//  Copyright © 2019年 Whde. All rights reserved.
//

#import "MessageView.h"


static NSDictionary *msgDic = nil;
@interface MessageView() {
    UILabel *messageLabel;
}

@end
@implementation MessageView
/**
 创建一个消息对象, 不包含显示部分
 
 @param msg 显示内容
 @return 消息对象
 */
+ (MessageView *)messageWith:(NSString *)msg {
    if (!msg || ([msg isKindOfClass:[NSString class]]&&msg.length<=0)) {
        return nil;
    }
    MessageView *msgView = [[MessageView alloc] initWithMsg:msg];
    return msgView;
}


/*!
 *  显示提示
 */
+ (void)showMsg:(NSString *)msg{
    [[MessageView messageWith:msg] show];
}

/**
 *  创建消息提示
 */
- (id)initWithMsg:(NSString *)msg{
    CGSize screenSize=[UIScreen mainScreen].bounds.size;
    CGSize msgSize=[msg boundingRectWithSize:CGSizeMake(screenSize.width-40, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} context:nil].size;
    CGRect rect=CGRectMake((screenSize.width-(msgSize.width+20))/2.0, screenSize.height-120, msgSize.width+20, msgSize.height+10);
    self = [super initWithFrame:rect];
    if (self) {
        [self getWithMessageViewFromMsg:msg];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgtound) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

/**
 *  加载消息框对象
 */
-(void)getWithMessageViewFromMsg:(NSString *)msg{
    
    self.layer.cornerRadius=0;
    self.layer.masksToBounds=YES;
    self.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.500];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,self.frame.size.width-20, self.frame.size.height-10)];
    messageLabel.font = [UIFont boldSystemFontOfSize:14.f];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = msg;
    messageLabel.numberOfLines = 0;
    messageLabel.backgroundColor=[UIColor clearColor];
    [self addSubview:messageLabel];
}

-(void)getWithMessageViewWithActivityFromMsg:(NSString *)msg{
    
    self.layer.cornerRadius=0;
    self.layer.masksToBounds=YES;
    self.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.500];
    
    CGRect rect = self.frame;
    rect.size.width = CGRectGetWidth(self.frame)+20;
    self.frame = rect;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.frame = CGRectMake(0, 0, 30, CGRectGetHeight(self.frame));
    [activity startAnimating];
    [self addSubview:activity];
    
    messageLabel= [[UILabel alloc] initWithFrame:CGRectMake(30, 5,self.frame.size.width-35, self.frame.size.height-10)];
    messageLabel.font = [UIFont boldSystemFontOfSize:14.f];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = msg;
    messageLabel.numberOfLines = 0;
    messageLabel.backgroundColor=[UIColor clearColor];
    [self addSubview:messageLabel];
}

/**
 *  显示提示
 */
-(void)show{
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    //加载对象到UI
    [((UIWindow *)[[UIApplication sharedApplication] windows][0]) addSubview:self];
    //退出动画
    [self viewAnimation];
}


/**
 进入后台后将直接移除
 */
- (void)enterBackgtound {
    dispatch_main_async_safe_el(^{
        if (self.superview) {
            [self removeFromSuperview];
        }
    });
}

/**
 *  显示提示
 */
-(void)showAtTop {
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = -64;
    rect.size.width = SCREEN_WIDTH;
    rect.size.height = (iPhoneX||iPhoneXR||iPhoneXS||iPhoneXSMax) ? 88 : 64;
    self.frame = rect;
    if ((iPhoneX||iPhoneXR||iPhoneXS||iPhoneXSMax)) {
        messageLabel.frame = CGRectMake(0, 22 , SCREEN_WIDTH, self.frame.size.height -22);
        messageLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        messageLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height);
    }
    messageLabel.font = [UIFont systemFontOfSize:16];
    messageLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:253/255.0 green:172/255.0 blue:5/255.0 alpha:1/1.0];
    //加载对象到UI
    [((UIWindow *)[[UIApplication sharedApplication] windows][0]) addSubview:self];
    //退出动画
    self.alpha = 0.7;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = 0;
        self.frame = rect;
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f animations:^{
            self.alpha = 0.99;
        } completion:^(BOOL finished) {
            if (finished == YES) {
                [UIView animateWithDuration:.5f animations:^{
                    CGRect rect = self.frame;
                    rect.origin.y = (iPhoneX||iPhoneXR||iPhoneXS||iPhoneXSMax) ? -88 : -50;
                    self.frame = rect;
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }
        }];
    }];
}

/**
 *  显示提示
 */
-(void)showInCenter{
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    UIWindow *window = ((UIWindow *)[[UIApplication sharedApplication] windows][0]);

    self.center = window.center;
    //加载对象到UI
    [window addSubview:self];
    //退出动画
    [self viewAnimation];
}

/**
 *  显示提示
 */
-(void)showInBottomCenter {
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    UIWindow *window = ((UIWindow *)[[UIApplication sharedApplication] windows][0]);
    self.center = CGPointMake(window.center.x, window.frame.size.height-window.center.y/2);
    //加载对象到UI
    [window addSubview:self];
    //退出动画
    [self viewAnimation];
}

/**
 *  显示提示
 */
-(void)showInBottom {
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    UIWindow *window = ((UIWindow *)[[UIApplication sharedApplication] windows][0]);
    self.center = CGPointMake(window.center.x, window.frame.size.height-TAB_BAR_HEIGHT-window.center.y/4);
    //加载对象到UI
    [window addSubview:self];
    //退出动画
    [self viewAnimation];
}

/**
 *  退出动画
 */
-(void)viewAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f animations:^{
            self.alpha = 0.95;
        } completion:^(BOOL finished) {
            if (finished == YES) {
                [UIView animateWithDuration:.5f animations:^{
                    self.alpha = .1;
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }
        }];
    }];
}

/**
 *  创建MessageView
 *
 *  @param msg    文字
 *  @param center 是否居中
 *
 *  @return MessageView
 */
- (id)initWithMsg:(NSString *)msg showInCenter:(BOOL)center{
    CGSize screenSize=[UIScreen mainScreen].bounds.size;
    CGSize msgSize=[msg boundingRectWithSize:CGSizeMake(screenSize.width-40, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} context:nil].size;
    CGRect rect=CGRectMake((screenSize.width-(msgSize.width+20))/2.0, screenSize.height-120, msgSize.width+20, msgSize.height+10);
    self = [super initWithFrame:rect];
    if (self) {
        [self getWithMessageViewWithActivityFromMsg:msg];
        if (center) {
            self.center = ((UIWindow *)[[UIApplication sharedApplication] windows][0]).center;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgtound) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

/**
 *  显示-没有自动隐藏
 */
- (void)showNoDismiss{
    for (UIView *view in [((UIWindow *)[[UIApplication sharedApplication] windows][0]) subviews]) {
        // 移除旧的对象
        if ([view isKindOfClass:[MessageView class]]) {
            [view removeFromSuperview];
        }
    }
    //加载对象到UI
    [((UIWindow *)[[UIApplication sharedApplication] windows][0]) addSubview:self];
}

/**
 *  隐藏
 */
- (void)dismiss{
    NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
    [UIView animateWithDuration:0.3f delay:0 options:options animations:^{
        self.alpha = 0.95;
    } completion:^(BOOL finished) {
        if (finished == YES) {
            [UIView animateWithDuration:.3f delay:0 options:options animations:^{
                self.alpha = .1;
            } completion:^(BOOL finished) {
                // UIActivityIndicatorView停止转动
                for (UIView *view in self.subviews) {
                    if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
                        [(UIActivityIndicatorView *)view stopAnimating];
                    }
                }
                [self removeFromSuperview];
            }];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


