//
//  SingltonClass.m
//  CameraApp
//
//  Created by Lion User on 29/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingltonClass.h"
#import "Constants.h"
#import <UIKit/UIKit.h>

static SingltonClass* _sharedData = nil;

@implementation SingltonClass

+(SingltonClass*) sharedData
{
	@synchronized([SingltonClass class])
	{
		if (!_sharedData)
			_sharedData = [[self alloc] init];
        
		return _sharedData;
	}
    
	return nil;
}



+(void) displayWarning:(NSString *) title message:(NSString *) message tag:(int)tag target:(id) target firstButtonTitle:(NSString *) aButton secondButtonTitle:(NSString *) bButton
{
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:target 
                                            cancelButtonTitle:aButton 
                                            otherButtonTitles:bButton,nil];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [myAlert setTransform:myTransform];
    [myAlert setTag:tag];
    [myAlert show];
//    [myAlert release];
}

@end
