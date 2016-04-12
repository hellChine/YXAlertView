//
//  ViewController.m
//  YXAlertViewDemo
//
//  Created by Alvin on 16/4/12.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import "ViewController.h"
#import "YXAlertView.h"
@interface ViewController ()<YXAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)clickAction:(UIButton *)sender {
    switch (sender.tag) {
        case YXAlertViewStyleDefault:
        {
            YXAlertView *alertView1 = [[YXAlertView alloc] initWithStyle:YXAlertViewStyleDefault title:@"温馨提示" message:@"这是一个系统样式 ！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
            [alertView1 show];
        }
            break;
        case YXAlertViewStyleSuccess:
        {
            YXAlertView *alertView1 = [[YXAlertView alloc] initWithStyle:YXAlertViewStyleSuccess title:@"温馨提示" message:@"这是显示成功的样式 ！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [alertView1 show];
        }
            break;
        case YXAlertViewStyleFail:
        {
            YXAlertView *alertView1 = [[YXAlertView alloc] initWithStyle:YXAlertViewStyleFail title:@"温馨提示" message:@"这是显示失败的样式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [alertView1 show];

        }
            break;
        case YXAlertViewStyleWaring:
        {
            YXAlertView *alertView1 = [[YXAlertView alloc] initWithStyle:YXAlertViewStyleWaring title:@"温馨提示" message:@"这是显示警告的样式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [alertView1 show];
        }
            break;
        case YXAlertViewStyleSheet:
        {
            YXAlertView *alertView1 = [[YXAlertView alloc] initWithStyle:YXAlertViewStyleSheet title:@"温馨提示 : 系统样式的ActionSheet" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",@"同意",@"删除",@"保存", nil];
            [alertView1 show];
        }
            break;
        default:
            break;
    }
    
}
- (void)alertView:(YXAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = %ld",(long)buttonIndex);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
