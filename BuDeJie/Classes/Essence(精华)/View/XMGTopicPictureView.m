//
//  XMGTopicPictureView.m
//  BuDeJie
//
//  Created by xiaomage on 16/3/24.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGTopicPictureView.h"

#import "XMGTopic.h"


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
	}];
	
	//gif
	XMGLog(@"---------%@----%@---%@", topic.image0, topic.image1, topic.image2);
	
	self.gifView.hidden = !topic.is_gif;
	
	//看大图
	if (topic.isBigPicture)
	{
		self.clickBigPictureBtn.hidden = NO;
		self.imageView.contentMode = UIViewContentModeTop;
		self.imageView.clipsToBounds = YES;
	}
	else
	{
		self.clickBigPictureBtn.hidden = YES;
		self.imageView.contentMode = UIViewContentModeScaleToFill;
		self.imageView.clipsToBounds = NO;
	}
}


- (IBAction)seeBigButtonClick:(id)sender {
	
}

@end
