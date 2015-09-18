//
//  GlobalListTableViewCell.h
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 30/07/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
