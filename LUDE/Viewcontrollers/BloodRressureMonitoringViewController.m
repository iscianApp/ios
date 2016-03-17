//
//  BloodRressureMonitoringViewController.m
//  LUDE
//
//  Created by bluemobi on 15/10/12.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "BloodRressureMonitoringViewController.h"
#import "CircleProgressView.h"
#import "BloodDataDeneralizationViewController.h"
#import "MainViewController.h"
#import "EquipmentSearchViewController.h"
#import "ZTypewriteEffectLabel.h"

@interface BloodRressureMonitoringViewController ()<UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    UIImageView *bang;
    UIView *popView;
    UIImageView *tips;
    ZTypewriteEffectLabel *tipsLable;
}

@property (strong, nonatomic) IBOutlet UILabel *lblTitleName;
@property (strong, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (nonatomic) float   value;
@property (nonatomic, assign) int   index;
@property (nonatomic, assign) int lastThreeCount;
//收缩压 实际值
@property (nonatomic, assign) int   SPValue;
//舒张压 实际值
@property (nonatomic, assign) int DSPValue;
//心率 实际值
@property (nonatomic, assign) int HRValue;

@property (weak, nonatomic) IBOutlet UILabel *resultLable;

@property (nonatomic ,assign)BOOL DONE;

@property (nonatomic ,retain) NSTimer *timeT;

@end

@implementation BloodRressureMonitoringViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [_lblTitleName setText:NSLocalizedString(@"Measurement", nil)];
    [_stopAndCkeckBtn setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
    self.circleProgressView.progress = 0.00;
    //蓝牙模块
    readValueArray = [[NSMutableArray alloc]init];
    descriptors = [[NSMutableArray alloc]init];
    
    [self createTipsAnimate];
    
    [self babyDelegate];
    self.index = 0;
    self.lastThreeCount = 0;
    //读取服务
    baby.channel(channelOnReadCharacteristicView).characteristicDetails(self.currPeripheral,self.readCharacteristic);
    [self setNotifiy:nil];
    
    [self performSelector:@selector(startWriteValue) withObject:nil afterDelay:5];
}
-(void)viewDidDisappear:(BOOL)animated
{
   // [baby cancelAllPeripheralsConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
// 专家头像动画
-(void)createTipsAnimate
{
    if (!bang) {
        bang =   [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tipsHeadImageNormal"]];
        [bang setUserInteractionEnabled:YES];
        [bang sizeToFit];
        [self.view addSubview:bang];
        
        bang.originValue = ccp(-bang.widthValue, self.view.heightValue - self.stopAndCkeckBtn.heightValue - 20.0 - bang.heightValue);
        [UIView transitionWithView:bang duration:1.0 options:UIViewAnimationOptionCurveEaseIn  animations:^{
            bang.originValue = ccp(10.0, self.view.heightValue - self.stopAndCkeckBtn.heightValue - 20.0 - bang.heightValue);
        } completion:^(BOOL finished) {
            //finished判断动画是否完成
            if (finished) {
                [self popViewAnimate];
            }
        }];
    }
}

// 文字出现动画
-(void)createPopView
{
    if (!tips) {
        tips = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftPopImage"]];
        [tips setUserInteractionEnabled:YES];
        
        tipsLable = [[ZTypewriteEffectLabel alloc] initWithFrame:CGRectMake(20.0,10.0, self.view.widthValue - (bang.rightValue+50.0),0)];
        tipsLable.tag = 100;
        tipsLable.backgroundColor = [UIColor clearColor];
        tipsLable.numberOfLines = 0;
        tipsLable.text = NSLocalizedString(@"Blood pressure gauge is being measured", nil);
        tipsLable.textColor = [UIColor clearColor];
        tipsLable.font = [UIFont systemFontOfSize:16.0];
        tipsLable.typewriteEffectColor = [UIColor whiteColor];
        tipsLable.hasSound = YES;
        tipsLable.typewriteTimeInterval = 0.1;
        tipsLable.typewriteEffectBlock = ^{
        };
        [tipsLable sizeToFit];
        
        [self.view bringSubviewToFront:bang];
    }
    
    if (!popView) {
        popView = [[UIView alloc] initWithFrame:CGRectMake(bang.rightValue,bang.topValue, tipsLable.frame.size.width + 40.0,tipsLable.frame.size.height + 20.0)];
        [popView setBackgroundColor:[UIColor clearColor]];
        
        [self.view addSubview:popView];
        
        [tips setFrame:CGRectMake(0,0, popView.widthValue,popView.heightValue)];
        popView.centerYValue = bang.centerYValue;
        [popView addSubview:tips];
        [popView addSubview:tipsLable];
    }
}

-(void)popViewAnimate
{
    [UIView transitionWithView:popView duration:1.0 options:UIViewAnimationOptionCurveEaseIn  animations:^{
        [self createPopView];
    } completion:^(BOOL finished) {
        
    }];
    
    [self performSelector:@selector(startOutPut:) withObject:tipsLable afterDelay:0.7];
}

-(void)startOutPut:(ZTypewriteEffectLabel *)lable
{
    [lable startTypewrite];
}

//蓝牙委托设置

-(void)babyDelegate{
    
    __weak typeof(self)weakSelf = self;
//    //设置设备断开连接的委托
//    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"设备：%@--断开连接",peripheral.name);
//        //[weakSelf performSelector:@selector(dismiss:) withObject:nil afterDelay:1];
//        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@已断开连接",peripheral.name] delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
//        alertView.tag = 400;
//        [alertView show];
//    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnReadCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
               NSLog(@"CharacteristicViewController===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        [weakSelf insertReadValues:characteristics];
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnReadCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        //        NSLog(@"CharacteristicViewController===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            //            NSLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
            [weakSelf insertDescriptor:d];
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnReadCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        for (int i =0 ; i<descriptors.count; i++) {
            if (descriptors[i]==descriptor) {
                NSLog(@"------------\n%@-----------",descriptor.value);
            }
        }
        NSLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
}

//插入描述
-(void)insertDescriptor:(CBDescriptor *)descriptor{
    [self->descriptors addObject:descriptor];
    NSMutableArray *indexPahts = [[NSMutableArray alloc]init];
    NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:self->descriptors.count-1 inSection:2];
    [indexPahts addObject:indexPaht];
}
//插入读取的值测试中563测试结果为566
-(void)insertReadValues:(CBCharacteristic *)characteristics{
    [self->readValueArray addObject:[NSString stringWithFormat:@"%@",characteristics.value]];
    NSString *valueString = [NSString stringWithFormat:@"%@",characteristics.value];
    //<ffff0a02 00760041 003d>
    NSString *hexstring = [[valueString substringWithRange:NSMakeRange(1, valueString.length - 2)] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"------------%d\n%@-----------",self.index,hexstring);
    if (hexstring.length == 10)
    {
        if ([hexstring hasPrefix:@"ffff05"])
        {
            NSString *CMD = [hexstring substringWithRange:NSMakeRange(6, 2)];
            
            if ([CMD isEqualToString:@"05"]) {
               
            }
            else if([CMD isEqualToString:@"04"] && self.index > 0)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You have canceled the measurement", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *otherAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"I know", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                               {
                                                   for(UIViewController *controller in self.navigationController.viewControllers) {
                                                       if([controller isKindOfClass:[MainViewController class]]){
                                                           MainViewController *mainView = (MainViewController *)controller;
                                                           [self.navigationController popToViewController:mainView animated:YES];
                                                       }
                                                   }
                                               }];
                [alertController addAction:otherAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
        
        self.index++;
    }
    else if(hexstring.length > 10)
    {
        if ([hexstring hasPrefix:@"ffff0a02"])
        {
            self.index++;
            if (self.index != 1) {
                self.circleProgressView.progress = [self resultVlueWithHexstringToIntValue:[NSString stringWithFormat:@"%@%@",[hexstring substringWithRange:NSMakeRange(12, 2)],[hexstring substringWithRange:NSMakeRange(10, 2)]]]/300.0;
                //心跳0或1
                // NSString *HB = [hexstring substringWithRange:NSMakeRange(8, 2)];
                self.resultLable.text = [NSString stringWithFormat:@"%d",[self resultVlueWithHexstringToIntValue:[NSString stringWithFormat:@"%@%@",[hexstring substringWithRange:NSMakeRange(12, 2)],[hexstring substringWithRange:NSMakeRange(10, 2)]]]];
            }
        }
        else if ([hexstring hasPrefix:@"ffff4903"] && self.index > 0)
         {
             self.lastThreeCount ++;
             //心率
             NSString *HR = [hexstring substringWithRange:NSMakeRange(8, 2)];
             self.HRValue =  [self resultVlueWithHexstringToIntValue:HR];
             //收缩压 低8位 (实际值-30)
             NSString *SP = [hexstring substringWithRange:NSMakeRange(10, 2)];
             self.SPValue = [self resultVlueWithHexstringToIntValue:SP]+30;
             //舒张压 (实际值-30）
             NSString *DSP = [hexstring substringWithRange:NSMakeRange(12, 2)];
             self.DSPValue = [self resultVlueWithHexstringToIntValue:DSP]+30;
             //self.circleProgressView.progress = self.SPValue/300.0;
             if (self.lastThreeCount%3 == 0) {
                 self.resultLable.text = [NSString stringWithFormat:@"%d/%d",self.SPValue,self.DSPValue];
                 [self showProgress];
                  [baby cancelNotify:self.currPeripheral characteristic:self.readCharacteristic];
             }
         }
        else if ([hexstring hasPrefix:@"ffff0607"] && self.index > 0)
        {
            self.lastThreeCount ++;
            //ERR信息分类为 00(充不上气);01(测量中发生错误);02(血压计低电量)
            NSString *wrong = [hexstring substringWithRange:NSMakeRange(8, 2)];
            if (self.lastThreeCount%3 == 0) {
                if ([wrong isEqualToString:@"00"])
                {
                    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message: NSLocalizedString(@"Cannot be filled with gas", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I know", nil), nil];
                    alertView.tag = 100;
                    [alertView show];
                }
                else if ([wrong isEqualToString:@"01"])
                {
                    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message: NSLocalizedString(@"Error in measurement", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I know", nil), nil];
                    alertView.tag = 101;
                    [alertView show];
                }
                else if ([wrong isEqualToString:@"02"])
                {
                    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message: NSLocalizedString(@"Blood pressure meter low power", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I know", nil), nil];
                    alertView.tag = 102;
                    [alertView show];
                }
            }
        }
        else if ([hexstring hasPrefix:@"ffff0609"])
        {
            //机型
            NSString *systemInfo_JX = [hexstring substringWithRange:NSMakeRange(8, 2)];
            NSLog(@"设备信息机型%@",systemInfo_JX);
            //版本号
            NSString *systemInfo_VT = [hexstring substringWithRange:NSMakeRange(10, 2)];
            NSLog(@"设备信息版本号%@",systemInfo_VT);
        }
        else if ([hexstring hasPrefix:@"ffff0708"])
        {
            NSString *powerInfo = [hexstring substringWithRange:NSMakeRange(8, 2)];
            NSLog(@"电量信息\n%@",powerInfo);
        }
    }
}
//写一个值   开始测量
-(void)startWriteValue{
    if (self.index < 5) {
//        NSString *hexstring = @"FFFF0501FA";
//        NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
        Byte byte[] = {0XFF,0XFF,0X05,0X01,0XFA};
        NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}
//写一个值   开始测量回馈正常
-(void)writeStartingFeedbackNormalValue{
//    NSString *hexstring = @"FFFF0502F9";
//    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X02,0XF9};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
//写一个值   开始测量回馈异常
-(void)writeStartingFeedbackFailedValue{
//    NSString *hexstring = @"FFFF0503F8";
//    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X03,0XF8};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
//写一个值   取消测量
-(void)writeCancelOperationValue{
//    NSString *hexstring = @"FFFF0504F7";
//    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X04,0XF7};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
//写一个值   获取设备信息
-(void)writeSystemInformationValue{
//    NSString *hexstring = @"FFFF0505F6";
//    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X05,0XF6};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
//写一个值   获取电量信息
-(void)writePowerInformationValue{
//    NSString *hexstring = @"FFFF0506F5";
//    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X06,0XF5};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//订阅一个值
-(void)setNotifiy:(id)sender{
    __weak typeof(self)weakSelf = self;
    if(self.currPeripheral.state != CBPeripheralStateConnected){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Peripheral has been disconnected. Please reconnect", nil)];
        return;
    }
    if (self.readCharacteristic.properties & CBCharacteristicPropertyNotify ||  self.readCharacteristic.properties & CBCharacteristicPropertyIndicate){
//        if(self.readCharacteristic.isNotifying){
//            [baby cancelNotify:self.currPeripheral characteristic:self.readCharacteristic];
//        }else{
           // [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
            [baby notify:self.currPeripheral
          characteristic:self.readCharacteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       [weakSelf insertReadValues:characteristics];
                   }];
       // }
    }
    else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"This characteristic does not have the rights to nofity", nil)];
        return;
    }
}

// 测量结果中显示进度，圆环的走势
- (void)showProgress
{
    NSDictionary *dict = [DEFAULTS objectForKey:@"User"];
    NSString * userIdStr =[[dict objectForKey:@"data"]objectForKey:@"userId"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
     [Tools show];
    
    WeakObject(self);
    
     LLNetApiBase *apis =[[LLNetApiBase alloc]init];
    [apis SaveBloodPressureDataRequestWithUserId:userIdStr equipmentNo:self.SerialNo bloodPressureOpen:[NSString stringWithFormat:@"%d",self.DSPValue] bloodPressureClose:[NSString stringWithFormat:@"%d",self.SPValue] pulse:[NSString stringWithFormat:@"%d",self.HRValue] measureTime:destDateString type:@"1" andCompletion:^(id objectRet, NSError *errorRes)
     {
         [Tools dismiss];
         if(errorRes)
         {
             switch (errorRes.code) {
                 case -1004:
                 {
                     UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please check the network", nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                     [_alertView show];
                 }
                     break;
                 case -1001:
                 {
                     UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                     [_alertView show];
                 }
                     break;
                     
                 default:
                     break;
             }
         }
         else
         {
             NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
             if ([statusStr isEqualToString:@"1"])
             {
                 self.DONE = YES;
                 [self.stopAndCkeckBtn setSelected:self.DONE];
                 [self.stopAndCkeckBtn setTitle:NSLocalizedString(@"Click to view", nil) forState:UIControlStateNormal];
                 
                 [self writeCancelOperationValue];
                 [baby cancelNotify:self.currPeripheral characteristic:self.readCharacteristic];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [baby cancelAllPeripheralsConnection];
                 });
                 BloodDataDeneralizationViewController *data =[[BloodDataDeneralizationViewController alloc] initWithSecondStoryboardID:@"BloodDataDeneralizationViewController"];
                 NSString *userId =[NSString stringWithFormat:@"%@",[[[DEFAULTS objectForKey:@"User"]objectForKey:@"data"]objectForKey:@"userId"]];
                 data.userId = userId;
                 [__weakObject.navigationController pushViewController:data animated:YES];

             }
             else if ([statusStr isEqualToString:@"0"])
             {
                 UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                 alertView.tag = 101;
                 [alertView show];
             }
         }
     }];
}
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        for(UIViewController *controller in self.navigationController.viewControllers) {
            if([controller isKindOfClass:[MainViewController class]]){
                MainViewController *mainView = (MainViewController *)controller;
                [self.navigationController popToViewController:mainView animated:YES];
            }
        }
    }
    else if (alertView.tag == 101)
    {
        for(UIViewController *controller in self.navigationController.viewControllers) {
            if([controller isKindOfClass:[MainViewController class]]){
                MainViewController *mainView = (MainViewController *)controller;
                [self.navigationController popToViewController:mainView animated:YES];
            }
        }
    }
    else if (alertView.tag == 102)
    {
        for(UIViewController *controller in self.navigationController.viewControllers) {
            if([controller isKindOfClass:[MainViewController class]]){
                MainViewController *mainView = (MainViewController *)controller;
                [self.navigationController popToViewController:mainView animated:YES];
            }
        }
    }
    
    else
    {
        BloodDataDeneralizationViewController *data =[[BloodDataDeneralizationViewController alloc] initWithSecondStoryboardID:@"BloodDataDeneralizationViewController"];
        [self.navigationController pushViewController:data animated:YES];
    }
}

/**
 *	@brief	 点击返回按钮单击事件
 */
- (IBAction)ReturnBtnClick:(UIButton *)sender
{
    [self writeCancelOperationValue];
    [baby cancelNotify:self.currPeripheral characteristic:self.readCharacteristic];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [baby cancelAllPeripheralsConnection];
    });
    
    for(UIViewController *controller in self.navigationController.viewControllers) {
        if([controller isKindOfClass:[MainViewController class]]){
            MainViewController *mainView = (MainViewController *)controller;
            [self.navigationController popToViewController:mainView animated:YES];
        }
    }
}
/**
 *	@brief 得到的血压值16进制的字符串转换成10进制数值
 */
-(int)resultVlueWithHexstringToIntValue:(NSString *)hexstring
{
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long hex = strtoul([hexstring UTF8String],0,16);
    //strtoul如果传入的字符开头是“0x”,那么第三个参数是0，也是会转为十六进制的,这样写也可以：
    // unsigned long red = strtoul([@"0x6587" UTF8String],0,0);
   // NSLog(@"转换完的16进制的数字为：%lx",hex);
    NSData *data = [[NSData alloc] initWithBytes:&hex length:sizeof(hex)];
    int resultValue;
    [data getBytes:&resultValue length:sizeof(resultValue)];
   // NSLog(@"转换完的10进制的数字为：%d",resultValue);
    return resultValue;
}
/**
 *	@brief 取消操作
 */
- (IBAction)StopMeasure:(UIButton *)sender {
    [self writeCancelOperationValue];
    [baby cancelNotify:self.currPeripheral characteristic:self.readCharacteristic];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [baby cancelAllPeripheralsConnection];
    });
    
    if (self.DONE) {
        BloodDataDeneralizationViewController *data =[[BloodDataDeneralizationViewController alloc] initWithSecondStoryboardID:@"BloodDataDeneralizationViewController"];
        [self.navigationController pushViewController:data animated:YES];
    }
    else
    {
        for(UIViewController *controller in self.navigationController.viewControllers) {
            if([controller isKindOfClass:[MainViewController class]]){
                MainViewController *mainView = (MainViewController *)controller;
                [self.navigationController popToViewController:mainView animated:YES];
            }
        }
    }
}
@end
