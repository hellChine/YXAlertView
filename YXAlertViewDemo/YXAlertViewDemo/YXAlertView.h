//
//  YXAlertView.h
//  TestDemo
//
//  Created by Alvin on 16/4/11.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/**
 *  YXAlertViewStyle
 */
typedef NS_ENUM(NSInteger, YXAlertViewStyle)
{
    
    YXAlertViewStyleDefault = 0,    //默认样式 ——系统样式
    
    YXAlertViewStyleSuccess,        //成功
    
    YXAlertViewStyleFail,           //失败
    
    YXAlertViewStyleWaring,         //警告
    
    YXAlertViewStyleSheet           //ActionSheet
};

@protocol YXAlertViewDelegate;

@interface YXAlertView : UIView

@property (nullable, nonatomic, assign) id<YXAlertViewDelegate> delegate;
@property (nullable, nonatomic, strong) NSString *alertTitle;
@property (nullable, nonatomic, strong) NSString *alertMessage;

- (instancetype)initWithStyle:(YXAlertViewStyle)style title:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id /*<YXAlertViewDelegate>*/)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
/**
 *  shows popup alert animated.
 */
- (void)show;

@end

@protocol YXAlertViewDelegate <NSObject>
@optional

/**
 *  Called when a button is clicked. The view will be automatically dismissed after this call returns
 */
- (void)alertView:(YXAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;




@end
NS_ASSUME_NONNULL_END