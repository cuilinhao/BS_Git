//
//  XMGAllViewController.m
//  BuDeJie
//
//  Created by xiaomage on 16/3/18.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGAllViewController.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "XMGTopic.h"
#import <SVProgressHUD.h>
#import "XMGTopicCell.h"
#import <SDImageCache.h>


@implementation XMGAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 如果这样写，会有问题，因为，
     在调用super时候，就会使用到type，
     所以在这个地方写，是有问题的
     
     */
    //self.type = XMGTopicTypeAll;
}

- (XMGTopicType)type
{
    return XMGTopicTypeAll;
}


@end
