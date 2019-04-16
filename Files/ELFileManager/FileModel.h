//
//  ELFileModel.h
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ELFileType) {
    ELFileTypeUnknown = -1, //其他
    ELFileTypeAll = 0, //所有
    ELFileTypeImage = 1, //图片
    ELFileTypeTxt = 2, //文档
    ELFileTypeVoice = 3, //音乐
    ELFileTypeAudioVidio = 4, //视频
    ELFileTypeApplication = 5, //应用
    ELFileTypeDirectory = 6, //目录
    ELFileTypePDF = 7, //PDF
    ELFileTypePPT = 8, //PPT
    ELFileTypeWord = 9, //Word
    ELFileTypeXLS = 10, //XLS
    ELFileTypeZip,
    ELFileTypeDmg,
};

@interface FileModel : NSObject
@property (copy, nonatomic) NSString *filePath; ///< 全路径
@property (copy, nonatomic) NSString *fileUrl;
@property (copy, nonatomic) NSString *name; ///< 文件名称
@property (copy, nonatomic) NSString *fileSize; ///< 大小用字符表述
@property (nonatomic, assign) float fileSizefloat; ///< 大小用float
@property (copy, nonatomic) NSString *modTime; ///< 修改时间
@property (copy, nonatomic) NSString *creatTime; ///< 修改时间
@property (assign, nonatomic) ELFileType fileType;
@property (nonatomic, strong) NSDictionary *attributes; ///<文件属性
- (instancetype)initWithFilePath:(NSString *)filePath;
extern NSString * NSStringFromTransactionState(ELFileType state);
@end
