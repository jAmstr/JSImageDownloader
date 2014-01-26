//
//  ImageDownloader.h
//
//
//  Created by fares jAmstr on 15/03/10.
//


#import <Foundation/Foundation.h>

@protocol JSImageDownloaderDelegate;

typedef enum
{
    kLoadedFromCache,
    kLoadedFromConnection
    
} DownloadingStatus;


typedef enum
{
    imageDownloader_ShouldRetry,
    imageDownloader_DoNotRetry
    
}ImageDownloaderRetryStatus;


@interface JSImageDownloader : NSObject
{
	NSString                    *link;
    NSIndexPath                 *forIndexPath;
    id <JSImageDownloaderDelegate>delegate;
    NSFileHandle                *fileHandle;
    NSMutableData				*activeDownload;
    DownloadingStatus           downloadingStatus;
    NSInteger                   numberOfRetries;
}

@property (nonatomic, strong) NSString						*link;
@property (nonatomic, strong) id <JSImageDownloaderDelegate>	delegate;
@property (nonatomic, assign) BOOL                          shouldFetchFromCache;

@property (nonatomic, strong) NSMutableData					*activeDownload;
@property (nonatomic, strong) NSIndexPath                   *forIndexPath;
@property (nonatomic, assign) DownloadingStatus             downloadingStatus;
@property (nonatomic, assign) NSInteger                     numberOfRetries;


-(id)initWithLink:(NSString *)aLink delegate:(id<JSImageDownloaderDelegate>)delta forIndexPath:(NSIndexPath *)path shouldFetchFromCache:(BOOL)ffc numberOfRetries:(NSInteger)retries;


- (void)startDownload;
- (void)cancelDownload;
+ (NSString *)getFilePathforURL:(NSString *)url;

@end

@protocol JSImageDownloaderDelegate 

- (void)ImageDownloader:(JSImageDownloader *)downloader didFinishDownloadingImageWithImagePath:(NSString *)path;
- (void)ImageDownloader:(JSImageDownloader *)downloader didFailedDownloadingImage:(id)anyObj;

@end