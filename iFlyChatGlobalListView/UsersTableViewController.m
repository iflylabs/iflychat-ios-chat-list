//
//  UsersTableViewController.m
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 29/07/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "UsersTableViewController.h"
#import "GlobalListTableViewCell.h"
#import "DataClass.h"
#import "ApplicationSettings.h"

@implementation UsersTableViewController
{
    DataClass *dtclass;
    ApplicationSettings *appSettings;
    dispatch_queue_t fetchImage;
    NSCache *userImageCache;
}

@synthesize userArray;


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //Getting singleton instances of DataClass and ApplicationSettings
    dtclass = [DataClass getInstance];
    appSettings = [ApplicationSettings getInstance];
    
    //Setting the Top bar title for Users Tab
    [appSettings setUsersTabTopBarTitle:@"Chats"];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Adding search bar to the top of table view
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    
    //Registering custom UITableViewCell in tableView and search results table view
    UINib *nib = [UINib nibWithNibName:@"GlobalListTableViewCell" bundle:nil];
    
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"GlobalListCell"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"GlobalListCell"];
    
    //Initializing iFlyChat
    [dtclass initiFlyChatLibrary];
    
    //Instantiating a queue for image downloads
    fetchImage = dispatch_queue_create("fetchImage", DISPATCH_QUEUE_SERIAL);
    
    //Instantiating cache to store downloaded images
    userImageCache = [[NSCache alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //Setting the top bar title
    [self.navigationItem setTitle:appSettings.getUsersTabTopBarTitle];
    
    //Putting the data inside the table view
    [self refreshUserList];
    
    //Registering for the notification that will come from DataClass after library sends the updated Global List
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserList) name:@"onUpdatedUserList" object:nil];
}

- (void)viewDidDisappear: (BOOL)animated{
    
    //Removing the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onUpdatedUserList" object:nil];
    
}


- (void)refreshUserList
{
    //Checking if the userlist is updated or not and user is not searching anything
    if(dtclass.updatedUserList && [resultsArray count] ==0)
    {
        userArray = dtclass.getUpdatedUserList;
        [dtclass setUpdatedUserList:NO];
        [self.tableView reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If the user is searching something, number of rows is equal to search results
    if (resultsArray.count != 0)
    {
        return [resultsArray count];
    }
    
    return [userArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    
    GlobalListTableViewCell *cell = (GlobalListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GlobalListCell"];
    
   
    iFlyChatUser *currentUser;
    
    //If the user is searching something, take the data from resultsArray otherwise from userArray
    if(resultsArray.count !=0)
    {
        currentUser = [resultsArray objectAtIndex:indexPath.row];
    }
    else
    {
        currentUser = [userArray objectAtIndex:indexPath.row];
    }
    
    cell.nameLabel.text = currentUser.getName;
    cell.timeLabel.text = @"5 pm";
    
    //Checking if the image is already downloaded for the user id
    if([userImageCache objectForKey:currentUser.getId] == nil)
    {
        if([[currentUser getAvatarUrl] length]!=0)
        {
            dispatch_async(fetchImage, ^{
        
                //Downloading images asynchronously
                [self loadImagesWithURL:[NSString stringWithFormat:@"%@%@",@"http:",[currentUser getAvatarUrl] IndexPath:indexPath activeTableView:tableView userId:currentUser.getId];
            
            });
        }
    
        //If avatar url is empty, set the default image
        cell.avatarImage.image = [UIImage imageNamed:@"defaultUser.png"];
    }
    else
    {
        //If the image is already downloaded, get it from cache and set it
        cell.avatarImage.image = [userImageCache objectForKey:currentUser.getId];
    }
    
    cell.messageLabel.text = @"No message";
    
    return cell;
}

-(void) loadImagesWithURL:(NSString *)imageURL IndexPath:(NSIndexPath *)indexPath activeTableView:(UITableView *)tableView userId:(NSString *)userId
{
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:data];
    
    //Inserting downloaded image in cache
    [userImageCache setObject:img forKey:userId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Setting the image in the correct tableview and in the correct row
        GlobalListTableViewCell *cell = (GlobalListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.avatarImage.image = img;
        
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    resultsArray = [[NSArray alloc] init];
    
    //Creating a predicate to be used for search
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.getName contains[c] %@", searchText];
    
    resultsArray = [userArray filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
    aSearchBar.text = nil;
    
    //After cancel button for search is pressed, check if user list is updated behind the scene or not. If yes, update it in the view.
    if(dtclass.updatedUserList)
    {
        userArray = [dtclass getUpdatedUserList];
        [dtclass setUpdatedUserList:NO];
        [self.tableView reloadData];
    }
}



@end

