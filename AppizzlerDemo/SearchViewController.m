//
//  SearchViewController.m
//  AppizzlerDemo
//
//  Created by Rana M Mateen on 12/11/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import "SearchViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "Constants.h"
#import "TweetCell.h"
#import "SingltonClass.h"
#import "AppDelegate.h"
@import CoreData;

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    defaults=[NSUserDefaults standardUserDefaults];
    _tweetArray =[[NSMutableArray alloc] init];
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    
    [self savedTweets:@"Saved Tweets"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:BEARER_KEY]] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&count=25",searchBar.text] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray * responseArray = [responseObject objectForKey:@"statuses"];
        NSLog(@"response array :%@",responseArray);
        [_tweetArray removeAllObjects];
        for (int i=0; i<[responseArray count]; i++) {
            
            NSLog(@"%@",[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:USER_NAME_KEY]);
            NSLog(@"%@",[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:PIC_URL_KEY]);
            NSLog(@"%@",[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:SCREEN_NAME_KEY]);
            NSLog(@"%@",[[responseArray objectAtIndex:i] objectForKey:TWEET_TEXT_KEY]);
            
            NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:USER_NAME_KEY],USER_NAME_KEY,[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:PIC_URL_KEY],PIC_URL_KEY,[[[responseArray objectAtIndex:i] objectForKey:@"user"] objectForKey:SCREEN_NAME_KEY],SCREEN_NAME_KEY,[[responseArray objectAtIndex:i] objectForKey:TWEET_TEXT_KEY],TWEET_TEXT_KEY,[[responseArray objectAtIndex:i] objectForKey:TWEET_ID_KEY],TWEET_ID_KEY, nil];
            [_tweetArray addObject:dict];
        }
        if([_tweetArray count]==0){
            [SingltonClass displayWarning:@"Alert" message:@"No record found. Please try again." tag:OK_ONLY_TAG target:self firstButtonTitle:@"OK" secondButtonTitle:nil];
            
        }else{
            
            [tableTweets setDelegate:self];
            [tableTweets setDataSource:self];
            [tableTweets reloadData];
            [searchBarOutlet resignFirstResponder];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SingltonClass displayWarning:@"Connectivity Status" message:@"Sorry. We cannot reach server. Please try again." tag:OK_ONLY_TAG target:self firstButtonTitle:@"OK" secondButtonTitle:nil];
    }];

}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;

    
    NSString *customCellIdentifierMain=@"TweetCell";
    customCellIdentifierMain = [NSString stringWithFormat:@"%@%ld%@",customCellIdentifierMain,(long)indexPath.row,[[_tweetArray objectAtIndex:row] objectForKey:TWEET_ID_KEY]];
    
    TweetCell *cell=(TweetCell *)[tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@",customCellIdentifierMain]];
    if (cell==nil) {
        NSArray *topLevelObjects=[[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell=(TweetCell *) currentObject;
                break;
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.reuseIdentifier = customCellIdentifierMain;
        [cell._lblName setText:[[_tweetArray objectAtIndex:row] objectForKey:USER_NAME_KEY]];
        [cell._lblScreenName setText:[NSString stringWithFormat:@"@%@",[[_tweetArray objectAtIndex:row] objectForKey:SCREEN_NAME_KEY]]];
        [cell._textViewText setText:[[_tweetArray objectAtIndex:row] objectForKey:TWEET_TEXT_KEY]];
        
        NSString * userPicURL=[[_tweetArray objectAtIndex:row] objectForKey:PIC_URL_KEY];
        [self startIconDownload:userPicURL forIndexPath:cell._imageViewUserPic forID:[[_tweetArray objectAtIndex:row] objectForKey:TWEET_ID_KEY]];
        
        [cell._btnSaveTweet addTarget:self action:@selector(saveBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell._btnSaveTweet.tag = row;

        
        
    }
    
    return cell;
}
-(void)saveBtnTapped:(id)sender{
    
    
    UIButton *button = (UIButton*)sender;
    
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id = %@", [[[_tweetArray objectAtIndex:button.tag] objectForKey:TWEET_ID_KEY] stringValue]]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound){
        //
    }
        else if (count == 0){
            NSManagedObject *newTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
            
            [newTweet setValue:[[_tweetArray objectAtIndex:button.tag] objectForKey:USER_NAME_KEY] forKey:USER_NAME_KEY];
            [newTweet setValue:[[_tweetArray objectAtIndex:button.tag] objectForKey:PIC_URL_KEY] forKey:PIC_URL_KEY];
            [newTweet setValue:[[_tweetArray objectAtIndex:button.tag] objectForKey:SCREEN_NAME_KEY] forKey:SCREEN_NAME_KEY];
            [newTweet setValue:[[[_tweetArray objectAtIndex:button.tag] objectForKey:TWEET_ID_KEY] stringValue] forKey:TWEET_ID_KEY];
            [newTweet setValue:[[_tweetArray objectAtIndex:button.tag] objectForKey:TWEET_TEXT_KEY] forKey:TWEET_TEXT_KEY];
            
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                
            }else{
                [SingltonClass displayWarning:@"Successful" message:@"Tweet is saved." tag:OK_ONLY_TAG target:self firstButtonTitle:@"OK" secondButtonTitle:nil];
                
                
                TweetCell *cell = (TweetCell*)[tableTweets cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
                UIButton *btn = cell._btnSaveTweet;
                [btn setTitle:@"Saved" forState:UIControlStateNormal];
            }

        }
            else
            {
    
                TweetCell *cell = (TweetCell*)[tableTweets cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
                UIButton *btn = cell._btnSaveTweet;
                [btn setTitle:@"Saved" forState:UIControlStateNormal];
            }
    
    
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 78;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tweetArray count];
}


#pragma mark - SWTableViewDelegate

- (void)savedTweets:(NSString *)name
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 32, 100, 30);
    [rightButton setTitle:name forState:UIControlStateNormal];
    [[rightButton titleLabel] setFont:[UIFont systemFontOfSize:15]];
    CALayer * container = [rightButton layer];
    [container setMasksToBounds:YES];
    [container setCornerRadius:5];
    [container setBorderColor:[[UIColor whiteColor] CGColor]];
    [container setBorderWidth:1.0];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goToSavedTweets) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)goToSavedTweets
{
    [self performSegueWithIdentifier:@"goSave" sender:self];
}


#pragma mark image support
- (void)startIconDownload:(NSString *)imageUrl forIndexPath:(UIImageView *)indexPath forID:(NSString *)imageID
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageID];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imageUrl = imageUrl;
        iconDownloader.imageID = imageID;
        iconDownloader.indexPathForImageView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageID];
        [iconDownloader startDownload];
    }
}


- (void)appImageDidLoad:(UIImageView *)indexPath url:(NSString *)url imageID:(NSString *)imageID
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageID];
    if (iconDownloader != nil)
    {
        
        [UIView transitionWithView:indexPath
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [indexPath setImage:iconDownloader.imageIcon];
                        } completion:nil];
        
    }
    
    [self.imageDownloadsInProgress removeObjectForKey:imageID];
}



- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}
/**
 Returns the URL to the application's documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // CHECK
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // copy the default store (with a pre-populated data) into our Documents folder
    //
    NSString *documentsStorePath =
    [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"TweetSave.xcdatamodeld"];
    
    // if the expected store doesn't exist, copy the default store
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsStorePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"TweetSave" ofType:@"xcdatamodeld"];
        if (defaultStorePath) {
            [[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:documentsStorePath error:NULL];
        }
    }
    
    _persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // add the default store to our coordinator
    NSError *error;
    NSURL *defaultStoreURL = [NSURL fileURLWithPath:documentsStorePath];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:defaultStoreURL
                                                         options:nil
                                                           error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _persistentStoreCoordinator;
}


@end
