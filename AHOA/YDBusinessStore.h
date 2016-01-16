//
//  YDBusinessStore.h
//  SaleAnalysis
//
//  Created by 224 on 15/4/13.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BusinessSOAPDelegate <NSObject>

- (void)passBusinessArray:(NSMutableArray *)businessArray;

@end

@interface YDBusinessStore : NSObject

@property (weak, nonatomic) id<BusinessSOAPDelegate>businessDelegate;

+ (instancetype)sharedBusinessStore;

- (void)getBusinessSOAP:(NSString *)timeStamp;

- (void)archivedData:(id)object forCode:(NSString *)code;

- (id)unarchivedData:(NSString *)code;

- (void)removePath;

- (BOOL)comPareDate:(NSDate *)currentDate;

@end
