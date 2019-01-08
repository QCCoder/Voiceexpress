//
//  ThemeTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/2.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "ThemeTool.h"
#import "DownloadTool.h"
@implementation ThemeTool

+(void)loadTheme{
    
    if ([VEUtility currentLocalVersion].length == 0) {
        NSString *path =[kDocumentsDirectory stringByAppendingPathComponent:@"Theme"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    if (![VEUtility isCurrentNetworkWifi]) {
        return;
    }
    
    NSString *str =[VEUtility currentSkinVersion];
    if (str == nil) {
        str = @"";
    }
    
    
     
    NSDictionary *dict = @{
                           @"clientVersion":[VEUtility curAppVersion],
                           @"skinVersion": str,
                           @"device":@"iga"
                           };
    [HttpTool postWithUrl:@"SkinVersionCheck" Parameters:dict Success:^(id JSON) {
        DLog(@"%@",JSON);
        NSInteger result = [JSON[@"result"] integerValue];
        if (result == 0) {
            NSString *url = JSON[@"url"];
            if (url.length> 0) {
                NSString *version = JSON[@"version"];
                DownloadTool *tool =[DownloadTool download];
                ALERT(@"提示", @"正在下载皮肤");
                [tool downloadFile:url Path:@"Theme.zip" Success:^(id responseObject,NSString *path) {
                    [QCZipImageTool unzipFileAtPath:path toPath:kDocumentsDirectory success:^(BOOL success, id JSON) {
                        if (success) {
                            [VEUtility setCurrentSkinVersion:version];
                            [VEUtility setCurrentLocalVersion:[VEUtility curAppVersion]];
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:RELOADIMAGE object:nil];
                        }
                    }];
                } Failure:^(NSError *error) {
                    NSLog(@"fail");
                } Progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                }];
            }else{
                NSString *localVersion =[VEUtility currentLocalVersion];
                NSString *curVersion =[VEUtility curAppVersion];
                if (![localVersion isEqualToString:curVersion] && localVersion.length>0 && [localVersion compare:curVersion] == NSOrderedAscending) {//若app版本和本地缓存版本不一致（APP升级过），就不能用原来的皮肤，删除。
                    NSString *path =[kDocumentsDirectory stringByAppendingPathComponent:@"Theme"];
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RELOADIMAGE object:nil];
                }
            }
        }
    } Failure:^(NSError *error) {
        DLog(@"%@",[error localizedDescription]);
    }];
}
@end
