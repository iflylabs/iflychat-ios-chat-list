//
//  RoomsTableViewController.h
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 30/07/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iFlyChatLibrary/iFlyChatLibrary.h"


@interface RoomsTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSArray *resultsArray;
}

@property (nonatomic, strong) iFlyChatOrderedDictionary *roomArray;


@end
