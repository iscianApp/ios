//
//  MyQRCodeViewController.m
//  LUDE
//
//  Created by JHR on 15/10/10.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "MyQRCodeViewController.h"
#import "QRCodeGenerator.h"

@interface MyQRCodeViewController ()<UIScrollViewDelegate,UINavigationControllerDelegate>
//二维码
@property (weak, nonatomic) IBOutlet UIImageView *codeImage_UIImageView;

@end

@implementation MyQRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_titleLable setText:NSLocalizedString(@"My QR", nil)];
    self.navigationController.delegate =self;
    
//    _codeImage_UIImageView.backgroundColor = [UIColor clearColor];
    _codeImage_UIImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_codeImage_UIImageView setUserInteractionEnabled:YES];
    UIImage *image = [QRCodeGenerator qrImageForString:self.accountToken imageSize:117.0];
    [_codeImage_UIImageView setImage:image];
   
   
   
}
-(void)viewDidLayoutSubviews
{
    
    [_codeImage_UIImageView mas_updateConstraints:^(MASConstraintMaker *make)
     {
         if (iPhone4||(FRAME_W(self.view)==320.0&&FRAME_H(self.view) ==480.0))
         {
             SET_FRAME_Y(_codeImage_UIImageView,235);
             SET_FRAME_X(_codeImage_UIImageView, FRAME_MIN_X(_codeImage_UIImageView)-7);
             SET_FRAME_H(_codeImage_UIImageView,117+17);
             SET_FRAME_W(_codeImage_UIImageView, 117+17);
         }
         else if  (iPhone5)
         {
             SET_FRAME_Y(_codeImage_UIImageView,275);
             SET_FRAME_X(_codeImage_UIImageView, FRAME_MIN_X(_codeImage_UIImageView)-10);
             SET_FRAME_H(_codeImage_UIImageView,117+25);
             SET_FRAME_W(_codeImage_UIImageView, 117+25);
         }
         else if (iPhone6)
         {
             SET_FRAME_Y(_codeImage_UIImageView,327);
             SET_FRAME_X(_codeImage_UIImageView, FRAME_MIN_X(_codeImage_UIImageView)-10);
             SET_FRAME_H(_codeImage_UIImageView,117+20);
             SET_FRAME_W(_codeImage_UIImageView, 117+20);
         }
         else
         {
             SET_FRAME_Y(_codeImage_UIImageView,357);
             SET_FRAME_X(_codeImage_UIImageView, FRAME_MIN_X(_codeImage_UIImageView)-20);
             SET_FRAME_H(_codeImage_UIImageView,117+40);
             SET_FRAME_W(_codeImage_UIImageView, 117+40);
         }
        
         
         
     }];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //注册通知事件
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"JKSideSlipShow" object:nil userInfo:nil];
//}
/**
 *	@brief	返回按钮 点击事件
 */
- (IBAction)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
