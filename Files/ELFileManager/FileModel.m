//
//  ELFileModel.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import "FileModel.h"
static const NSString *IMAGES_TYPES = @"png jpg jpeg gif tiff";
static const NSString *TEXT_TYPES = @"txt md sh";
static const NSString *VIOCEVIDIO_TYPES = @"mp3 wav cd ogg midi vqf amr";
static const NSString *AV_TYPES = @"asf wma rm rmvb avi mkv mp4";
static const NSString *Application_types = @"apk ipa pkg";
static const NSString *DOC_TYPES = @"doc docx pages";
static const NSString *XLS_TYPES = @"xls xlsx csv numbers";
static const NSString *PPT_TYPES = @"ppt pptx keynote";
static const NSString *PDF_TYPES = @"pdf";
static const NSString *ZIP_TYPES = @"zip xip rar";
static const NSString *DMG_TYPES = @"dmg iso ipsw";

@implementation FileModel {
    NSFileManager *fileMgr;
}

- (instancetype)init {
    if(self = [super init]) {
        fileMgr = [NSFileManager defaultManager];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if(self = [self init]){
        self.filePath = filePath;
    }
    return self;
}


- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    self.name = [filePath lastPathComponent];
    self.fileType = ELFileTypeUnknown; // 暂时先设置为未知
    
    BOOL isDirectory = true;
    [fileMgr fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isDirectory) { // 存在文件夹,说明这个文件是文件夹
        self.fileType = ELFileTypeDirectory;
    } else {
        self.fileType = [self judgeType:[filePath pathExtension]];  // 设置类型
    }
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:filePath error:&error];
    if (fileAttributes != nil) {
        
        self.attributes = fileAttributes;
        
        // 下面把一些常用的获取到
        NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
        if (fileModDate) { // 修改时间
            //用于格式化NSDate对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //NSDate转NSString
            self.modTime = [dateFormatter stringFromDate:fileModDate];
        }
        
        NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
        if (fileCreateDate) { // 创建时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //NSDate转NSString
            self.creatTime = [dateFormatter stringFromDate:fileCreateDate];
        }
        
        // 获得大小
        self.fileSizefloat = [self calculateSize];
        
        // 大小的字符
        if (self.fileSizefloat) {
            if (self.fileSizefloat >= pow(10, 9)) { // size >= 1GB
                self.fileSize = [NSString stringWithFormat:@"%.2fGB", self.fileSizefloat / pow(10, 9)];
            } else if (self.fileSizefloat >= pow(10, 6)) { // 1GB > size >= 1MB
                self.fileSize = [NSString stringWithFormat:@"%.2fMB", self.fileSizefloat / pow(10, 6)];
            } else if (self.fileSizefloat >= pow(10, 3)) { // 1MB > size >= 1KB
                self.fileSize = [NSString stringWithFormat:@"%.2fKB", self.fileSizefloat / pow(10, 3)];
            } else { // 1KB > size
                self.fileSize = [NSString stringWithFormat:@"%.0fB", self.fileSizefloat];
            }
        } else {
            self.fileSize = @"0 B";
        }
    }
}



#pragma mark - 私有
// 计算大小
- (float)calculateSize {
    if (self.fileType != ELFileTypeDirectory) { // 文件
        NSNumber *fileSize = [self.attributes objectForKey:NSFileSize];
        return [fileSize unsignedLongLongValue];
    } else { // 文件夹
        //遍历文件夹中的所有内容
        NSArray *subpaths = [fileMgr subpathsAtPath:_filePath];
        //计算文件夹大小
        float totalByteSize = 0;
        for (NSString *subpath in subpaths){
            //拼接全路径
            NSString *fullSubPath = [_filePath stringByAppendingPathComponent:subpath];
            //判断是否为文件
            BOOL dir = NO;
            [fileMgr fileExistsAtPath:fullSubPath isDirectory:&dir];
            if (dir == NO){//是文件
                NSDictionary *attr = [fileMgr attributesOfItemAtPath:fullSubPath error:nil];
                totalByteSize += [attr[NSFileSize] integerValue];
            }
        }
        return totalByteSize;
    }
}

// 通过后缀获得类型
- (ELFileType)judgeType:(NSString *)pathExtension {
    pathExtension = pathExtension.lowercaseString;
    if ([IMAGES_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeImage;
    }
    
    if ([TEXT_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeTxt;
    }
    
    if ([VIOCEVIDIO_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeVoice;
    }
    
    if ([Application_types rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeApplication;
    }
    
    if ([AV_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeAudioVidio;
    }
    
    if ([DOC_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeWord;
    }
    
    if ([XLS_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeXLS;
    }
    
    if ([PDF_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypePDF;
    }
    
    if ([PPT_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypePPT;
    }
    if ([ZIP_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeZip;
    }
    if ([DMG_TYPES rangeOfString:pathExtension].location!=NSNotFound) {
        return ELFileTypeDmg;
    }

    return ELFileTypeUnknown;
}
- (NSString *)description {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_filePath forKey:@"path"];
    [dic setValue:_name forKey:@"name"];
    [dic setValue:_fileSize forKey:@"size"];
    [dic setValue:NSStringFromTransactionState(_fileType) forKey:@"fileType"];
    return [NSString stringWithFormat:@"%@", dic];
}
NSString * NSStringFromTransactionState(ELFileType state) {
    switch (state) {
        case  ELFileTypeUnknown:
            return @"ELFileTypeUnknown";
        case  ELFileTypeAll:
            return @"ELFileTypeAll";
        case  ELFileTypeImage:
            return @"ELFileTypeImage";
        case  ELFileTypeTxt:
            return @"ELFileTypeTxt";
        case  ELFileTypeVoice:
            return @"ELFileTypeVoice";
        case  ELFileTypeAudioVidio:
            return @"ELFileTypeAudioVidio";
        case  ELFileTypeApplication:
            return @"ELFileTypeApplication";
        case  ELFileTypeDirectory:
            return @"ELFileTypeDirectory";
        case  ELFileTypePDF:
            return @"ELFileTypePDF";
        case  ELFileTypePPT:
            return @"ELFileTypePPT";
        case  ELFileTypeWord:
            return @"ELFileTypeWord";
        case  ELFileTypeXLS:
            return @"ELFileTypeXLS";
        case  ELFileTypeZip:
            return @"ELFileTypeZip";
        case  ELFileTypeDmg:
            return @"ELFileTypeDmg";
        default:
            return nil;
    }
}
@end
