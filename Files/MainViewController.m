//
//  MainViewController.m
//  Files
//
//  Created by Whde on 2019/04/16.
//  Copyright © 2019年 Whde All rights reserved.
//

#import "MainViewController.h"
#import "FileModel.h"

@interface MainViewController () // <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray * lists;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mian";
}

@end
