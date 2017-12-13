//
//  ViewController.m
//  RunLoop_timer
//
//  Created by lyj on 2017/12/5.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import <objc/runtime.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign)int count;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *timeLabel2;
@property (nonatomic, strong) NSThread *subThread;

@property (nonatomic, assign) BOOL isTure;
@end

static const void *kUITableViewIndexKey;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _count = 1;
    if (_isTure) {
#pragma mark 方法二
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];/* NSDefaultRunLoopMode */
        [timer fire];
    }else{
#pragma mark 方法二
        [self createThread];
    }

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)timerUpdate
{
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop].currentMode);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.count ++;
        NSString *timerText = [NSString stringWithFormat:@"计时器:%d",self.count];
        self.timeLabel.text = timerText;
    });
}
#pragma mark timeLabel2
//首先是创建一个子线程
- (void)createThread
{
    NSThread *subThread = [[NSThread alloc] initWithTarget:self selector:@selector(timerTest) object:nil];
    [subThread start];
    self.subThread = subThread;
}

// 创建timer，并添加到runloop的mode中
- (void)timerTest
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSLog(@"启动RunLoop前--%@",runLoop.currentMode);
    NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
    // 第一种写法
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate2) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];/* NSDefaultRunLoopMode */
    [timer fire];
    // 第二种写法
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate2) userInfo:nil repeats:YES];
//    [timer fire];
    
    // 把timer加入到当前runloop后，必须让runloop 运行起来，否则timer仅执行一次。
    [[NSRunLoop currentRunLoop] run];
}
//更新label
-(void)timerUpdate2
{
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop].currentMode);
    NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.count ++;
        NSString *timerText = [NSString stringWithFormat:@"计时器:%d",self.count];
        self.timeLabel2.text = timerText;
    });
}

#pragma mark dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (!cell) {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
    }
    if (_isTure) {
        if (indexPath.row == 2) {
            self.timeLabel = cell.timeLabel;
        }else{
            cell.timeLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
        }
    }else{
        if (indexPath.row == 3) {
            self.timeLabel2 = cell.timeLabel;
        }else{
            cell.timeLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"这里是xx楼"
                                                   delegate:self
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    //然后这里设定关联，此处把indexPath关联到alert上
    objc_setAssociatedObject(alert, &kUITableViewIndexKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSIndexPath *indexPath = objc_getAssociatedObject(alertView, &kUITableViewIndexKey);
        NSLog(@"=======%@", indexPath);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
