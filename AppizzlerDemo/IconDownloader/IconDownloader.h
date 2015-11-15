#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    NSString *imageUrl;
    UIImage *imageIcon;
    UIImageView *indexPathForImageView;
    UIImageView *panelImageView;
    UIView *greyBG;
    UIView *mainView;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    int tag_id ;
    NSString *imageID;
}

@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *imageID;
@property (nonatomic, retain) UIImage *imageIcon;
@property (nonatomic, retain) UIImageView *indexPathForImageView;
@property (nonatomic, retain) UIImageView *panelImageView;
@property (nonatomic, retain) UIView *greyBG;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic) int tag_id;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

- (void)appImageDidLoad:(UIImageView *)imagePath url:(NSString *)url imageID:(NSString *)imageID;

@end