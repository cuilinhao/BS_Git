//
//  XMGSeeBigPictureViewController.m
//  3期-百思不得姐
//
//  Created by xiaomage on 15/9/16.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import "XMGSeeBigPictureViewController.h"
#import <UIImageView+WebCache.h>
#import "XMGTopic.h"
#import <SVProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


@interface XMGSeeBigPictureViewController () <UIScrollViewDelegate>
/** 图片 */
@property (nonatomic, weak) UIImageView *imageView;
/** 相册库 */
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

/** 当前App对应的自定义相册 */
- (PHAssetCollection *)createdCollection;

@end

@implementation XMGSeeBigPictureViewController


/**
 一种开发思路
 1. viewDidLoad 中创建子控件
 2. 在viewDidLayoutSubviews 中布局控件
 
 第二种思路：
 1.控件使用懒加载
 */

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self _initUI];
	
}

- (void)_initUI
{
	UIScrollView *scrolleView = [[UIScrollView alloc] init];
	scrolleView.frame = self.view.bounds;
	scrolleView.backgroundColor = [UIColor blackColor];
	//让scrolleView 全屏显示 也可以直接设置screen宽和高
	scrolleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[scrolleView addGestureRecognizer:[[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(back)]];
	[self.view insertSubview:scrolleView atIndex:0];
	
	UIImageView *imageView = [[UIImageView alloc] init];
	[imageView sd_setImageWithURL:[NSURL URLWithString:self.topic.image1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if (!image) return ;
		self.saveBtn.enabled = YES;
		
	}];
	imageView.xmg_width = scrolleView.xmg_width;
	imageView.xmg_height = imageView.xmg_width *self.topic.height / self.topic.width;
	imageView.xmg_x = 0;
	if (imageView.xmg_height > XMGScreenH) {
		imageView.xmg_y = 0;
		scrolleView.contentSize = CGSizeMake(0, imageView.xmg_height);
	}
	else
	{
		imageView.xmg_centerY = scrolleView.xmg_height * 0.5;
	}
	self.imageView = imageView;
	//求出图片最大缩放图片
	CGFloat maxScale = self.topic.width / imageView.xmg_width;
	if (maxScale > 1) {
		scrolleView.maximumZoomScale = 2.0;
		scrolleView.delegate = self;
	}
	
	[scrolleView addSubview: imageView];
}


- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

#pragma mark - Delegate
// return a view that will be scaled. if delegate returns nil, nothing happens
//图片缩放
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

#pragma mark - Action
- (IBAction)back {
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

/** 注释
 
 //保存图片到相机胶卷
 //拥有一个 自定义相册
 //添加刚才保存的图片到自定义相册
 
 一，保存图片到自定义相册
 1.保存图片到相机胶卷
 1>C语言y函数
 UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
 
 2>AssetsLibrary 框架 ios9 废弃了
 3>photos框架 ios8 开始使用
 
 2.拥有一个自定义相册
 1>AssetsLibrary框架
 2>Photos框架
 
 3.添加刚才保存的图片到自定义相册
 1>AssetsLibrary框架
 2>Photos框架
 
 二： Photos框架须知
 1.PHAsset :一个PHAsset 对象就代表相册中的一个图片或一个视频
 1> 查：[PHAsset fetchAssets...]
 2> 增删改： PHAsserChangeRequest(包括所有跟图片\相册相关改动操作)
 
 
 2. PHAssetcollection: 一个PHAssetcollection 对象代表一个相册
 1> 查：[PHAssetcollection fetchAssets...]
 2> 增删改： PHAsserCollectionChangeRequest
 
 3. 对相片、相册的任何 增删改都必须放到下面的block中执行
 PHPhotoLibrary performChanges：
 [PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait
 
 
 //异步执行修改操作
 //performChanges 是异步修改
 //Asynchronously runs a block that requests changes to be performed in the photo library.
 [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
 
 } completionHandler:^(BOOL success, NSError * _Nullable error) {
 
 }];
 
 NSError *error = nil;
 
 //同步执行修改操作
 //performChangesAndWait 是同步修改
 //Synchronously runs a block that requests changes to be performed in the photo library.
 
 [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
 [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
 } error:&error];
 
 if (error) {
 [SVProgressHUD showErrorWithStatus:@"保存失败"];
 }
 else
 {
 [SVProgressHUD showSuccessWithStatus:@"保存成功"];
 }
 
 */

/** 注释
 2019-08-04 15:34:07.132363+0800 BuDeJie[3517:155068] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[NSInvocation setArgument:atIndex:]: index (2) out of bounds [-1, 1]'
 *** First throw call stack:
 */

/** 注释
Foundation 和Core Foundation 的数据类型可以相互转换，比如 NSString 和CFStringRef
 NSString *string = (__bridge NSString *)kCFBundleNameKey;
 CFStringRef string = (__bridge CFStringRef)@"test";
 
 */

- (IBAction)save
{
	
	// Adds a photo to the saved photos album.  The optional completionSelector should have the form:
	//UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	
	//异步执行修改操作
	//performChanges 是异步修改
	//Asynchronously runs a block that requests changes to be performed in the photo library.
	/*
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		
	}];
	*/
	
	
	
	//同步执行修改操作
	//performChangesAndWait 是同步修改
	//Synchronously runs a block that requests changes to be performed in the photo library.
	/*
	[[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
		[PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
	} error:&error];
	
	if (error) {
		[SVProgressHUD showErrorWithStatus:@"保存失败"];
	}
	else
	{
		[SVProgressHUD showSuccessWithStatus:@"保存成功"];
	}
	 */
	
	self.createdCollection;
	
}

- (PHAssetCollection *)createdCollection
{
	//获取软件名字
	NSString *title = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
	PHFetchResult<PHAssetCollection *> *collections =  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
	//查找当前App对应的自定义相册
	__block NSString *ID = nil;
	for (PHAssetCollection *collection in collections) {
		XMGLog(@"%@", collection.localizedTitle);
		if ([collection.localizedTitle isEqualToString:title]) {
			return collection;
		}
	}
	
	/*当前没有被 创建过**/
	//创建一个自定义相册
	NSError *error = nil;
	//performChangesAndWait 是一个同步的方法，只有这个方法全部执行完之后才会创建相册成功
	[[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
		//执行完creationRequestForAssetCollectionWithTitle 相册还没有成功，所以要使用标示来创建
		ID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
	} error:&error];
	
	if (error)
	{
		[SVProgressHUD showErrorWithStatus:@"创建失败"];
		return nil;
	}
	
	return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ID] options:nil].firstObject;
	

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (error) {
		[SVProgressHUD showErrorWithStatus:@"保存失败"];
	}
	else
	{
		[SVProgressHUD showSuccessWithStatus:@"保存成功"];
	}
}



@end
