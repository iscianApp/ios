//
//  BPMeasurementGuidanceViewController.m
//  LUDE
//
//  Created by bluemobi on 15/12/4.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "BPMeasurementGuidanceViewController.h"
#import "BloodRressureMonitoringViewController.h"
#import "ManualBloodPressureViewController.h"

@interface BPMeasurementGuidanceViewController ()

@property (strong, nonatomic) IBOutlet UILabel *lblTitleName;
@property (strong, nonatomic) IBOutlet UIButton *btnInput;
@property (strong, nonatomic) IBOutlet UIButton *btnStarMeasure;

@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation BPMeasurementGuidanceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    血压测量指导；
//    手动输入；
    [self.btnInput setTitle:NSLocalizedString(@"Manual Input", nil) forState:UIControlStateNormal];
    [_btnStarMeasure setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    [self createUI];
    
    if (_titleStr.length>0)
    {
        self.titleLabel.text =_titleStr;
    }
    
    readValueArray = [[NSMutableArray alloc]init];
    descriptors = [[NSMutableArray alloc]init];
    [self babyDelegate];
    //写服务
    baby.channel(channelOnCharacteristicView).characteristicDetails(self.currPeripheral,self.writeCharacteristic);
    [self writePowerInformationValue];
    
}

//写一个值   获取电量信息
-(void)writePowerInformationValue{
    //    NSString *hexstring = @"FFFF0506F5";
    //    NSData *data = [hexstring dataUsingEncoding: NSUTF8StringEncoding];
    Byte byte[] = {0XFF,0XFF,0X05,0X06,0XF5};
    NSData *data = [[NSData alloc] initWithBytes:byte length:5];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
-(void)babyDelegate{
    __weak typeof(self)weakSelf = self;
    //设置读取characteristics的委托
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
            [weakSelf insertDescriptor:d];
        }
    }];
//    //设置读取Descriptor的委托
//    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
//        for (int i =0 ; i<descriptors.count; i++) {
//            if (descriptors[i]==descriptor) {
//                NSLog(@"------------\n%@-----------",descriptor.value);
//            }
//        }
//        NSLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
//    }];

}

//插入描述
-(void)insertDescriptor:(CBDescriptor *)descriptor{
    [self->descriptors addObject:descriptor];
    NSMutableArray *indexPahts = [[NSMutableArray alloc]init];
    NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:self->descriptors.count-1 inSection:2];
    [indexPahts addObject:indexPaht];
}
//插入读取的值
-(void)insertReadValues:(CBCharacteristic *)characteristics{
    [self->readValueArray addObject:[NSString stringWithFormat:@"%@",characteristics.value]];
}

//写一个值   开始测量
-(void)writeValue{
    Byte byte[] = {0XFF,0XFF,0X05,0X01,0XFA};
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

/**
 *	@brief	 界面测量指导页创建
 */
-(void)createUI
{
    NSArray *arr =[NSArray arrayWithObjects:@"xin-zhidao1",@"xin-zhidao2",@"xin-zhidao3",@"xin-zhidao4",@"xin-zhidao5", nil];
    for (int i =0; i < [arr count]; i++)
    {
        UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(i*FRAME_W(self.view), 0, FRAME_W(self.view), FRAME_H(self.view)-150)];
        imageView.image =[UIImage imageNamed:arr[i]];
        [_backView addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
/**
 *	@brief	 返回按钮点击事件
 */
- (IBAction)ReturnBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief	 开始测量按钮点击事件
 */
- (IBAction)startBPMeasure:(UIButton *)sender {
    [self writeValue];
    BloodRressureMonitoringViewController *Blood= [[BloodRressureMonitoringViewController alloc] initWithSecondStoryboardID:@"BloodRressureMonitoringViewController"];
    Blood->baby = self->baby;
    Blood.writeCharacteristic = self.writeCharacteristic;
    Blood.readCharacteristic = self.readCharacteristic;
    Blood.currPeripheral = self.currPeripheral;
    Blood.SerialNo = self.SerialNo;
    [self.navigationController pushViewController:Blood animated:YES];
}
/**
 *	@brief	 手动输入按钮点击事件
 */
- (IBAction)ManualBP:(id)sender {
    ManualBloodPressureViewController *Start=[[ManualBloodPressureViewController alloc] initWithSecondStoryboardID:@"ManualBloodPressureViewController"];
    Start.currPeripheral = self.currPeripheral;
    [self.navigationController pushViewController:Start animated:YES];
}
@end
