//
//  OnilneImage.h
//
//  Created by Jasim Sajid on 7/1/13.
//

#import <UIKit/UIKit.h>

@protocol OnlineImageViewDelegate;


@interface JSOnlineImageView : UIView

@property(nonatomic, assign) IBOutlet UIActivityIndicatorView   *activity;
@property(nonatomic, assign) IBOutlet UIImageView               *imageView;
@property(nonatomic, strong) NSString                           *link;
@property(nonatomic, assign) BOOL                                hasFinishedDownloadingImage;
@property(nonatomic, assign) IBOutlet id<OnlineImageViewDelegate>delegate;

-(void)startDownloadingWithLink:(NSString *)alink;
-(void)setImage:(UIImage *)image;

@end

@protocol OnlineImageViewDelegate

@optional
-(void)onlineImageView:(JSOnlineImageView *)sender didFinishDownloadingLink:(NSString *)link;
@optional
-(void)onlineImageView:(JSOnlineImageView *)sender didFailDownloadingLink:(NSString *)link;

@end