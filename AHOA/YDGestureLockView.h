//
//  YDGestureLockView.h
//  hnOA
//
//  Created by 224 on 14-7-1.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

/**
 *类似android的九宫格手势密码解锁类
**/

#import <UIKit/UIKit.h>

//密码状态,用状态控制输入密码和确认密码
typedef enum ePasswordState {
    ePasswordUnset,//未设置
    ePasswordRepeat,//重复输入
    ePasswordExist,//密码设置成功
    ePasswordLogin,//跳转MainController
    ePasswordOld //原始密码
} ePasswordState;

@class YDGestureLockView;

@protocol YDGestureLockViewDelegate <NSObject>
//自定义一个协议，将当前视图作为参数，传递解锁密码
- (void)LockViewDidClick:(YDGestureLockView *)lockView andPassword:(NSString *)pwd;

@end

@interface YDGestureLockView : UIView

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic) CGPoint currentPoint;
@property (weak, nonatomic) id<YDGestureLockViewDelegate>delegate;

@end
