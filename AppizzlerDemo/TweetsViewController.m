//
//  FirstViewController.m
//  AppizzlerDemo
//
//  Created by Rana M Mateen on 12/11/2015.
//  Copyright (c) 2015 MattDev. All rights reserved.
//

#import "TweetsViewController.h"
#import "NSData+Base64.h"
#import "AFNetworking/AFNetworking.h"
#import "Constants.h"
#import "SingltonClass.h"

@interface TweetsViewController ()

@end

@implementation TweetsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    defaults = [NSUserDefaults standardUserDefaults];
    _bearerToken = [defaults objectForKey:BEARER_KEY];
    if (_bearerToken==nil){
        [btnLogin setTitle:@"Authorise" forState:UIControlStateNormal];
    }else{
        [btnLogin setTitle:@"Search Tweets" forState:UIControlStateNormal];
        [lblHelp setHidden:YES];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:61/255.0 green:191/255.0 blue:168/255.0 alpha:1];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    
    if(_bearerToken == nil){
        [self bearerTokenRequest];
        return;
    }else{
//        [self performSegueWithIdentifier:@"goSearch" sender:self];
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
        
    
}

- (void) bearerTokenRequest
{
    if(_bearerToken == nil)
    {
        NSString * consumerKey = @"x3uWx4usZCa6fH86JGVuDoDRS";
        NSString * consumerSecret = @"upNIqKdPg9FEzGzwaS6rKpjiO6VLlK8vTdhqr9qKOTfJW4s7zM";
        consumerKey = [consumerKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         consumerSecret = [consumerSecret stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * combinedKey = [[self class] _base64Encode:[[NSString stringWithFormat:@"%@:%@", consumerKey, consumerSecret] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth2/token"]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:[NSString stringWithFormat:@"Basic %@", combinedKey] forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded;charset=UTF-8"] forHTTPHeaderField:@"Content-Type"];

        [urlRequest setHTTPBody:[@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *sendRequest = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        sendRequest.responseSerializer = [AFJSONResponseSerializer serializer];
        [sendRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON responseObject: %@ ",responseObject);
            
            _bearerToken = [responseObject valueForKey:@"access_token"];
            [defaults setObject:_bearerToken forKey:BEARER_KEY];
            [btnLogin setTitle:@"Search Tweets" forState:UIControlStateNormal];
            [lblHelp setHidden:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [SingltonClass displayWarning:@"Connectivity Status" message:@"Sorry. We cannot reach server. Please try again." tag:OK_ONLY_TAG target:self firstButtonTitle:@"OK" secondButtonTitle:nil];
            
        }];
        [sendRequest start];
    }
}

+(NSString *)_base64Encode:(NSData *)data{
    //Point to start of the data and set buffer sizes
    NSInteger inLength = [data length];
    NSInteger outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer);
    return pictemp;
}


//text = "@Annalana Hi... Is Annalana from periscope?";
//name = Matt;
//"profile_image_url" = "http://pbs.twimg.com/profile_images/634708196272148480/qiiKZIbU_normal.jpg";
//"screen_name" = mattdevcloud;


@end
