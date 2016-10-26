//
//  Student.h
//  RuntimeNSCoding
//
//  Created by Alex on 2016/10/26.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Persion.h"

@interface Student : Persion
{
    NSString *studentId;
}

@property (copy, nonatomic) NSString *className;

@end
