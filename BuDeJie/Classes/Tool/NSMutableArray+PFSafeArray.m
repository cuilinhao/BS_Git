//
//  NSMutableArray+PFSafeArray.m
//  BuDeJie
//
//  Created by 崔林豪 on 2019/6/17.
//  Copyright © 2019 小码哥. All rights reserved.
//

#import "NSMutableArray+PFSafeArray.h"

@implementation NSMutableArray (PFSafeArray)

- (id)pf_objWithIndex:(NSUInteger)index
{
	if (index < self.count)
	{
		return self[index];
	}
	else
	{
		return nil;
	}
}

@end
