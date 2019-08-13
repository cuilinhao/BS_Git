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
    
}

- (XMGTopicType)type
{
    return XMGTopicTypeAll;
}


@end
