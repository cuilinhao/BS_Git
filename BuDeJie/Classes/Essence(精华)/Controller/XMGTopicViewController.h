//
//  XMGTopicViewController.h
//  BuDeJie
//
//  Created by 天下林子 on 2019/8/13.
//  Copyright © 2019 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMGTopic.h"


NS_ASSUME_NONNULL_BEGIN

@interface XMGTopicViewController : UITableViewController

//只生成getter方法， 多生成一个下划线的成员变量
//@property (nonatomic, assign, readonly) XMGTopicType  type;

- (XMGTopicType)type;

@end

NS_ASSUME_NONNULL_END
