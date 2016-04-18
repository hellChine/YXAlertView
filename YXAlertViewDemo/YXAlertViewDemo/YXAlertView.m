//
//  YXAlertView.m
//  TestDemo
//
//  Created by Alvin on 16/4/11.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import "YXAlertView.h"

//（动画区域）半径
NSInteger const indicateRadius = 40;
CGFloat const indicateLineWidth = 3;
NSInteger const actionSheetButtonHeight = 55;
NSInteger const alertButtonHeight = 50;
#define alertStyleWith [UIScreen mainScreen].bounds.size.width
#define alertStyleHeight [UIScreen mainScreen].bounds.size.height
#define YXColor(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]


@interface YXAlertView()
@property (nonatomic, assign) YXAlertViewStyle alertViewStyle;
@property (nullable, nonatomic, strong) UILabel *titleLabel;
@property (nullable, nonatomic, strong) UILabel *messageLabel;
@property (nullable, nonatomic, strong) UIView *alertCanvas;
@property (nullable, nonatomic, strong) NSMutableArray *buttonTitles;
@property (nullable, nonatomic, strong) NSString *cancelTitle;
@property (nonnull, nonatomic, strong) UIWindow *alertKeyWindow;
@property (nullable, nonatomic, strong) UIButton *cancelButton;
@end

@interface YXSingleTon : NSObject

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) NSMutableArray *alertStack;

@end

@implementation YXSingleTon

+ (instancetype)sharedInstance{
    static YXSingleTon *shareSingleTon = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareSingleTon = [YXSingleTon new];
    });
    return shareSingleTon;
}

- (UIWindow *)alertWindow{
    if (!_alertWindow) {
        _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _alertWindow.windowLevel = UIWindowLevelAlert + 1;
    }
    return _alertWindow;
}

- (NSMutableArray *)alertStack{
    if (!_alertStack) {
        _alertStack = [NSMutableArray array];
    }
    return _alertStack;
}

@end


@implementation YXAlertView

@synthesize alertViewStyle;
@synthesize alertTitle;
@synthesize alertMessage;
@synthesize alertCanvas;
@synthesize buttonTitles;
@synthesize titleLabel;
@synthesize messageLabel;
@synthesize cancelTitle;
@synthesize alertKeyWindow;
@synthesize cancelButton;

- (instancetype)initWithStyle:(YXAlertViewStyle)style title:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id /*<YXAlertViewDelegate>*/)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.hidden = NO;//不隐藏
        
        alertViewStyle = style;
        alertTitle = title;
        alertMessage = message;
        _delegate = delegate;
        cancelTitle = cancelButtonTitle;
        
        if(otherButtonTitles)
        {
            NSString *curStr;
            va_list args;
            buttonTitles = [NSMutableArray array];
            [buttonTitles addObject:otherButtonTitles];
            
            va_start(args, otherButtonTitles); // scan for arguments after firstObject.
            while ((curStr = va_arg(args, NSString*))) {
                [buttonTitles addObject:curStr];
            }
            va_end(args);
            
        }
        [self setup];
    }
    return self;
    
}
- (void)dealloc
{
//    NSLog(@"dealloc");
}
#pragma mark - life cylce
- (void)show;
{
    NSInteger count = [YXSingleTon sharedInstance].alertStack.count;
    YXAlertView *previousAlert = nil;
    if (count > 0) {
        previousAlert = [[YXSingleTon sharedInstance].alertStack firstObject];
    }
    if (previousAlert) {
        alertKeyWindow = [YXSingleTon sharedInstance].alertWindow;
        alertKeyWindow.hidden = NO;
        [alertKeyWindow addSubview:previousAlert];
        [alertKeyWindow makeKeyAndVisible];
    }

}
- (void)dismiss
{
    alertKeyWindow.hidden = YES;
    [self removeFromSuperview];
    NSInteger count = [YXSingleTon sharedInstance].alertStack.count;
    if (count > 0) {
        [[YXSingleTon sharedInstance].alertStack removeObjectAtIndex:0];
        [self show];
    }else
    {
        alertKeyWindow = nil;
    }
}

- (void)alertViewCancelAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:sender.tag];
    }
    [self dismiss];
}
- (void)otherButtonAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:sender.tag];
        [self dismiss];
    }
}

- (void)setup
{
    switch (alertViewStyle) {
        case YXAlertViewStyleDefault:
            if (!alertCanvas) {
                [self initAlertStyle];
            }
            [self initElements];
            break;
        case YXAlertViewStyleSuccess:
            [self drawRight];
            [self initElements];
            break;
        case YXAlertViewStyleWaring:
            [self drawWaring];
            [self initElements];
            break;
        case YXAlertViewStyleFail:
            [self drawWrong];
            [self initElements];
            break;
        case YXAlertViewStyleSheet:
            [self initActionSheet];
            break;
        default:
            break;
    }

    
    [[YXSingleTon sharedInstance].alertStack addObject:self];
}
#pragma mark - initElment
- (void)initActionSheet
{
    CGFloat contentViewHeight = 45;
    if (buttonTitles) {
        contentViewHeight = buttonTitles.count * actionSheetButtonHeight + 45;
    }
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(15, alertStyleHeight - contentViewHeight - 70, alertStyleWith - 30, contentViewHeight)];
    CGFloat width = CGRectGetWidth(contentView.bounds);
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = YES;
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width, 40)];
    titleLabel.text = alertTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [contentView addSubview:titleLabel];
    
    if (buttonTitles) {
        CGFloat buttonWidth = alertStyleWith - 28;
        CGFloat buttonY = CGRectGetMaxY(titleLabel.frame);
        for (int i = 1; i <= buttonTitles.count; i ++) {
            UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            otherButton.tag = i;
            otherButton.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
            otherButton.layer.borderWidth = 0.5;
            [otherButton setTitle:[buttonTitles objectAtIndex:i - 1] forState:UIControlStateNormal];
            [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            otherButton.frame = CGRectMake(- 1, (i - 1) * actionSheetButtonHeight + buttonY , buttonWidth, actionSheetButtonHeight);
            otherButton.titleLabel.font = [UIFont systemFontOfSize:19];
            [otherButton addTarget:self action:@selector(otherButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:otherButton];
        }
    }
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor whiteColor];
    cancelButton.tag = 0;
    cancelButton.layer.cornerRadius = 10;
    cancelButton.frame = CGRectMake(15, alertStyleHeight - 60, alertStyleWith - 30, 45);
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:YXColor(0, 150, 70, 1) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertViewCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
}
- (void)initElements
{
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGFloat width = alertCanvas.frame.size.width;
    
    if (alertTitle && alertViewStyle == YXAlertViewStyleDefault) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 20, width, 30)];
        [titleLabel setText:alertTitle];
        [titleLabel setFont:[UIFont systemFontOfSize:18]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [alertCanvas addSubview:titleLabel];
    }
    
    CGFloat messageY = titleLabel ? CGRectGetHeight(titleLabel.frame) + 20 : alertViewStyle == YXAlertViewStyleDefault ? 20 : CGRectGetMidY(alertCanvas.bounds) - 10;
    messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = 0;
    messageLabel.text = alertMessage;
//    messageLabel.backgroundColor = [UIColor blueColor];
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:16];
    float messageHeight = ceil(alertMessage.length * 18.0 / (width - 40)) * 20.0 + 20;
    messageLabel.frame = CGRectMake(x + 20, messageY, width - 40, messageHeight);
    [alertCanvas addSubview:messageLabel];

    CGRect rect = alertCanvas.bounds;
    rect.size.height = CGRectGetMaxY(messageLabel.frame) + 60;
    alertCanvas.bounds = rect;
    
    CGFloat height = alertCanvas.frame.size.height;
    if (cancelTitle) {
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.tag = -1;
        cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cancelButton.layer.borderWidth = 0.5;
        [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:YXColor(0, 150, 70, 1) forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(-1, height - alertButtonHeight, width + 2, alertButtonHeight);
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        [cancelButton addTarget:self action:@selector(alertViewCancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [alertCanvas addSubview:cancelButton];
    }

    if (buttonTitles) {
        CGFloat buttonWidth = 1 + (width + 2) / (buttonTitles.count + (cancelButton ? 1 : 0));
        if (cancelButton) {
            cancelButton.frame = CGRectMake(-1, height - alertButtonHeight, buttonWidth, alertButtonHeight);
            cancelButton.tag = 0;
        }
        CGFloat otherButtonOffset = cancelButton ? 0 : 1;
        for (int i = 1; i <= buttonTitles.count; i ++) {
            UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            otherButton.tag = i;
            otherButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            otherButton.layer.borderWidth = 0.5;
            [otherButton setTitle:[buttonTitles objectAtIndex:i - 1] forState:UIControlStateNormal];
            [otherButton setTitleColor:YXColor(0, 150, 70, 1) forState:UIControlStateNormal];
            CGFloat otherButtonX = (i - otherButtonOffset) * buttonWidth - 1;
            otherButton.frame = CGRectMake(otherButtonX, height - alertButtonHeight, buttonWidth, alertButtonHeight);
            otherButton.titleLabel.font = [UIFont boldSystemFontOfSize:19];
            [otherButton addTarget:self action:@selector(otherButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [alertCanvas addSubview:otherButton];
        }
    }


    alertCanvas.clipsToBounds = YES;
}

- (void)initAlertStyle
{
    //移除画布
    [alertCanvas removeFromSuperview];
    alertCanvas = nil;
    //新建画布
    alertCanvas                     = [UIView new];
    alertCanvas.center              = CGPointMake(self.center.x, self.center.y - 20);
    alertCanvas.bounds              = CGRectMake(0, 0, alertStyleWith / 1.23, alertStyleWith / 1.5);
    alertCanvas.backgroundColor     = [UIColor whiteColor];
    alertCanvas.layer.cornerRadius  = 10;
    alertCanvas.layer.shadowColor   = [UIColor blackColor].CGColor;
    alertCanvas.layer.shadowOffset  = CGSizeMake(0, 5);
    alertCanvas.layer.shadowOpacity = 0.3f;
    alertCanvas.layer.shadowRadius  = 10.0f;
    
    //保证画布位于所有视图层级的最下方
    [self addSubview:alertCanvas];
}
/**
 *  画圆和勾
 */
-(void) drawRight
{
    
    [self initAlertStyle];
    //自绘制图标中心点
    CGPoint pathCenter = CGPointMake(CGRectGetMidX(alertCanvas.bounds), CGRectGetMidY(alertCanvas.bounds) / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pathCenter radius:indicateRadius startAngle:M_PI endAngle:M_PI*3 clockwise:YES];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    
    CGFloat x = pathCenter.x - 20;
    CGFloat y = pathCenter.y + 5;
    //勾的起点
    [path moveToPoint:CGPointMake(x, y)];
    //勾的最底端
    CGPoint p1 = CGPointMake(x + 15, y + 10);
    [path addLineToPoint:p1];
    //勾的最上端
    CGPoint p2 = CGPointMake(x + 35,y - 20);
    [path addLineToPoint:p2];
    //新建图层——绘制上面的圆圈和勾
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.lineWidth = indicateLineWidth;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [alertCanvas.layer addSublayer:layer];
    
}

/**
 *  画三角形以及感叹号
 */
-(void) drawWaring
{
    [self initAlertStyle];
    //自绘制图标中心点
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    //绘制三角形
    CGFloat x = CGRectGetMidX(alertCanvas.bounds);
    CGFloat y = CGRectGetMidY(alertCanvas.bounds) / 2 - indicateRadius;
    //三角形起点（上方）
    [path moveToPoint:CGPointMake(x, y)];
    //左边
    CGPoint p1 = CGPointMake(x - 45, y + 80);
    [path addLineToPoint:p1];
    //右边
    CGPoint p2 = CGPointMake(x + 45,y + 80);
    [path addLineToPoint:p2];
    //关闭路径
    [path closePath];
    
    //绘制感叹号
    //绘制直线
    [path moveToPoint:CGPointMake(x, y + 20)];
    CGPoint p4 = CGPointMake(x, y + 60);
    [path addLineToPoint:p4];
    //绘制实心圆
    [path moveToPoint:CGPointMake(x, y + 70)];
    [path addArcWithCenter:CGPointMake(x, y + 70) radius:2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    
    //新建图层——绘制上述路径
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor orangeColor].CGColor;
    layer.lineWidth = indicateLineWidth;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [alertCanvas.layer addSublayer:layer];
}

/**
 *  画圆角矩形和叉
 */
- (void)drawWrong
{
    [self initAlertStyle];
    
    CGFloat x = CGRectGetMidX(alertCanvas.bounds) - indicateRadius;
    CGFloat y = CGRectGetMidY(alertCanvas.bounds) / 2 - indicateRadius;
    
    //圆角矩形
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, indicateRadius * 2, indicateRadius * 2) cornerRadius:5];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    CGFloat space = 20;
    //斜线1
    [path moveToPoint:CGPointMake(x + space, y + space)];
    CGPoint p1 = CGPointMake(x + indicateRadius * 2 - space, y + indicateRadius * 2 - space);
    [path addLineToPoint:p1];
    //斜线2
    [path moveToPoint:CGPointMake(x + indicateRadius * 2 - space , y + space)];
    CGPoint p2 = CGPointMake(x + space, y + indicateRadius * 2 - space);
    [path addLineToPoint:p2];
    
    //新建图层——绘制上述路径
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = indicateLineWidth;
    layer.path = path.CGPath;
// 使用NSStringFromSelector(@selector(strokeEnd))作为KeyPath的作用，绘制动画每一次Show均重复运行
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    //和上对应
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [alertCanvas.layer addSublayer:layer];
}
#pragma mark - setter method
- (void)setAlertTitle:(NSString *)title
{
    alertTitle = title;
    titleLabel.text = alertTitle;
}
- (void)setAlertMessage:(NSString *)message
{
    alertMessage = message;
    messageLabel.text = alertMessage;
}
@end
