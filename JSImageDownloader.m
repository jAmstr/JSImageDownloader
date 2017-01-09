//
//  ImageDownloader.m
//
//  Created by fares jAmstr on 15/03/10.

#import "JSImageDownloader.h"



@implementation JSImageDownloader

@synthesize link;
@synthesize delegate;
@synthesize activeDownload;
@synthesize forIndexPath;
@synthesize downloadingStatus;
@synthesize numberOfRetries;


-(id)initWithLink:(NSString *)aLink delegate:(id<JSImageDownloaderDelegate>)delta forIndexPath:(NSIndexPath *)path shouldFetchFromCache:(BOOL)ffc numberOfRetries:(NSInteger)retries;
{
    if((self=[super init]))
    {
        [self setLink:aLink];
        [self setDelegate:delta];
        [self setForIndexPath:path];
        [self setShouldFetchFromCache:ffc];
        [self setNumberOfRetries:retries];
    }
    return self;
}



+(NSString *)getFilePathforURL:(NSString *)url
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [paths objectAtIndex:0];
	NSArray *comps=[[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"];
	
	NSString *name=[NSString stringWithFormat:@"%@-%@",[comps objectAtIndex:[comps indexOfObject:[comps lastObject]]-1],[comps lastObject]];
	
	return [cachePath stringByAppendingPathComponent:name];
}

- (void)startDownload
{
    [self startWithDelay];
}


-(void)startWithDelay
{
    if(!link || [link length]==0)
    {
        [self.delegate ImageDownloader:self didFailedDownloadingImage:@(imageDownloader_DoNotRetry)];
        
        return;
    }
    
    
    link=[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	
	NSString *fileName=[[self class] getFilePathforURL:link];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName] && self.shouldFetchFromCache)
	{
        [self setDownloadingStatus:kLoadedFromCache];
        [delegate ImageDownloader:self didFinishDownloadingImageWithImagePath:fileName];
		
		return;
	}
    
	
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
	   
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
							 [NSURLRequest requestWithURL:
							  [NSURL URLWithString:link]] delegate:self];
    
	[conn start];

}



- (void)cancelDownload
{
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    NSLog(@"%@",error.description);
    
    // Release the connection now that it's finished
	
    [delegate ImageDownloader:self didFailedDownloadingImage:error.description];
    
}


- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] > 0)
    {
        // do something may be alert message
    }
    else
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:MY_SERVER_USERNAME
                                                                 password:MY_SERVER_PASSWORD
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    NSInteger dataLength=self.activeDownload.length;
    NSInteger bytes=dataLength/2;
    
    if(bytes > 0 ) // greater than 1KB
    {
        
        NSString *fileName=[[self class] getFilePathforURL:link];

        if([[NSFileManager defaultManager] createFileAtPath:fileName contents:self.activeDownload attributes:nil])
        {
            [self setDownloadingStatus:kLoadedFromConnection];
            [delegate ImageDownloader:self didFinishDownloadingImageWithImagePath:fileName]; 
        }
        else
        {
            self.activeDownload = nil;
            [delegate ImageDownloader:self didFailedDownloadingImage:nil];
            return;
        }
    }
    else
    {
        [delegate ImageDownloader:self didFailedDownloadingImage:nil];
    }
	self.activeDownload = nil;
    


}




@end

