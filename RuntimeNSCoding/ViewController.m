//
//  ViewController.m
//  RuntimeNSCoding
//
//  Created by Alex on 2016/10/26.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self printDifferenceCopyIvarListAndCopyPropertyList];
    [self archiverAndUnarchiver];
}

#pragma mark -
#pragma mark - 获取Documents文件夹路径
- (NSString *)getDocumentPath {
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documents[0] stringByAppendingPathComponent:@"persion"];
    return documentPath;
}

#pragma mark -
#pragma mark - class_copyIvarList 和 class_copyPropertyList的区别
- (void)printDifferenceCopyIvarListAndCopyPropertyList
{
    Student *student = [Student new];
    // 获取当前类的所有属性和变量(包括在@interface大括号中声明的变量)
    unsigned int outCount = 0;
    Ivar *ivarList = class_copyIvarList([student class], &outCount);
    for (NSInteger i = 0; i < outCount; i++) {
        const char *varName = ivar_getName(ivarList[i]);
        NSString *varKey = [NSString stringWithUTF8String:varName];
        NSLog(@"varKey:%@",varKey);
    }
    
    // 获取当前类的所有属性(@property申明的属性)
    unsigned int propertyVarCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([student class], &propertyVarCount);
    for (NSInteger i = 0; i < propertyVarCount; i++) {
        const char *varName = property_getName(propertyList[i]);
        NSString *propertyKey = [NSString stringWithUTF8String:varName];
        NSLog(@"propertyKey:%@",propertyKey);
    }
}

#pragma mark -
#pragma mark - 归档和解挡
- (void)archiverAndUnarchiver
{
    Student *student = [Student new];
    student.name = @"alxe";
    student.age = 18;
    student.className = @"四年级一班";
    
    NSMutableData* data = [NSMutableData data];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:student forKey:@"student"];
    [archiver finishEncoding];
    [data writeToFile:[self getDocumentPath] atomically:YES];
    
    NSData* cacheData = [NSData dataWithContentsOfFile:[self getDocumentPath]];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:cacheData];
    Student *cachePersion = [unarchiver decodeObjectForKey:@"student"];
    [unarchiver finishDecoding];
    
    NSLog(@"----->name:%@",cachePersion.name);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
