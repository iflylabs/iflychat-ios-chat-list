//
//  GlobalListTableViewCell.m
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 30/07/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "GlobalListTableViewCell.h"

@implementation GlobalListTableViewCell

@synthesize avatarImage;
@synthesize userLetterLabel;
@synthesize nameLabel;
@synthesize messageLabel;
@synthesize timeLabel;


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.avatarImage.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.avatarImage.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.avatarImage.backgroundColor;
    [super setSelected:selected animated:animated];
    self.avatarImage.backgroundColor = backgroundColor;
}

@end

