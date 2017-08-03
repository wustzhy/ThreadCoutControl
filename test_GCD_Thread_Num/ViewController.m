//
//  ViewController.m
//  test_GCD_Thread_Num
//
//  Created by Ray on 2017/8/4.
//  Copyright © 2017年 Yestin. All rights reserved.
//

#import "ViewController.h"

#import "QSDispatchQueue.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // - cannot control max thread count
//    [self test_GCD_dispatch_async];

    // - can control max thread count
//    [self test_NSOperationQueue_withMaxTheadCount:2];
//    [self test_QSDispatchQueue_withMaxTheadCount:2];
    [self test_GCD_semaphore_WithMaxTheadCount:10];
}


// GCD, dispatch_async
- (void)test_GCD_dispatch_async {

    NSLog(@"begin: %@",[NSThread currentThread]);
    for (int i = 0; i < 10; i++) {
        __block int index = i;
        
        dispatch_async(dispatch_queue_create("socket msg recv queue", NULL), ^{
        
            sleep(1);
            NSLog(@"执行第%zd次操作，线程：%@",index, [NSThread currentThread]);
        
        });
    }
// count:   10
// begin:   02:52:54.213
// end  :   02:52:55.231
// time :    ≈ 1s
}

//  NSOperationQueue
- (void)test_NSOperationQueue_withMaxTheadCount:(NSInteger) max {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue setMaxConcurrentOperationCount:max];
    
    NSLog(@"begin: %@",[NSThread currentThread]);
    for (int i = 0; i < 10; i++) {
        
        __block int index = i;
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^(){
            sleep(1);
            NSLog(@"执行第%zd次操作，线程：%@",index, [NSThread currentThread]);
        }];
        
        [queue addOperation:operation];

    }
    
// max  :   2               10
// begin:   02:29:49.548    02:41:20.911
// end  :   02:29:54.806    02:41:21.985
// time :      ≈ 5.26s         ≈ 1s
}

// QSDispatchQueue
- (void)test_QSDispatchQueue_withMaxTheadCount:(NSInteger) max {

    dispatch_queue_t concurrentQueue = dispatch_queue_create("socketConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    QSDispatchQueue *queue = [[QSDispatchQueue alloc]initWithQueue:concurrentQueue concurrentCount:max];
    
    NSLog(@"begin: %@",[NSThread currentThread]);
    for (int i = 0; i < 10; i++) {
        __block int index = i;
        [queue async:^{
            sleep(1);
            NSLog(@"执行第%zd次操作，线程：%@",index, [NSThread currentThread]);
        }];
    }
    
// max  :   2               10
// begin:   02:37:29.052    02:40:11.811
// end  :   02:37:34.069    02:40:12.816
// time :    ≈ 5.1s           ≈ 1s
}

- (void)test_GCD_semaphore_WithMaxTheadCount:(NSInteger) max {
    
    dispatch_queue_t workConcurrentQueue = dispatch_queue_create("cccccccc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue = dispatch_queue_create("sssssssss",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(max);    // create semaphore: value = 3

    NSLog(@"begin: %@",[NSThread currentThread]);
    for (int i = 0; i < 10; i++) {
        __block int index = i;
        dispatch_async(serialQueue, ^{
            
            // If value < 0, then wait here. Else value > 0, then pass, and value -1
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(workConcurrentQueue, ^{
                
                sleep(1);
                NSLog(@"执行第%zd次操作，线程：%@",index, [NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);});                // Perform value +1
        });
    }
    NSLog(@"主线程...!");
// max  :   2               10
// begin:   03:02:45.309    03:05:53.301
// end  :   03:02:50.332    03:05:54.309
// time :    ≈ 5.03s           ≈ 1s
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
