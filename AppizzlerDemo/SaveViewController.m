//
//  SaveViewController.m
//  AppizzlerDemo
//
//  Created by Rana M Mateen on 12/11/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import "SaveViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "Constants.h"
#import "TweetCell.h"
#import "SingltonClass.h"
@import CoreData;

@interface SaveViewController ()

@end

@implementation SaveViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    defaults=[NSUserDefaults standardUserDefaults];
    _saveTweetArray =[[NSMutableArray alloc] init];
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    
    // Fetch Stored Tweets
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tweet"];
    _saveTweetArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [tableTweets setDataSource:self];
    [tableTweets setDelegate:self];
    [tableTweets reloadData];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}




-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    
    //        NSLog(@"Row No. %ld",(long)row);
    
    NSString *customCellIdentifierMain=@"TweetCell";
    customCellIdentifierMain = [NSString stringWithFormat:@"%@%ld",customCellIdentifierMain,(long)indexPath.row];
    
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
        NSManagedObject *tweet = [_saveTweetArray objectAtIndex:indexPath.row];
        
        [cell._lblName setText:[tweet valueForKey:USER_NAME_KEY]];
        [cell._lblScreenName setText:[NSString stringWithFormat:@"@%@",[tweet valueForKey:SCREEN_NAME_KEY]]];
        [cell._textViewText setText:[tweet valueForKey:TWEET_TEXT_KEY]];
        
        NSString * userPicURL=[tweet valueForKey:PIC_URL_KEY];
        [self startIconDownload:userPicURL forIndexPath:cell._imageViewUserPic forID:[tweet valueForKey:TWEET_ID_KEY]];
        [cell._btnSaveTweet setHidden:YES];

        
        
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[_saveTweetArray objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        
        
        // Remove device from table view
        [_saveTweetArray removeObjectAtIndex:indexPath.row];
        [tableTweets deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 78;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_saveTweetArray count];
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
