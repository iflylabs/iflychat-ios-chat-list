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
#import "Utility.h"
@import MobileCoreServices;
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UsersTableViewController
{
    DataClass *dtclass;
    ApplicationSettings *appSettings;
    ApplicationData *appData;
    dispatch_queue_t fetchImage;
    NSCache *userImageCache;
    
    BOOL use_default_avatar;
}

@synthesize userArray;


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //Getting singleton instances of DataClass and ApplicationSettings
    dtclass = [DataClass getInstance];
    appSettings = [ApplicationSettings getInstance];
    appData = [ApplicationData getInstance];
    
    //Setting the Top bar title for Users Tab
    [appSettings setUsersTabTopBarTitle:@"Chats"];
    
    
    use_default_avatar = NO;
    
    
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
    
    [self.tabBarController.tabBar setHidden:NO];
    
    //Registering for the notification that will come from DataClass after library sends the updated Global List
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserList) name:@"onUpdatedGlobalList" object:nil];
    
    //Adding observers for required notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatConnect:) name:@"iFlyChat.onChatConnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSessionKey:) name:@"iFlyChat.onGetSessionKey" object:nil];
}


- (void)viewDidDisappear: (BOOL)animated{
    
    //Removing the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onUpdatedGlobalList" object:nil];
    
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

-(void) chatConnect:(NSNotification *)notification
{
    //Assigning the loggedUser data to the loggedUser variable in application data
    NSDictionary *dict = [notification object];
    appData.loggedUser = [dict objectForKey:@"iFlyChatCurrentUser"];
}

-(void) gotSessionKey:(NSNotification *)notification
{
    //Assigning session key
    appData.sessionKey = [notification object];
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
        [self setChatImage:cell.avatarImage userLetterLabel:cell.userLetterLabel userId:currentUser.getId userName:currentUser.getName userAvatarUrl:currentUser.getAvatarUrl];
    }
    else
    {
        //If the image is already downloaded, get it from cache and set it
        cell.avatarImage.image = [userImageCache objectForKey:currentUser.getId];
        cell.avatarImage.backgroundColor = [UIColor whiteColor];
        [cell.userLetterLabel setHidden:YES];
    }
    
    cell.messageLabel.text = @"No message";
    
    return cell;
}

-(void) setChatImage:(UIImageView *)userImageView userLetterLabel:(UILabel *)userLetterLabel userId:(NSString *)userId userName:(NSString *)userName userAvatarUrl:(NSString *)userAvatarUrl
{
    if([self checkRegisteredUser:userId])
    {
        if(userAvatarUrl.length != 0)
        {
            if([userAvatarUrl rangeOfString:@"default_avatar"].location != NSNotFound || [userAvatarUrl rangeOfString:@"gravatar"].location != NSNotFound )
            {
                if(use_default_avatar)
                {
                    //A registered user with no image set and we have to use only default image, no letter image
                    [self setDefaultAvatarWithBackgroundColor:userName userImageView: userImageView];
                    [userLetterLabel setHidden:YES];
                }
                else
                {
                    //A registered user with no image set and we are allowed to use letter image
                    [self setLetterAvatarWithBackgroundColor:userName userImageView: userImageView userLetterLabel: userLetterLabel];
                }
            }
            else
            {
                //A registered user with image set so use URL image
                dispatch_async(fetchImage, ^{
                    //Downloading images asynchronously
                    [self loadImagesWithURL:[NSString stringWithFormat:@"%@%@",@"http:",userAvatarUrl] userImageView:userImageView userId:userId];
                });
                
                [userLetterLabel setHidden:YES];
                userImageView.backgroundColor = [UIColor whiteColor];
            }
        }
        else if(use_default_avatar)
        {
            //A registered user with no URL for avatar and we have to use default image, no letter image
            [self setDefaultAvatarWithBackgroundColor:userName userImageView: userImageView];
            [userLetterLabel setHidden:YES];
        }
        else
        {
            //A registered user with no URL for avatar and we are allowed to use letter image
            [self setLetterAvatarWithBackgroundColor:userName userImageView: userImageView userLetterLabel: userLetterLabel];
        }
    }
    else
    {
        if(use_default_avatar)
        {
            //A guest user and we have to use default image, no letter image
            [self setDefaultAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:userName] userImageView: userImageView];
            [userLetterLabel setHidden:YES];
        }
        else
        {
            //A guest user and we are allowed to use letter image
            [self setLetterAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:userName] userImageView: userImageView userLetterLabel: userLetterLabel];
        }
    }
}


-(void) setDefaultAvatarWithBackgroundColor:(NSString *)userNameWithoutPrefix userImageView:(UIImageView *)userImageView
{
    userImageView.backgroundColor = [Utility getColorFromNameWithoutPrefix:userNameWithoutPrefix];
    userImageView.image = [UIImage imageNamed:@"MaleUser"];
}

-(void) setLetterAvatarWithBackgroundColor:(NSString *)userNameWithoutPrefix userImageView:(UIImageView *)userImageView userLetterLabel:(UILabel *)userLetterLabel
{
    if([[Utility getLetterFromNameWithoutPrefix:userNameWithoutPrefix] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound)
    {
        [userLetterLabel setHidden:YES];
        [self setDefaultAvatarWithBackgroundColor:userNameWithoutPrefix userImageView:userImageView];
    }
    else
    {
        userImageView.backgroundColor = [Utility getColorFromNameWithoutPrefix:userNameWithoutPrefix];
        userLetterLabel.text = [Utility getLetterFromNameWithoutPrefix:userNameWithoutPrefix];
        [userLetterLabel setHidden:NO];
        userImageView.image = nil;
    }
}

-(void) loadImagesWithURL:(NSString *)imageURL userImageView:(UIImageView *)userImageView userId:(NSString *)userId
{
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:data];
    
    //Inserting downloaded image in cache
    if(img != nil)
    {
        [userImageCache setObject:img forKey:userId];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Setting the image in the correct tableview and in the correct row
        userImageView.image = img;
    });
}

-(BOOL) checkRegisteredUser:(NSString *)userId
{
    if([userId rangeOfString:@"0-"].location != NSNotFound)
    {
        return NO;
    }
    else
    {
        return YES;
    }
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

