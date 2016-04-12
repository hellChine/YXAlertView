# YXAlertView
similar system API,convenient use and lightweight.

@property (nullable, nonatomic, assign) id<YXAlertViewDelegate> delegate;
@property (nullable, nonatomic, strong) NSString *alertTitle;
@property (nullable, nonatomic, strong) NSString *alertMessage;

- (instancetype)initWithStyle:(YXAlertViewStyle)style title:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id /*<YXAlertViewDelegate>*/)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
/**
*  shows popup alert animated.
*/
- (void)show;

/**
*  Called when a button is clicked. The view will be automatically dismissed after this call returns
*/
- (void)alertView:(YXAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
