//

//
//  Created by Rana M Mateen on 23/06/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TweetCell: UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *_lblName;
@property (strong, nonatomic) IBOutlet UILabel *_lblScreenName;
@property (strong, nonatomic) IBOutlet UIButton *_btnSaveTweet;
@property (strong, nonatomic) IBOutlet UIImageView *_imageViewUserPic;
@property (strong, nonatomic) IBOutlet UITextView * _textViewText;



@property (nonatomic,copy) NSString * reuseIdentifier;

@end
