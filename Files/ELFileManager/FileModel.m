//
//  ELFileModel.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import "FileModel.h"

static const UInt8 IMAGES_TYPES_COUNT = 4;
static const UInt8 TEXT_TYPES_COUNT = 1;
static const UInt8 VIOCEVIDIO_COUNT = 7;
static const UInt8 Application_count = 3;
static const UInt8 AV_COUNT = 7;
static const UInt8 DOC_TYPES_COUNT = 2;
static const UInt8 XLS_TYPES_COUNT = 2;
static const UInt8 PPT_TYPES_COUNT = 1;
static const UInt8 PDF_TYPES_COUNT = 1;
static const UInt8 ZIP_TYPES_COUNT = 3;
static const UInt8 DMG_TYPES_COUNT = 3;

static const NSString *IMAGES_TYPES[IMAGES_TYPES_COUNT] = {@"png", @"jpg", @"jpeg" ,@"gif"};
static const NSString *TEXT_TYPES[TEXT_TYPES_COUNT] = {@"txt"};
static const NSString *VIOCEVIDIO_TYPES[VIOCEVIDIO_COUNT] = {@"mp3",@"wav",@"cd",@"ogg",@"midi",@"vqf",@"amr"};
static const NSString *AV_TYPES[AV_COUNT] = {@"asf",@"wma",@"rm",@"rmvb",@"avi",@"mkv",@"mp4"};
static const NSString *Application_types[Application_count] = {@"apk",@"ipa",@"pkg"};
static const NSString *DOC_TYPES[DOC_TYPES_COUNT] = {@"doc",@"docx"};
static const NSString *XLS_TYPES[XLS_TYPES_COUNT] = {@"xls", @"xlsx"};
static const NSString *PPT_TYPES[PPT_TYPES_COUNT] = {@"ppt"};
static const NSString *PDF_TYPES[PDF_TYPES_COUNT] = {@"pdf"};
static const NSString *ZIP_TYPES[ZIP_TYPES_COUNT] = {@"zip",@"xip",@"rar"};
static const NSString *DMG_TYPES[DMG_TYPES_COUNT] = {@"dmg",@"iso",@"ipsw"};

//@interface ELFileModel()
//@end

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
                self.fileSize = [NSString stringWithFormat:@"%fB", self.fileSizefloat];
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
    NSArray *imageTypesArray = [NSArray arrayWithObjects: IMAGES_TYPES count: IMAGES_TYPES_COUNT];
    if ([imageTypesArray containsObject:pathExtension]) {
        return ELFileTypeImage;
    }
    
    NSArray *textTypesArray = [NSArray arrayWithObjects: TEXT_TYPES count: TEXT_TYPES_COUNT];
    if ([textTypesArray containsObject:pathExtension]) {
        return ELFileTypeTxt;
    }
    
    NSArray *viceViodeArray = [NSArray arrayWithObjects: VIOCEVIDIO_TYPES count: VIOCEVIDIO_COUNT];
    if ([viceViodeArray containsObject:pathExtension]) {
        return ELFileTypeVoice;
    }
    
    NSArray *appViodeArray = [NSArray arrayWithObjects: Application_types count: Application_count];
    if ([appViodeArray containsObject:pathExtension]) {
        return ELFileTypeApplication;
    }
    
    NSArray *AVArray = [NSArray arrayWithObjects: AV_TYPES count: AV_COUNT];
    if ([AVArray containsObject:pathExtension]) {
        return ELFileTypeAudioVidio;
    }
    
    NSArray *DOCArray = [NSArray arrayWithObjects: DOC_TYPES count: DOC_TYPES_COUNT];
    if ([DOCArray containsObject:pathExtension]) {
        return ELFileTypeWord;
    }
    
    NSArray *XLSArray = [NSArray arrayWithObjects: XLS_TYPES count: XLS_TYPES_COUNT];
    if ([XLSArray containsObject:pathExtension]) {
        return ELFileTypeXLS;
    }
    
    NSArray *PDFArray = [NSArray arrayWithObjects: PDF_TYPES count: PDF_TYPES_COUNT];
    if ([PDFArray containsObject:pathExtension]) {
        return ELFileTypePDF;
    }
    
    NSArray *PPTArray = [NSArray arrayWithObjects: PPT_TYPES count: PPT_TYPES_COUNT];
    if ([PPTArray containsObject:pathExtension]) {
        return ELFileTypePPT;
    }
    NSArray *ZIPArray = [NSArray arrayWithObjects: ZIP_TYPES count: ZIP_TYPES_COUNT];
    if ([ZIPArray containsObject:pathExtension]) {
        return ELFileTypeZip;
    }
    NSArray *DMGArray = [NSArray arrayWithObjects: DMG_TYPES count: DMG_TYPES_COUNT];
    if ([DMGArray containsObject:pathExtension]) {
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
