JSImageDownloader
=================

Image Downloading Utility for iOS. 

Downloads Images from links and stores them in NSCachesDirectory, so when you fetch it again, the image is fetched from the cache.

Use it directly to download images.

Or you can use JSOnlineImageView to implement it for a UIImageView. 
To use JSOnlineImage View copy the View object from the JSOnlineImageView.xib file and paste it into your NIBs as a subview to your existing view. Reference it in your code and call start whenever you wish to load the image.
