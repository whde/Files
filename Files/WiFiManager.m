//
//  WiFiManager.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import "WiFiManager.h"
#import "GCDWebUploader.h"
#import "IPHelper.h"

@interface WiFiManager () <GCDWebUploaderDelegate> {
    GCDWebUploader * _webServer;
}
@end

@implementation WiFiManager

- (BOOL)start {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    _webServer.title = @"WiFi";
    _webServer.prologue = @"欢迎使用WIFI管理平台";
    _webServer.epilogue = @"Whde";
    if ([_webServer start]) {
        self.ip = [IPHelper deviceIPAdress];
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
