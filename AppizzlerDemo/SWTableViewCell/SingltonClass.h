//
//  SingltonClass.h
//  CameraApp
//
//  Created by Lion User on 29/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SingltonClass : NSObject

+ (SingltonClass*) sharedData;


+(void) displayWarning:(NSString *) title message:(NSString *) message tag:(int)tag target:(id) target firstButtonTitle:(NSString *) aButton secondButtonTitle:(NSString *) bButton;
@end
