//
//  BPMeasurementGuidanceViewController.h
//  LUDE
//
//  Created by bluemobi on 15/12/4.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import "PeripheralInfo.h"

@interface BPMeasurementGuidanceViewController : UIViewController
{
@public
    BabyBluetooth *baby;
    __block  NSMutableArray *readValueArray;
    __block  NSMutableArray *descriptors;
}
/**
 *	@brief	标题
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong ,nonatomic)NSString *titleStr;
/**
 *	@brief	 设备特性
 */
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic;
@property (nonatomic,strong)CBCharacteristic *readCharacteristic;
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (nonatomic ,copy)NSString *SerialNo ;

/**
 *	@brief	 手动输入按钮点击事件
 */
- (IBAction)ManualBP:(id)sender;

@end
