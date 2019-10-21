//
//  GKQuestion.m
//  GuessImage
//
//  Created by Zhuang Yang on 2019/10/18.
//  Copyright © 2019 Zhuang Yang. All rights reserved.
//

#import "GKQuestion.h"

@implementation GKQuestion

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.answer = dict[@"answer"];
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
        self.options = dict[@"options"];
    }
    return self;
    
}

+ (instancetype)questionWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)questionList
{
    //加载数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
    NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSDictionary *dict in arrayDict) {
        [arrayM addObject:[self questionWithDict:dict]];
    }
    
    return arrayM;
}
@end
