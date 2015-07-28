//
//  YDMenu.m
//  YNOA
//
//  Created by 224 on 14-9-10.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDMenu.h"

@implementation YDMenu

#define kMenuCode @"menuCode"
#define kMenuName @"menuName"
#define kMenuImage @"menuImage"
#define kMenuURL @"menuURL"
#define kMenuAllowTop @"menuAllowTop"
#define kMenuOrderTag @"menuOrderTag"
#define kMenuVersion @"menuVersion"
#define kMenuIMG @"menuIMG"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_menuCode forKey:kMenuCode];
    [aCoder encodeObject:_menuName forKey:kMenuName];
    [aCoder encodeObject:_image forKey:kMenuImage];
    [aCoder encodeObject:_url forKey:kMenuURL];
    [aCoder encodeObject:_allowTop forKey:kMenuAllowTop];
    [aCoder encodeObject:_orderTag forKey:kMenuOrderTag];
    [aCoder encodeObject:_version forKey:kMenuVersion];
    [aCoder encodeObject:_Img forKey:kMenuIMG];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        _menuCode=[aDecoder decodeObjectForKey:kMenuCode];
        _menuName=[aDecoder decodeObjectForKey:kMenuName];
        _image=[aDecoder decodeObjectForKey:kMenuImage];
        _url=[aDecoder decodeObjectForKey:kMenuURL];
        _allowTop=[aDecoder decodeObjectForKey:kMenuAllowTop];
        _Img=[aDecoder decodeObjectForKey:kMenuIMG];
        _orderTag=[aDecoder decodeObjectForKey:kMenuOrderTag];
        _version=[aDecoder decodeObjectForKey:kMenuVersion];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YDMenu *copy=[[[self class] allocWithZone:zone] init];
    copy.menuCode=[self.menuCode copyWithZone:zone];
    copy.menuName=[self.menuName copyWithZone:zone];
    copy.image=[self.image copyWithZone:zone];
    copy.Img=self.Img;
    copy.url=[self.url copyWithZone:zone];
    copy.allowTop=[self.allowTop copyWithZone:zone];
    copy.orderTag=[self.orderTag copyWithZone:zone];
    copy.version=[self.version copyWithZone:zone];
    
    return copy;
}

@end
