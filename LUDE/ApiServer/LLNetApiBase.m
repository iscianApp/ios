//
//  ViewController.h
//  phoneDrugSieve
//
//  Created by bluemobi on 15/4/28.
//  Copyright (c) 2015年 liuhengyu. All rights reserved.
//


#import "LLNetApiBase.h"

#import "AFHTTPRequestOperationManager.h"

#import "JSONKit.h"

#define MAX_TIME_LIMIT 20
 

//static NSTimeInterval  lastRequestFailureTime,currentTime;

@implementation LLNetApiBase

-(void)cleanUserStore
{
 
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)getRequestWithUrll:(NSString *)_strUrl
                 WithPara:(NSDictionary*)para
            andCompletion:(LLDPResponseBlock)completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain",nil]];

   NSString *urls = [NSString stringWithFormat:@"%@%@",SERVER_DEMAIN,_strUrl];
    
   NSString *urlString = [urls stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (para)
     {
      [manager POST:urlString parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
          
        //  NSLog(@"responseObject = %@",responseObject);
          completion(responseObject, nil);
          
        }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
                completion(nil, error) ;
        }];
      }
  else
      {
        [manager GET:urlString
      parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
       //   NSLog(@"responseObject = %@",responseObject);
          completion(responseObject, nil);
          
      }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
          NSLog(@"Error: %@", error);
         
          completion(nil, error) ;
      }];
   }
}




-(void)postRequestWithUrl:(NSString *)_strUrl WithPara:(NSDictionary*)para andCompletion: (LLDPResponseBlock)completion{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil]];
    
    NSString *urls = [NSString stringWithFormat:@"%@%@",SERVER_DEMAIN,_strUrl];
    
    NSLog(@"urls=%@",urls);
    
//    NSDictionary *jsonprama = @{@"json": [para JSONString]};
//    
//    NSString *strJson = [jsonprama JSONString];
    NSString *urlString = [urls stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"urlStirng = %@",urlString);
    
    [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
          completion(responseObject, nil) ;
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
          
          NSLog(@"Error: %@", error);
          completion(nil, error) ;
      }];

}

- (NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

//校验验证码是否过期(2015-10-15  何小慧)///app/messageVerificationCode/checkVerificationCode.htm
-(void)POSTCheckVerificationCodeTelephone:(NSString *)telephone verificationCode:(NSString *)verificationCode sendTime:(NSString *)sendTime andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/messageVerificationCode/checkVerificationCode.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_telephoneData=[telephone dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_verificationCodeData=[verificationCode dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_sendTimeData=[sendTime dataUsingEncoding:NSUTF8StringEncoding];
         [formData appendPartWithFormData:_telephoneData name:@"telephone"];

         [formData appendPartWithFormData:_verificationCodeData name:@"verificationCode"];

         [formData appendPartWithFormData:_sendTimeData name:@"sendTime"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
    
}

//注册(2015-10-15  何小慧) / app/userInfo/userInfoRegister.htm
-(void)PostUserInfoRegisterUserName:(NSString *)userName phone:(NSString *)phone userType:(NSString *)userType realName:(NSString *)realName sex:(NSString *)sex birthday:(NSString *)birthday height:(NSString *)height weight:(NSString *)weight  andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/userInfoRegister.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (userName) {
             NSData *_userNameData=[userName dataUsingEncoding:NSUTF8StringEncoding];
              [formData appendPartWithFormData:_userNameData name:@"userName"];
         }
         NSData *_phoneData=[phone dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_userTypeData=[userType dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_realNameData=[realName dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_sexData=[sex dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_birthdayData=[birthday dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_heightData=[height dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_weightData=[weight dataUsingEncoding:NSUTF8StringEncoding];
         
         [formData appendPartWithFormData:_phoneData name:@"phone"];
         [formData appendPartWithFormData:_userTypeData name:@"userType"];
         [formData appendPartWithFormData:_realNameData name:@"realName"];
         [formData appendPartWithFormData:_sexData name:@"sex"];
         [formData appendPartWithFormData:_birthdayData name:@"birthday"];
         [formData appendPartWithFormData:_heightData name:@"height"];
         [formData appendPartWithFormData:_weightData name:@"weight"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}

//登录(2015-10-15  何小慧)
-(void)PostSignWithPhoneNum:(NSString *)phone andCompletion:(LLDPResponseBlock)completion
{
   
    
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/userInfoLogin.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_phoneData=[phone dataUsingEncoding:NSUTF8StringEncoding];
        [formData appendPartWithFormData:_phoneData name:@"phone"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
}

//发布提醒设置(2015-10-16   何小慧) app/remindInfo/addRemindInfo.htm
-(void)PostaddRemindHour:(NSString *)remindHour remindMinute:(NSString *)remindMinute remindType:(NSString *)remindType state:(NSString *)state userId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/remindInfo/addRemindInfo.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_remindHourData=[remindHour dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_remindMinuteData=[remindMinute dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_remindTypeData=[remindType dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_stateData=[state dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
        
         [formData appendPartWithFormData:_remindHourData name:@"remindHour"];
         [formData appendPartWithFormData:_remindMinuteData name:@"remindMinute"];
         [formData appendPartWithFormData:_remindTypeData name:@"remindType"];
         [formData appendPartWithFormData:_stateData name:@"state"];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
         
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}

//修改提醒设置(2015-10-16   何小慧) app/remindInfo/ updateRemindInfo.htm
-(void)PostUpdateRemindInfoId:(NSString *)Id remindHour:(NSString *)remindHour remindMinute:(NSString *)remindMinute remindType:(NSString *)remindType state:(NSString *)state userId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/remindInfo/updateRemindInfo.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_IdData=[Id dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_remindHourData=[remindHour dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_remindMinuteData=[remindMinute dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_remindTypeData=[remindType dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_stateData=[state dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         
         [formData appendPartWithFormData:_IdData name:@"id"];
         [formData appendPartWithFormData:_remindHourData name:@"remindHour"];
         [formData appendPartWithFormData:_remindMinuteData name:@"remindMinute"];
         [formData appendPartWithFormData:_remindTypeData name:@"remindType"];
         [formData appendPartWithFormData:_stateData name:@"state"];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
         
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
    
}

//设置提醒状态(2015-10-16   何小慧) app/remindInfo/updateRemindInfoState.htm
-(void)PostupdateRemindInfoStateId:(NSString *)Id state:(NSString *)state andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/remindInfo/updateRemindInfoState.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_IdData=[Id dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_stateData=[state dataUsingEncoding:NSUTF8StringEncoding];
         
         [formData appendPartWithFormData:_IdData name:@"id"];
         [formData appendPartWithFormData:_stateData name:@"state"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];


}

//上传图片接口 （2015-10-16  何小慧）app/uploadFile/uploadSWFImage.htm
-(void)PostuploadSWFImage:(UIImage *)image andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/uploadFile/uploadSWFImage.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
        
         if (image)
         {
             NSData *_imgData = UIImageJPEGRepresentation(image, 0.9);
             [formData appendPartWithFileData:_imgData name:@"files['0'].file"  fileName:@"0.png" mimeType:@"image/png"];
         }
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
    
}

//修改用户资料 （2015-10-16  何小慧）app/userInfo/updateUserInfo.htm
-(void)PostupdateUserInfoUserId:(NSString *)userId realName:(NSString *)realName userPic:(NSString *)userPic sex:(NSString *)sex age:(NSString *)age birthday:(NSString *)birthday height:(NSString *)height weight:(NSString *)weight andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/updateUserInfo.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_realNameData=[realName dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_userPicData=[userPic dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_sexData=[sex dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_ageData=[age dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_birthdayData=[birthday dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_heightData=[height dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_weightData=[weight dataUsingEncoding:NSUTF8StringEncoding];
         
         [formData appendPartWithFormData:_weightData name:@"weight"];
         [formData appendPartWithFormData:_heightData name:@"height"];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
         [formData appendPartWithFormData:_realNameData name:@"realName"];
         [formData appendPartWithFormData:_userPicData name:@"userPic"];
         [formData appendPartWithFormData:_sexData name:@"sex"];
         [formData appendPartWithFormData:_ageData name:@"age"];
         [formData appendPartWithFormData:_birthdayData name:@"birthday"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}
//推送 （2015-10-16  何小慧）app/userInfo/updateUserInfo.htm
-(void)PostUpdateUserInfoPishUserId:(NSString *)userId isPush:(NSString *)isPush andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/updateUserInfo.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_isPushData=[isPush dataUsingEncoding:NSUTF8StringEncoding];
        
        
         [formData appendPartWithFormData:_isPushData name:@"isPush"];
       
         [formData appendPartWithFormData:_userIdData name:@"userId"];
       
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}

//退出登录 （2015-10-16  何小慧）app/userInfo/userInfoLogout.htm
-(void)PostUserInfoLogoutUserId:(NSString *)userId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/userInfoLogout.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}

//发送好友验证（郭乐）  app/verificationMessage/saveVerificationMessageApp.htm
-(void)PostSaveVerificationMessageAppUserId:(NSString *)userId friendsId:(NSString *)friendsId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/verificationMessage/saveVerificationMessageApp.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_friendsIdData=[friendsId dataUsingEncoding:NSUTF8StringEncoding];
         [formData appendPartWithFormData:_friendsIdData name:@"friendsId"];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
    
}

//同意添加好友（郭乐）app/verificationMessage/saveVerificationMessageAgreeApp.htm
-(void)PostSaveVerificationMessageAgreeAppMessageId:(NSString *)messageId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/verificationMessage/saveVerificationMessageAgreeApp.htm",SERVER_DEMAIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_messageIdData=[messageId dataUsingEncoding:NSUTF8StringEncoding];
         [formData appendPartWithFormData:_messageIdData name:@"messageId"];
       
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
}


//扫一扫加好友（郭乐）app/verificationMessage/saveVerificationMessageSweepApp.htm
-(void)PostSaveVerificationMessageSweepAppUserId:(NSString *)userId friendsId:(NSString *)friendsId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/verificationMessage/saveVerificationMessageSweepApp.htm",SERVER_DEMAIN];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         NSData *_userIdData=[userId dataUsingEncoding:NSUTF8StringEncoding];
         NSData *_friendsIdData=[friendsId dataUsingEncoding:NSUTF8StringEncoding];
         [formData appendPartWithFormData:_friendsIdData name:@"friendsId"];
         [formData appendPartWithFormData:_userIdData name:@"userId"];
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}

//血压测量数据存储数据（郭乐） app/bloodPressure/saveBloodPressureApp.htm
-(void)SaveBloodPressureDataRequestWithUserId:(NSString *)userId  equipmentNo:(NSString *)equipmentNo bloodPressureOpen:(NSString *)bloodPressureOpen  bloodPressureClose:(NSString *)bloodPressureClose  pulse:(NSString *)pulse measureTime:(NSString *)measureTime type:(NSString *)type andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/bloodPressure/saveBloodPressureApp.htm",SERVER_DEMAIN];
    NSDictionary *paramDic;
    
    if ([type isEqualToString:@"2"])
    {
        paramDic = @{@"userId":userId,@"bloodPressureOpen":bloodPressureOpen,@"bloodPressureClose":bloodPressureClose,@"pulse":pulse,@"measureTime":measureTime,@"type":type};
    }
    else
    {
        paramDic = @{@"userId":userId, @"equipmentNo":equipmentNo,@"bloodPressureOpen":bloodPressureOpen,@"bloodPressureClose":bloodPressureClose,@"pulse":pulse,@"type":type};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         
         
         
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
}

//第三方登录(2015-10-15  何小慧) app/userInfo/thirdPartyLogin
-(void)LoginWithWeiXinAndWeiBoRequestWithUserId:(NSString *)userName  andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/userInfo/thirdPartyLogin.htm",SERVER_DEMAIN];
    NSDictionary *paramDic = @{@"userName":userName};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];
}

//好友留言（郭乐）app/friendsMessage/saveFriendsMessageApp.htm
-(void)PostSaveFriendsMessageAppUserId:(NSString *)userId messageContent:(NSString *)messageContent myFriendsId:(NSString *)myFriendsId andCompletion:(LLDPResponseBlock)completion
{
    NSString *urls = [NSString stringWithFormat:@"%@app/friendsMessage/saveFriendsMessageApp.htm",SERVER_DEMAIN];

    NSDictionary * paramDic = @{@"userId":userId,@"messageContent":messageContent,@"myFriendsId":myFriendsId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"text/html",@"text/plain",nil]];
    [manager POST:urls parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject,nil);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil,error);
         
     }];

}
@end
