//
//  ViewController.m
//  DrawTest_OC
//
//  Created by Lisa on 2017/4/15.
//  Copyright © 2017年 Lisa. All rights reserved.
//

#import "ViewController.h"
#import "LSPieChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *testArray = @[@"苹果", @"香蕉", @"橙子", @"菠萝蜜", @"西瓜"];

    LSPieChartView *pieChartView = [[LSPieChartView alloc] initWithFrame:self.view.bounds];
    pieChartView.title = @"Pie Chart";
    pieChartView.titleAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Futura-CondensedMedium" size:20],
                                      NSForegroundColorAttributeName : [UIColor blueColor] };
    pieChartView.statementAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"ChalkboardSE-Light" size:14] };
//    pieChartView.enablePersentInFan = NO;
//    pieChartView.enableAnnotation = NO;
//    pieChartView.hasInnerCircle = NO;
    for (NSString *obj in testArray) {
        PieChartComponent *component = [[PieChartComponent alloc] initWithProportion:0.2 statement:obj];
        [pieChartView addComponent:component];
    }
    [self.view addSubview:pieChartView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
