//
//  SearchViewController.h
//  AppizzlerDemo
//
//  Created by Rana M Mateen on 12/11/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"
@import CoreData;

@interface SearchViewController : UIViewController<UISearchBarDelegate,IconDownloaderDelegate,UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *tableTweets;
    NSUserDefaults * defaults;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    IBOutlet UISearchBar *searchBarOutlet;
}
@property (nonatomic, retain) NSMutableDictionary * imageDownloadsInProgress;
@property (nonatomic,retain)NSMutableArray * tweetArray;





@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator * persistentStoreCoordinator;



@end

