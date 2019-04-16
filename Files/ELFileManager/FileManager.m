//
//  ELFileManager.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import "FileManager.h"
#import "FileModel.h"

@interface FileManager()
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation FileManager
static id instance = nil;
+ (instancetype)shareManager {
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
        return instance;
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (!instance) {
            instance = [super allocWithZone:zone];
        }
        return instance;
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (FileModel *)getFileWithPath:(NSString *)path {
    FileModel *file = [[FileModel alloc] initWithFilePath:path];
    return file;
}

- (NSArray *)getAllFileWithPath:(NSString *)path {
    NSMutableArray *files = [NSMutableArray array];
    NSDirectoryEnumerator<NSURL *> *enumerator = [self.fileManager enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    NSURL *str;
    while (str = [enumerator nextObject]) {
        FileModel *file = [[FileModel alloc] initWithFilePath: [NSString stringWithFormat:@"%@/%@",path, str.lastPathComponent]];
        [files addObject:file];
    }
    NSArray *sorts = [files sortedArrayUsingComparator:^NSComparisonResult(FileModel *  _Nonnull obj1, FileModel *  _Nonnull obj2) {
        if (obj1.fileType==ELFileTypeDirectory&&obj2.fileType==ELFileTypeDirectory) {
            return [obj2.creatTime compare:obj1.creatTime];
        } else if (obj2.fileType==ELFileTypeDirectory) {
            return YES;
        } else if (obj1.fileType==ELFileTypeDirectory) {
            return NO;
        }
        return [obj2.creatTime compare:obj1.creatTime];
    }];
    return sorts;
}

- (NSArray *)getAllFileInPathWithSurfaceSearch:(NSString *)path {
    NSMutableArray *files = [NSMutableArray array];
    NSArray<NSString *> *subPathsArray = [self.fileManager contentsOfDirectoryAtPath:path error: NULL];
    for(NSString *str in subPathsArray){
        FileModel *file = [[FileModel alloc] initWithFilePath: [NSString stringWithFormat:@"%@/%@",path, str]];
        if (file.fileType != ELFileTypeDirectory)
            [files addObject:file];
    }
    return files;
}

- (NSArray *)getAllFileInPathWithDeepSearch:(NSString *)path {
    NSMutableArray *files = [NSMutableArray array];
    NSArray<NSString *> *subPathsArray = [self.fileManager contentsOfDirectoryAtPath:path error: NULL];
    for(NSString *str in subPathsArray){
        FileModel *file = [[FileModel alloc] initWithFilePath: [NSString stringWithFormat:@"%@/%@",path, str]];
        if (file.fileType == ELFileTypeDirectory) {
            [files addObjectsFromArray: [self getAllFileInPathWithDeepSearch:file.filePath]];
        } else {
            [files addObject:file];
        }
    }
    return files;
}

- (BOOL)fileExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)createFolderToPath:(NSString *)path folderName:(NSString *)name {
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [self createFolderToFullPath:path];
}

- (BOOL)createFolderToFullPath:(NSString *)fullPath {
    NSError *error;
    return  [self.fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
}

- (BOOL)createFileToPath:(NSString *)path fileName:(NSString *)name {
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [self createFileToFullPath:path];
}

- (BOOL)createFileToFullPath:(NSString *)fullPath {
    return [self.fileManager createFileAtPath:fullPath contents:nil attributes:nil];
}

- (BOOL)addFile:(id)file toPath:(NSString *)path fileName:(NSString *)name {
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [file writeToFile:path atomically:YES];
}

- (BOOL)deleteFileWithPath:(NSString *)path {
    return [self.fileManager removeItemAtPath:path error:nil];
}

- (BOOL)moveFile:(NSString *)oldPath toNewPath:(NSString *)newPath {
    newPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    return [self.fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (BOOL)copyFile:(NSString *)oldPath toNewPath:(NSString *)newPath {
    NSError *error;
    newPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    BOOL succeed = [self.fileManager copyItemAtPath:oldPath toPath:newPath error:&error];
    return succeed;
}

- (BOOL)renameFileWithPath:(NSString *)path oldName:(NSString *)oldName newName:(NSString *)newName {
    NSString *oldPath = [NSString stringWithFormat:@"%@/%@", path, oldName];
    NSString *newPath = [NSString stringWithFormat:@"%@/%@", path, newName];
    return [self.fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (NSArray *)searchSurfaceFile:(NSString *)searchText folderPath:(NSString *)folderPath {
    NSArray *files = [self getAllFileWithPath:folderPath];
    
    NSMutableArray *returnArr = [NSMutableArray array];
    for (FileModel *file in files) {
        if ([file.name rangeOfString:searchText].location != NSNotFound) {
            [returnArr addObject:file];
        }
    }
    return returnArr;
}

- (NSArray *)searchDeepFile:(NSString *)searchText folderPath:(NSString *)folderPath {
    NSArray *files = [self getAllFileWithPath:folderPath];
    
    NSMutableArray *returnArr = [NSMutableArray array];
    for (FileModel *file in files) {
        if ([file.name rangeOfString:searchText].location != NSNotFound) { // 找到文件
            if (file.fileType == ELFileTypeDirectory) { // 文件夹
                [returnArr addObjectsFromArray:[self searchDeepFile:searchText folderPath:file.filePath]]; // 递归去找
            }
            [returnArr addObject:file];
        }
    }
    return returnArr;
}

- (NSData *)readDataFromFilePath:(NSString *)filePath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    NSData *data = [fileHandle readDataToEndOfFile];
    [fileHandle closeFile];
    return data;
}

- (void)seriesWriteContent:(NSData *)contentData intoHandleFile:(NSString *)filePath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:contentData];
    [fileHandle closeFile];
}

#pragma mark - lazy
- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end


