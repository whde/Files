//
//  WiFiManager.m
//  iOSHttpServer
//
//  Created by ziv on 2017/2/9.
//  Copyright © 2017年 ziv. All rights reserved.
//

#import "WiFiManager.h"
#import "GCDWebUploader.h"
#import "SJXCSMIPHelper.h"

@interface WiFiManager () <GCDWebUploaderDelegate> {
    GCDWebUploader * _webServer;
}
@end

@implementation WiFiManager

- (BOOL)start {
    
    // 文件存储位置
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"文件存储位置 : %@", documentsPath);
    
    // 创建webServer，设置根目录
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    // 设置代理
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    
    /*
    // 限制文件上传类型
    _webServer.allowedFileExtensions = nil;
    */
    // 设置网页标题
    _webServer.title = @"WiFi";
    // 设置展示在网页上的文字(开场白)
    _webServer.prologue = @"欢迎使用WIFI管理平台";
    // 设置展示在网页上的文字(收场白)
    _webServer.epilogue = @"WiFi·Whde";
    
    if ([_webServer start]) {
        self.ip = [SJXCSMIPHelper deviceIPAdress];
        self.port = [NSString stringWithFormat:@"%zd", _webServer.port];
        return YES;
    } else {
        return NO;
    }
}

- (void)stop {
    [_webServer stop];
    _webServer = nil;
}

#pragma mark - <GCDWebUploaderDelegate>
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
    if (self.changed) {
        self.changed();
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
    if (self.changed) {
        self.changed();
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
    
    if (self.changed) {
        self.changed();
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
    if (self.changed) {
        self.changed();
    }
}

@end
