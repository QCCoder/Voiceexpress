//
//  QCZipImage.m
//  Theme
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCZipImage.h"

@implementation QCZipImage

-(instancetype)initWithNSDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.themeID = dict[@"themeID"];
        self.fileName = dict[@"fileName"];
        self.themeImg = dict[@"themeImg"];
        self.toPath = dict[@"toPath"];
    }
    return self;
}
//归档
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.themeID forKey:@"themeID"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.themeImg forKey:@"themeImg"];
    [aCoder encodeObject:self.toPath forKey:@"toPath"];
}

//接档
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.themeID = [aDecoder decodeObjectForKey:@"themeID"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.themeImg = [aDecoder decodeObjectForKey:@"themeImg"];
        self.toPath = [aDecoder decodeObjectForKey:@"toPath"];
    }
    return self;
}



@end
