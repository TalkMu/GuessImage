//
//  GKQuestion.h
//  GuessImage
//
//  Created by Zhuang Yang on 2019/10/18.
//  Copyright © 2019 Zhuang Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKQuestion : NSObject

/// 答案
@property (nonatomic,copy) NSString *answer;


/// 图标
@property (nonatomic,copy) NSString *icon;


/// 标题
@property (nonatomic,copy) NSString *title;


/// 待选文字
@property (nonatomic,strong) NSArray *options;


/// 内部字典处理方法
/// @param dict 待处理字典
- (instancetype)initWithDict:(NSDictionary *) dict;


/// 外部字典处理方法
/// @param dict 待处理字典
+ (instancetype)questionWithDict:(NSDictionary *) dict;


/// 懒加载数据
+ (NSArray *)questionList;
@end

NS_ASSUME_NONNULL_END
