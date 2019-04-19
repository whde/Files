//
//  MoreViewController.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.

#import "MoreViewController.h"
#import "FileModel.h"
#import "FileManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MoreTableViewCell.h"
#import "MsgView/MessageView.h"
#import <QuickLook/QuickLook.h>
@interface MoreViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) FileManager *fileManager;
@property (nonatomic, weak) UITableView *tv;
@property (nonatomic, copy) NSString *homePath;
@end

@implementation MoreViewController {
    FileModel *_longPressFile; // 记录长按的文件
    NSIndexPath *_longPressIndexPath; // 记录长按的indexpath
    NSString *_downloadFileName; // 下载的文件名
    NSUInteger _totolLen; // 总长度
    NSUInteger _currentLen; // 当前长度
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileManager = [FileManager shareManager];
    if (self.fileModel == nil) { // 总目录
        self.homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 创建一个目录
        [self.fileManager createFolderToFullPath:self.homePath];
        self.title = @"目录";
    } else {
        self.title = self.fileModel.name;
        self.homePath = self.fileModel.filePath;
    }
    
    
    // init视图
    [self initViews];
    
    // 获得路径下的所以文件
    [self getAllFile];
}

#pragma mark - tableView 代理数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (MoreTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell =  [[NSBundle mainBundle]loadNibNamed:@"MoreTableViewCell" owner:self options:nil].firstObject;

        //添加长按手势
        UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        longPressGesture.minimumPressDuration = 1.0f;
        [cell addGestureRecognizer:longPressGesture];
    }
    FileModel *file = self.files[indexPath.row];
    cell.tLabel.text = file.name;
    cell.imageV.image = nil;
    if (file.fileType == ELFileTypeDirectory) { // 文件夹
        cell.sLabel.text = [NSString stringWithFormat:@"文件夹： %@ %@", file.creatTime, file.fileSize];
        cell.imageV.image = [UIImage imageNamed:@"file_floder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (file.fileType) {
            case ELFileTypeImage: {
                cell.sLabel.text = [NSString stringWithFormat:@"图片： %@ %@", file.creatTime, file.fileSize];
                [self getImageFromImageSource:file.filePath complete:^(UIImage *image, NSString *path) {
                    if ([file.filePath isEqual:path]) {
                        cell.imageV.image = image;
                        [cell setNeedsLayout];
                    }
                }];
                break;
            }
            case ELFileTypeTxt: {
                cell.sLabel.text = [NSString stringWithFormat:@"文档： %@ %@", file.creatTime, file.fileSize];
                cell.imageV.image = [UIImage imageNamed:@"file_txt"];
                break;
            }
            case ELFileTypeVoice: {
                cell.sLabel.text = [NSString stringWithFormat:@"音乐： %@ %@", file.creatTime, file.fileSize];
                cell.imageV.image = [UIImage imageNamed:@"file_mp3"];
                break;
            }
            case ELFileTypeAudioVidio: {
                cell.sLabel.text = [NSString stringWithFormat:@"视频： %@ %@", file.creatTime, file.fileSize];
                cell.imageV.image = [UIImage imageNamed:@"file_avi"];
                [self getImageFromVideoSource:file.filePath complete:^(UIImage *image, NSString *path) {
                    if ([file.filePath isEqual:path]) {
                        cell.imageV.image = image;
                        [cell setNeedsLayout];
                    }
                }];
                break;
            }
            case ELFileTypeApplication: {
                cell.sLabel.text = [NSString stringWithFormat:@"应用： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"apk"]) {
                    cell.imageV.image = [UIImage imageNamed:@"apk"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"ipa"]) {
                    cell.imageV.image = [UIImage imageNamed:@"ipa"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"pkg"]) {
                    cell.imageV.image = [UIImage imageNamed:@"pkg"];
                }
                break;
            }
            case ELFileTypeUnknown: {
                cell.sLabel.text = [NSString stringWithFormat:@"未知文件： %@ %@", file.creatTime, file.fileSize];
                cell.imageV.image = [UIImage imageNamed:@"file_webView_error"];
                break;
            }
            case ELFileTypeWord: {
                cell.sLabel.text = [NSString stringWithFormat:@"word： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"pages"]) {
                    cell.imageV.image = [UIImage imageNamed:@"pages"];
                } else {
                    cell.imageV.image = [UIImage imageNamed:@"file_word"];
                }
                break;
            }
            case ELFileTypePDF: {
                cell.sLabel.text = [NSString stringWithFormat:@"pdf： %@ %@", file.creatTime, file.fileSize];
                cell.imageV.image = [UIImage imageNamed:@"file_pdf"];
                break;
            }
            case ELFileTypePPT: {
                cell.sLabel.text = [NSString stringWithFormat:@"ppt： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"keynote"]) {
                    cell.imageV.image = [UIImage imageNamed:@"keynote"];
                } else {
                    cell.imageV.image = [UIImage imageNamed:@"file_ppt"];
                }
                break;
            }
            case ELFileTypeXLS: {
                cell.sLabel.text = [NSString stringWithFormat:@"xls： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"numbers"]) {
                    cell.imageV.image = [UIImage imageNamed:@"numbers"];
                } else {
                    cell.imageV.image = [UIImage imageNamed:@"file_excel"];
                }
                break;
            }
            case ELFileTypeZip: {
                cell.sLabel.text = [NSString stringWithFormat:@"压缩文件： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"zip"]) {
                    cell.imageV.image = [UIImage imageNamed:@"zip"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"xip"]) {
                    cell.imageV.image = [UIImage imageNamed:@"xip"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"rar"]) {
                    cell.imageV.image = [UIImage imageNamed:@"rar"];
                }
                break;
            }
            case ELFileTypeDmg: {
                cell.sLabel.text = [NSString stringWithFormat:@"磁盘镜像： %@ %@", file.creatTime, file.fileSize];
                if ([file.filePath.pathExtension.lowercaseString isEqual:@"dmg"]) {
                    cell.imageV.image = [UIImage imageNamed:@"dmg"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"iso"]) {
                    cell.imageV.image = [UIImage imageNamed:@"iso"];
                } else if ([file.filePath.pathExtension.lowercaseString isEqual:@"ipsw"]) {
                    cell.imageV.image = [UIImage imageNamed:@"ipsw"];
                }
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FileModel *file = self.files[indexPath.row];
    if (file.fileType == ELFileTypeDirectory) {
        MoreViewController *vc = [[MoreViewController alloc] init];
        vc.fileModel = file;
        vc.homePath = file.filePath;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (file.fileType == ELFileTypeDmg || file.fileType == ELFileTypeUnknown || file.fileType == ELFileTypeApplication) {
        UIDocumentInteractionController *documentVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file.filePath]];
        documentVc.delegate = self;
        documentVc.UTI = @"public.archive";
        BOOL canOpen = [documentVc presentPreviewAnimated:YES];
        if (!canOpen) {
            [MessageView showMsg:@"文件类型不能打开分享"];
        }
    } else {
        UIDocumentInteractionController *documentVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file.filePath]];
        documentVc.delegate = self;
        BOOL canOpen = [documentVc presentPreviewAnimated:YES];
        if (!canOpen) {
            [MessageView showMsg:@"文件类型不能打开分享"];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *file = self.files[indexPath.row];
    if ([self.fileManager deleteFileWithPath:file.filePath]) {
        [self.files removeObjectAtIndex:indexPath.row];
        [self.tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - 对控件权限进行设置
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(rename:) || action == @selector(moveFile) || action == @selector(copyFile))
        return YES;
    return NO;
}

#pragma mark - 私有
- (void)initViews {

    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    tv.estimatedSectionFooterHeight = 0;
    tv.estimatedSectionHeaderHeight = 0;
    tv.estimatedRowHeight = 0;
    tv.rowHeight = 60;
    tv.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
    tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
    [self.view addSubview:tv];
    if (@available(iOS 10, *)) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        [refreshControl addTarget:self action:@selector(getAllFile) forControlEvents:UIControlEventValueChanged];
        tv.refreshControl = refreshControl;
    }
    self.tv = tv;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
}

- (void)getAllFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.files = [NSMutableArray arrayWithArray:[self.fileManager getAllFileWithPath:self.homePath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tv reloadData];
            if (@available(iOS 10, *)) {
                [self.tv.refreshControl endRefreshing];
            }
        });
    });
}

- (void)addAction {
    int num = arc4random() % 100;
    NSString *name = [NSString stringWithFormat:@"新建的文件夹%d", num];
    if ([self.fileManager createFolderToPath:self.homePath folderName:name]) {
        [self getAllFile];
    } else {
        NSLog(@"创建失败");
    }
//    NSArray *resFiles = [self.fileManager searchDeepFile:@"的" folderPath:self.homePath];
//    for (FileModel *file in resFiles) {
//        NSLog(@"%@", file.name);
//    }
}

- (void)cellLongPress:(UILongPressGestureRecognizer *)longRecognizer {
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [longRecognizer locationInView:self.tv];
        _longPressIndexPath = [self.tv indexPathForRowAtPoint:location];
        UITableViewCell *cell = [self.tv cellForRowAtIndexPath:_longPressIndexPath];
        _longPressFile = self.files[_longPressIndexPath.row];
        
        
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        //控制箭头方向
        menuController.arrowDirection = UIMenuControllerArrowDefault;
        //自定义事件
        UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:@"重命名" action:@selector(rename:)];
        UIMenuItem *moveItem = [[UIMenuItem alloc] initWithTitle:@"移动" action:@selector(moveFile)];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyFile)];
        
        NSArray *menuItemArray = [NSArray arrayWithObjects:renameItem, moveItem, copyItem, nil];
        [menuController setMenuItems:menuItemArray];
        [menuController setTargetRect:cell.frame inView:self.tv];
        [menuController setMenuVisible:YES animated:YES];
    }
}

// 重命名
- (void)rename:(UIMenuController *)menu {
    UIAlertController *actionAlertController = [UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.fileManager renameFileWithPath:self.homePath oldName:self->_longPressFile.name newName:[[[actionAlertController textFields] firstObject] text]]) { // 成功
            [self getAllFile]; // 获取数据
        } else {
            NSLog(@"失败");
        }
    }];
    
    [actionAlertController addAction:cancleAction];
    [actionAlertController addAction:defaultAction];
    
    [actionAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self->_longPressFile.name;
    }];
    
    [self presentViewController:actionAlertController animated:YES completion:nil];
}

// 复制
- (void)copyFile {
    FileModel *directoryFile;
    for (FileModel *file in self.files) {  // 获取一个临时的最前的文件夹
        if (file.fileType == ELFileTypeDirectory) {
            directoryFile = file;
        }
    }
    if ([self.fileManager copyFile:_longPressFile.filePath toNewPath:directoryFile.filePath]) {
        [self getAllFile];
        NSLog(@"复制成功");
    } else {
        NSLog(@"复制失败");
    }
}

// 移动
- (void)moveFile {
    FileModel *directoryFile;
    for (FileModel *file in self.files) {  // 获取一个临时的最前的文件夹
        if (file.fileType == ELFileTypeDirectory) {
            directoryFile = file;
        }
    }
    if ([self.fileManager moveFile:_longPressFile.filePath toNewPath:directoryFile.filePath]) {
        [self getAllFile];
        NSLog(@"移动成功");
    } else {
        NSLog(@"移动失败");
    }
}

- (void)getImageFromImageSource:(NSString *)path complete:(void (^)(UIImage *image, NSString *path))success {
    dispatch_global_async_safe_el(^{
        NSString *imagePath=[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", [path lastPathComponent]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(image, path);
                });
            }
            return;
        }
        CGImageSourceRef imageSource = NULL;
        CGImageRef thumbnail = NULL;
        imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath: [path stringByExpandingTildeInPath]], NULL);
        if (imageSource == NULL) {
            if (success) {
                dispatch_main_async_safe_el(^{
                    success(nil, path);
                });
            }
            return;
        }
        CFStringRef imageSourceType = CGImageSourceGetType(imageSource);
        if (imageSourceType == NULL) {
            CFRelease(imageSource);
            if (success) {
                dispatch_main_async_safe_el(^{
                    success(nil, path);
                });
            }
            return;
        }
        CFRelease(imageSourceType);
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                 [NSNumber numberWithLong:120], (NSString *)kCGImageSourceThumbnailMaxPixelSize, //new image size 800*600
                                 nil];
        thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)options);
        CFRelease(imageSource);
        UIImage *imageResult=[UIImage imageWithCGImage:thumbnail];
        [UIImageJPEGRepresentation(imageResult, 1) writeToFile:imagePath atomically:YES];
        if (success) {
            dispatch_main_async_safe_el(^{
                success(imageResult, path);
            });
        }
    });
}
- (void)getImageFromVideoSource:(NSString *)videoPath complete:(void (^)(UIImage *image, NSString *path))success {
    if (videoPath) {
        dispatch_global_async_safe_el(^{
            NSString *imagePath=[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", [videoPath lastPathComponent]];
            UIImage *cacheImage = [UIImage imageWithContentsOfFile:imagePath];
            if (cacheImage) {
                if (success) {
                    dispatch_main_async_safe_el(^{
                        success(cacheImage, videoPath);
                    });
                }
                return;
            }
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath: videoPath] options:nil];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            // 设定缩略图的方向
            // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的
            gen.appliesPreferredTrackTransform = YES;
            // 设置图片的最大size(分辨率)
            gen.maximumSize = CGSizeMake(300, 169);
            CMTime time = CMTimeMakeWithSeconds(5.0, 600); //取第5秒，一秒钟600帧
            NSError *error = nil;
            CMTime actualTime;
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
            if (error) {
                return;
            }
            UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
            [UIImageJPEGRepresentation(thumb, 1) writeToFile:imagePath atomically:YES];
            CGImageRelease(image);
            if (success) {
                dispatch_main_async_safe_el(^{
                    success(thumb, videoPath);
                });
            }
        });
    }
}

#pragma mark - lazy
- (NSMutableArray *)files {
    if (!_files) {
        _files = [NSMutableArray array];
    }
    return _files;
}

#pragma mark - UIDocumentInteractionController 代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.bounds;
}
@end

