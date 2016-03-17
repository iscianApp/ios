//
//  ViewController.h
//  phoneDrugSieve
//
//  Created by bluemobi on 15/4/28.
//  Copyright (c) 2015年 liuhengyu. All rights reserved.
//

#import "AJServerApis.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

@implementation AJServerApis
//注册协议
//：http://localhost:8080/bitSite/app/aboutUs/show?flag=zc

-(void)GetAgreeflag:(NSString *)flag Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"/app/aboutUs/show.htm?flag=%@",flag];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
    {
        completion(objectRet,errorRes);
    }];

}

//发送短信验证码(2015-10-15  何小慧)  /app/messageVerificationCode/sendMessage.htm
-(void)GetSendMessagePhoneNum:(NSString *)phone type:(NSString *)type Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/messageVerificationCode/sendMessage.htm?phone=%@&type=%@",phone,type];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//banner图列表(2015-10-15   何小慧) app/bannerInfo/getBannerInfoList.htm
-(void)GetBannerInfoListCompletion:(LLDPResponseBlock)completion
{
    
    NSString *_url = [NSString stringWithFormat:@"app/bannerInfo/getBannerInfoList.htm"];
    
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
    
}
//提醒设置列表(2015-10-15   何小慧)   app/remindInfo/getRemindInfoByList.htm
-(void)GetRemindInfoPageNo:(NSString *)pageNo pageSize:(NSString *)pageSize userId:(NSString *)userId remindType:(NSString *)remindType Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/remindInfo/getRemindInfoByList.htm?pageNo=%@&pageSize=%@&userId=%@&remindType=%@",pageNo,pageSize,userId,remindType];
    
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

    
}

//提醒设置详细(2015-10-15   何小慧)   app/remindInfo/getRemindInfoById.htm
-(void)GetgetRemindInfoById:(NSString *)Id Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/remindInfo/getRemindInfoById.htm?id=%@",Id];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//删除提醒设置(2015-10-16   何小慧)   app/remindInfo/deleteRemindInfoById.htm
-(void)GetdeleteRemindInfoById:(NSString *)Id Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/remindInfo/deleteRemindInfoById.htm?id=%@",Id];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//用户详情 （2015-10-22  何小慧）app/userInfo/getUserInfoById.htm
-(void)GetUserInfoByUserId:(NSString *)userId Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/userInfo/getUserInfoById.htm?userId=%@",userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//根据用户手机号搜索好友 （2015-10-22  何小慧）app/userInfo/getUserInfoByPhone.htm
-(void)getUserInfoByPhone:(NSString *)phone userId:(NSString *)userId  Completion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/userInfo/getUserInfoByPhone.htm?phone=%@&userId=%@",phone,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//专家建议列表 （2015-10-16  何小慧）app/articleInfo/getArticleInfoByList.htm
-(void)GetArticleInfoByListPageNo:(NSString *)pageNo pageSize:(NSString *)pageSize type:(NSString *)type andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/articleInfo/getArticleInfoByList.htm?pageNo=%@&pageSize=%@&type=%@",pageNo,pageSize,type];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//系统消息列表 （2015-10-22  何小慧）app/sysMessage/getSysMessageByList.htm
-(void)GetSysMessageByListPageNo:(NSString *)pageNo userId:(NSString *)userId pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/sysMessage/getSysMessageByList.htm?pageNo=%@&pageSize=%@&userId=%@",pageNo,pageSize,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//我的设备列表（郭乐）app/userEquipment/getUserEquipmentForPageApp.htm
-(void)GetUserEquipmentForPageAppUserId:(NSString *)userId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/userEquipment/getUserEquipmentForPageApp.htm?pageNo=%@&pageSize=%@&userId=%@",pageNo,pageSize,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//删除我的设备（郭乐）app/userEquipment/ deleteUserEquipmentApp.htm
-(void)GetDeleteUserEquipmentAppUserEquipmentId:(NSString *)userEquipmentId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/userEquipment/deleteUserEquipmentApp.htm?userEquipmentId=%@",userEquipmentId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//好友验证消息列表（郭乐）app/verificationMessage/getVerificationMessageListApp.htm
-(void)GetVerificationMessageListAppUserId:(NSString *)userId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/verificationMessage/getVerificationMessageListApp.htm?pageNo=%@&pageSize=%@&userId=%@",pageNo,pageSize,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//好友留言列表（郭乐）app/friendsMessage/getFriendsMessageListApp.htm
-(void)GetFriendsMessageListAppUserId:(NSString *)userId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/friendsMessage/getFriendsMessageListApp.htm?pageNo=%@&pageSize=%@&userId=%@",pageNo,pageSize,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//首页（血压、专家建议、我的数据）app/homeIndex/getBloodPressureByNewApp.htm
-(void)GetBloodPressureByNewAppUserId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/homeIndex/getBloodPressureByNewApp.htm?userId=%@",userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//我的好友列表（郭乐）app/myFriends/getMyFriendsListApp.htm
-(void)GetMyFriendsListAppUserId:(NSString *)userId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/myFriends/getMyFriendsListApp.htm?pageNo=%@&pageSize=%@&userId=%@",pageNo,pageSize,userId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//删除添加好友（郭乐）app/myFriends/updateState.htm
-(void)GetUpdateStateUserId:(NSString *)userId friendsId:(NSString *)friendsId myFriendsId:(NSString *)myFriendsId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/myFriends/updateState.htm?userId=%@&friendsId=%@&myFriendsId=%@",userId,friendsId,myFriendsId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}
//血压测量结果（郭乐）app/bloodPressure/ getBloodPressureByNewApp.htm
-(void)GetBloodPressureRequestWithUserId:(NSString *)userId bloodPressureId:(NSString *)bloodPressureId andCompletion:(LLDPResponseBlock)completion
{
    if (!bloodPressureId) {
        bloodPressureId = @"";
    }
    NSString *_url = [NSString stringWithFormat:@"app/bloodPressure/ getBloodPressureByNewApp.htm?userId=%@&bloodPressureId=%@",userId,bloodPressureId];
    
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//历史血压数据（郭乐）app/bloodPressure/ getBloodPressureHisApp.htm
-(void)GetBloodPressureHistoryRequestWithUserId:(NSString *)userId type:(NSString *)type pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize  andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/bloodPressure/ getBloodPressureHisApp.htm?userId=%@&type=%@&pageNo=%@&pageSize=%@",userId,type,pageNo,pageSize];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//历史血压数据-趋势图（郭乐） app/bloodPressure/getBloodPressureWhereApp.htm
-(void)GetBloodPressureHistoryTendencyChartRequestWithUserId:(NSString *)userId type:(NSString *)type andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/bloodPressure/getBloodPressureWhereApp.htm?userId=%@&type=%@",userId,type];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//好友历史数据 app/bloodPressure/ getFriendsBloodPressureApp.htm
-(void)GetFriendsBloodPressureAppUserId:(NSString *)userId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/bloodPressure/getFriendsBloodPressureApp.htm?userId=%@&pageNo=%@&pageSize=%@",userId,pageNo,pageSize];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];

}

//好友历史折现图 app/bloodPressure/ getFriendsBloodPressureByPicApp.htm
-(void)GetFriendsBloodPressureByPicAppUserId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/bloodPressure/getFriendsBloodPressureByPicApp.htm?userId=%@",userId];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
//寻医 app/seekDoctor/getSeekDoctorLoginOrReg.htm
-(void)GetSeekDoctorWithPressureId:(NSString *)pressureId phone:(NSString *)phone UUIDString:(NSString *)UUIDString andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/seekDoctor/getSeekDoctorLoginOrReg.htm?telephoe=%@&bloodPressureId=%@&app_data=%@",phone,pressureId,UUIDString];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

#pragma mark - 新接口
//首页 app/homeIndex/getBloodPressureIndexApp.htm
-(void)GetBloodPressureUserId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/homeIndex/getBloodPressureIndexApp.htm?userId=%@",userId];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}

//我的好友详情 app/myFriends/getMyFriendsInfoApp.htm
-(void)GetMyFriendsWithFriendId:(NSString *)friendId userId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *_url = [NSString stringWithFormat:@"app/myFriends/getMyFriendsInfoApp.htm?friendId=%@&userId=%@",friendId,userId];
    [self getRequestWithUrll:_url WithPara:nil andCompletion:^(id objectRet, NSError *errorRes)
     {
         completion(objectRet,errorRes);
     }];
}
@end
