//
//  UsersTableViewController.h
//  iFlyChatGlobalListView
//
//  Created by Prateek Grover on 29/07/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iFlyChatLibrary/iFlyChatLibrary.h"

@interface UsersTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSArray *resultsArray;
}

@property (nonatomic, strong) iFlyChatOrderedDictionary *userArray;


@end
