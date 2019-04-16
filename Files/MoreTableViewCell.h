//
//  MoreTableViewCell.h
//  Files
//
//  Created by Whde on 2019/4/16.
//  Copyright © 2019 Whde. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *tLabel;
@property (weak, nonatomic) IBOutlet UILabel *sLabel;

@end

NS_ASSUME_NONNULL_END
