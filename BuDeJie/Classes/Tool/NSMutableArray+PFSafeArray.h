//
//  NSMutableArray+PFSafeArray.h
//  BuDeJie
//
//  Created by 崔林豪 on 2019/6/17.
//  Copyright © 2019 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (PFSafeArray)

- (id)pf_objWithIndex:(NSUInteger)index;



@end

NS_ASSUME_NONNULL_END
