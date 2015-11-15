//
//  FirstViewController.h
//  AppizzlerDemo
//
//  Created by Rana M Mateen on 12/11/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetsViewController : UIViewController{
    
    IBOutlet UIButton *btnLogin;
    NSUserDefaults * defaults;
    IBOutlet UILabel *lblHelp;
}

@property (nonatomic,retain) NSString * bearerToken;
- (IBAction)loginButtonPressed:(id)sender;

@end

