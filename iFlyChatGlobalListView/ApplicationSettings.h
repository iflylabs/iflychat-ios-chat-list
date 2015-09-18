//
//  ApplicationSettings.h
//  iFlyChatGlobalListView
//
//  Created by Prateek Grover on 16/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ApplicationSettings : NSObject

+(ApplicationSettings *)getInstance;

-(void) setUsersTabTopBarTitle:(NSString *)usersTabTopBarTitleText;

-(NSString *)getUsersTabTopBarTitle;

-(void) setRoomsTabTopBarTitle:(NSString *)roomsTabTopBarTitleText;

-(NSString *)getRoomsTabTopBarTitle;

@end

