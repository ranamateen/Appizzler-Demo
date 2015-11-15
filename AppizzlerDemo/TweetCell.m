
//  Created by Rana M Mateen on 23/06/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import "TweetCell.h"


@implementation TweetCell
@synthesize reuseIdentifier;
- (void)awakeFromNib {
    // Initialization code
    //Make Border
    CALayer * container = [__imageViewUserPic layer];
    [container setMasksToBounds:YES];
    [container setCornerRadius:15];
    [container setBorderColor:[[UIColor colorWithRed:61/255.0 green:191/255.0 blue:168/255.0 alpha:1] CGColor]];
    [container setBorderWidth:1.0];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
