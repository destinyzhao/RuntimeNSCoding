//
//  BaseModel.m
//  RuntimeNSCoding
//
//  Created by Alex on 2016/10/26.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

//将对象编码(即:序列化)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"%s",__func__);
    Class cls = [self class];
    while (cls != [NSObject class]) {
        /*判断是自身类还是父类*/
        BOOL bIsSelfClass = (cls == [self class]);
        
        unsigned int iVarCount = 0;
        unsigned int propertyVarCount = 0;
        unsigned int outCount = 0;
        /*获取当前类的所有属性和变量(包括在@interface大括号中声明的变量)*/
        Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;
        /*获取当前类的所有属性(@property申明的属性)*/
        objc_property_t *propertyList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propertyVarCount);
        outCount = bIsSelfClass ? iVarCount : propertyVarCount;
        
        for (int i = 0; i < outCount; i++) {
            const char *varName = bIsSelfClass ? ivar_getName(ivarList[i]) : property_getName(propertyList[i]);
            NSString *key = [NSString stringWithUTF8String:varName];
            /*valueForKey只能获取本类所有变量以及所有层级父类的属性，不包含任何父类的私有变量(会崩溃)*/
            id varValue = [self valueForKey:key];
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                [aCoder encodeObject:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propertyList);
        cls = class_getSuperclass(cls);
    }
}

//将对象解码(反序列化)
- (instancetype)initWithCoder:(NSCoder *)aCoder
{
    NSLog(@"%s",__func__);
    Class cls = [self class];
    while (cls != [NSObject class]) {
        /*判断是自身类还是父类*/
        BOOL bIsSelfClass = (cls == [self class]);
        
        unsigned int iVarCount = 0;
        unsigned int propertyVarCount = 0;
        unsigned int outCount = 0;
        /*获取当前类的所有属性和变量(包括在@interface大括号中声明的变量)*/
        Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;
        /*获取当前类的所有属性(@property申明的属性)*/
        objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propertyVarCount);
        outCount = bIsSelfClass ? iVarCount : propertyVarCount;
        
        for (int i = 0; i < outCount; i++) {
            const char *varName = bIsSelfClass ? ivar_getName(ivarList[i]) : property_getName(propList[i]);
            NSString *key = [NSString stringWithUTF8String:varName];
            id varValue = [aCoder decodeObjectForKey:key];
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                [self setValue:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propList);
        cls = class_getSuperclass(cls);
    }
    return self;
}

@end
