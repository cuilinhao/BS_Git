//
//  XMGTopicPictureView.m
//  BuDeJie
//
//  Created by xiaomage on 16/3/24.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGTopicPictureView.h"
#import "XMGTopic.h"
#import "XMGSeeBigPictureViewController.h"



@interface XMGTopicPictureView ()

@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;
@property (weak, nonatomic) IBOutlet UIImageView *gifView;

@property (weak, nonatomic) IBOutlet UIButton *clickBigPictureBtn;


@end

@implementation XMGTopicPictureView

- (void)awakeFromNib
{
	[super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setTopic:(XMGTopic *)topic
{
	_topic = topic;
	
	// 设置图片
	self.placeholderView.hidden = NO;
	[self.imageView xmg_setOriginImage:topic.image1 thumbnailImage:topic.image0 placeholder:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if (!image) return;
		
		self.placeholderView.hidden = YES;
		//处理超长图片的大小
#pragma mark - 	对于大图片处理为 等比例修改 例如：300 x 400 = 355 x （355 *400/300）
#pragma mark -对于超长图片，这里使用安比例进行处理，用Context 将图片的rect进行修改，然后再进行渲染view
		if (topic.isBigPicture) {
			CGFloat imageW = topic.middleFrame.size.width;
			CGFloat imageH = imageW * topic.height / topic.width;
			
			//开启上下文
			UIGraphicsBeginImageContext(CGSizeMake(imageW, imageH));
			//绘制图片到上下文
			[self.imageView.image drawInRect:CGRectMake(0, 0, imageW, imageH)];
			self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
			//关闭上下文
			UIGraphicsEndImageContext();
		}
	}];
	
	//gif
	//XMGLog(@"---------%@----%@---%@", topic.image0, topic.image1, topic.image2);
	
	self.gifView.hidden = !topic.is_gif;
	//看大图
	if (topic.isBigPicture)
	{
		self.clickBigPictureBtn.hidden = NO;
		self.imageView.contentMode = UIViewContentModeTop;
		self.imageView.clipsToBounds = YES;
		//NSLog(@"___是大图_____00000");
	}
	else
	{
		self.clickBigPictureBtn.hidden = YES;
		self.imageView.contentMode = UIViewContentModeScaleToFill;
		self.imageView.clipsToBounds = NO;
		//NSLog(@"___不是大图_____00000");
	}
	self.clickBigPictureBtn.hidden = NO;
	
}

//MARK:- 查看大图
- (IBAction)seeBigButtonClick:(id)sender {
	
	XMGSeeBigPictureViewController * vc = [[XMGSeeBigPictureViewController alloc] init];
	vc.topic = self.topic;

	[self.window.rootViewController presentViewController:vc animated:YES completion:nil];
}

@end
