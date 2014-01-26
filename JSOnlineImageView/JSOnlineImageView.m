//
//  OnilneImage.m
//
//  Created by Jasim Sajid on 7/1/13.
//

#import "JSOnlineImageView.h"

#import "JSImageDownloader.h"

@interface JSOnlineImageView() <JSImageDownloaderDelegate>

@property(nonatomic, strong) JSImageDownloader *downloader;
@property(nonatomic, assign) NSInteger retries;
@end

#define MAX_IMAGE_DOWNLOAD_RETRIES 3

@implementation JSOnlineImageView

@synthesize activity;
@synthesize imageView;
@synthesize link;
@synthesize delegate;


-(id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        self.hasFinishedDownloadingImage=NO;
        self.retries=0;
        [self.activity setHidesWhenStopped:YES];

    }
    return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.hasFinishedDownloadingImage=NO;
    self.retries=0;
    [self.activity setHidesWhenStopped:YES];
}


-(void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}


-(void)startDownloadingWithLink:(NSString *)alink
{

#ifdef DEBUG
    alink=@"https://www.google.ae/images/srpr/logo4w.png";
#endif
    
    if(!self.hasFinishedDownloadingImage | (self.link && ![self.link isEqualToString:alink]))//if the link changed.
    {
        NSLog(@"%@",alink);

        [self setLink:alink];
        self.hasFinishedDownloadingImage=NO;
        
        if([[JSReachability serverReachability] currentReachabilityStatus]==NotReachable)
            return;

        [self.activity startAnimating];

        
        [self setDownloader:[[JSImageDownloader alloc] initWithLink:self.link delegate:self forIndexPath:nil shouldFetchFromCache:YES numberOfRetries:0]];
        [self.downloader startDownload];
    }

}

-(void)ImageDownloader:(JSImageDownloader *)downloader didFailedDownloadingImage:(id)anyObj
{
    [self.activity stopAnimating];
    
    self.hasFinishedDownloadingImage=NO;
    
    if([[JSReachability serverReachability] currentReachabilityStatus]!=NotReachable && self.retries<MAX_IMAGE_DOWNLOAD_RETRIES )
    {
        self.retries++;
        [self startDownloadingWithLink:self.link];
    }
    else
    {
        if(self.delegate)
            [self.delegate onlineImageView:self didFailDownloadingLink:self.link];
    }
}

-(void)ImageDownloader:(JSImageDownloader *)downloader didFinishDownloadingImageWithImagePath:(NSString *)path
{
    [self.activity stopAnimating];

    UIImage *image=[UIImage imageWithContentsOfFile:path];
    if(image)
    {
        [self.imageView setImage:image];
        self.hasFinishedDownloadingImage=YES;
        self.retries=0;
        
        if(self.delegate)
            [self.delegate onlineImageView:self didFinishDownloadingLink:self.link];

    }
    else if([[JSReachability serverReachability] currentReachabilityStatus]!=NotReachable && self.retries<MAX_IMAGE_DOWNLOAD_RETRIES )
    {
        self.retries++;
        [self startDownloadingWithLink:self.link];
    }
}


@end
