//
//  ApplicationSettings.m
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 16/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "ApplicationSettings.h"


@implementation ApplicationSettings

NSString *usersTabTopBarTitle;
NSString *roomsTabTopBarTitle;


//Singleton instance
static ApplicationSettings *instance = nil;


+(ApplicationSettings *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        usersTabTopBarTitle = @"Chats";
        roomsTabTopBarTitle = @"Chats";
    });
    
    return instance;
}

-(void) setUsersTabTopBarTitle:(NSString *)usersTabTopBarTitleText
{
    usersTabTopBarTitle = usersTabTopBarTitleText;
}


-(NSString *)getUsersTabTopBarTitle
{
    return usersTabTopBarTitle;
}

-(void) setRoomsTabTopBarTitle:(NSString *)roomsTabTopBarTitleText
{
    roomsTabTopBarTitle = roomsTabTopBarTitleText;
}


-(NSString *)getRoomsTabTopBarTitle
{
    return roomsTabTopBarTitle;
}


@end