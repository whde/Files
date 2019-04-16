//
//  ELFileManager.h
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileModel;

@interface FileManager : NSObject

+ (instancetype)shareManager;
- (FileModel *)getFileWithPath:(NSString *)path;
- (NSArray *)getAllFileWithPath:(NSString *)path;
- (NSArray *)getAllFileInPathWithSurfaceSearch:(NSString *)path;
- (NSArray *)getAllFileInPathWithDeepSearch:(NSString *)path;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (BOOL)createFolderToPath:(NSString *)path folderName:(NSString *)name;
- (BOOL)createFolderToFullPath:(NSString *)fullPath;
- (BOOL)createFileToPath:(NSString *)path fileName:(NSString *)name;
- (BOOL)createFileToFullPath:(NSString *)fullPath;
- (BOOL)addFile:(id)file toPath:(NSString *)path fileName:(NSString *)name;
- (BOOL)deleteFileWithPath:(NSString *)path;
- (BOOL)moveFile:(NSString *)oldPath toNewPath:(NSString *)newPath;
- (BOOL)copyFile:(NSString *)oldPath toNewPath:(NSString *)newPath;
- (BOOL)renameFileWithPath:(NSString *)path oldName:(NSString *)oldName newName:(NSString *)newName;
- (NSArray *)searchSurfaceFile:(NSString *)searchText folderPath:(NSString *)folderPath;
- (NSArray *)searchDeepFile:(NSString *)searchText folderPath:(NSString *)folderPath;
- (NSData *)readDataFromFilePath:(NSString *)filePath;
- (void)seriesWriteContent:(NSData *)contentData intoHandleFile:(NSString *)filePath;
@end


