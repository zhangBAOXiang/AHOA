//
//  YDGestureLockView.m
//  hnOA
//
//  Created by 224 on 14-7-1.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDGestureLockView.h"

@implementation YDGestureLockView

- (NSMutableArray *)buttons
{
    if (_buttons==nil) {
        _buttons=[NSMutableArray array];
    }
    return _buttons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
     
    }
    return self;
}

//nib文件会调用此方法，否则调用initwithframe初始化界面
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    for (int i=0; i<9; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"indicator_lock_area.png"] forState:UIControlStateSelected];
        //btn.layer.masksToBounds=YES;
        [self addSubview:btn];
        
        btn.userInteractionEnabled=NO;
        btn.tag=i;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor=[UIColor clearColor];
    for (int i=0;i<self.subviews.count; i++) {
        //取出按钮
        UIButton *btn=self.subviews[i];
        [btn setFrame:CGRectMake(26+(i%3)*98, (i/3)*98, 72, 72)];
    }


    
}

//监听手指的移动
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint startPoint=[self getCurrentPoint:touches];
    UIButton *btn=[self getCurrentBtnWithPoint:startPoint];
    if (btn && btn.selected!=YES) {
        btn.selected=YES;
        [self.buttons addObject:btn];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint movePoint=[self getCurrentPoint:touches];
    UIButton *btn=[self getCurrentBtnWithPoint:movePoint];
    // 存储按钮
    //已经连接过的按钮不可再连
    if (btn && btn.selected!=YES) {
        btn.selected=YES;
        [self.buttons addObject:btn];
    }
    //记录当前点（不在按钮的范围内）
    self.currentPoint=movePoint;
    //通知view重新绘图
    [self setNeedsDisplay];
}

//手指离开的时候清除线条
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //取出用户的密码
    NSMutableString *result=[NSMutableString string];
    for (UIButton *btn in self.buttons) {
        [result appendFormat:@"%ld",(long)btn.tag];
    }
    
    NSLog(@"用户输入的密码为: %@",result);
    //通知代理，告知用户输入的密码
    if ([self.delegate respondsToSelector:@selector(LockViewDidClick:andPassword:)]) {
        [self.delegate LockViewDidClick:self andPassword:result];
    }
    
    //调用该方法，它就会让数组中的每一个元素都调用setSelected:方法，并给每一个元素传递一个NO参数
    [self.buttons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    //清空数组
    [self.buttons removeAllObjects];
    [self setNeedsDisplay];
    
    //清空当前点
    self.currentPoint=CGPointZero;
}



//对功能点进行封装
- (CGPoint)getCurrentPoint:(NSSet *)touches
{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:touch.view];
    return point;
}
- (UIButton *)getCurrentBtnWithPoint:(CGPoint)point
{
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return Nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//绘图
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //获取上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    //每次绘制前，清空上下文
    CGContextClearRect(context, rect);
    //绘图（线段）
    for (int i=0; i<self.buttons.count; i++) {
        UIButton *btn=self.buttons[i];
        if (0==i) {
            //设置起点，注意连接的是中点
            CGContextMoveToPoint(context, btn.center.x, btn.center.y);
        }else {
            CGContextAddLineToPoint(context, btn.center.x, btn.center.y);
        }
    }
    
    //当所有按钮的中点都连接好之后，再连接手指当前的位置
    //判断数组中是否有按钮，只有有按钮的时候才绘制
    if (self.buttons.count!=0) {
        CGContextAddLineToPoint(context, self.currentPoint.x, self.currentPoint.y);
    }
    //渲染，设置线条属性
    CGContextSetLineWidth(context, 9);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetRGBStrokeColor(context, 03/255.0, 77/255.0, 115/255.0, 1);
    CGContextStrokePath(context);
}

@end
