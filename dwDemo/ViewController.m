//
//  ViewController.m
//  dwDemo
//
//  Created by dw962666721 on 2017/9/14.
//  Copyright © 2017年 dw962666721. All rights reserved.
//

#import "ViewController.h"
#import <Charts/Charts.h>
#import "dwDemo-Swift.h"
#import "NetworkTool.h"
#import "SRWebSocket.h"

@interface ViewController ()<ChartViewDelegate,SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet CandleStickChartView *chartView;
@property NSMutableArray *dataArray;
@property ChartLimitLine *ll1; // 实时价格
@property (nonatomic, assign) BOOL shouldHideData;
@property (nonatomic) UILabel *markY;
@property NSString *buttonString;
@property NSString *nameString;
@property NSMutableArray *valueColors;
@property (nonatomic, strong)SRWebSocket * webSocketNumber;
@property NSString *starTime;
@property bool isLoading; // 正在短链接刷新
@end

@implementation ViewController

-(void)loadData
{
    self.isLoading=YES;
    NSDictionary * parameters = @{@"period":self.buttonString,@"symbol":self.nameString,@"startTime":@"2017-09-13T10:06:03Z"};
    
    
    [[NetworkTool sharedTools] POST:@"symbols/charts" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        if (responseObject[@"param"])
        {
            NSDictionary * dict = responseObject[@"param"];
            if ([dict class]==[[[NSArray alloc]init] class])
            {
                return ;
            }
            if (dict[@"list"])
            {
                NSArray * sourceArray = dict[@"list"];
                // 创建数据
                self.dataArray = [self getKData:sourceArray];
                
                // 设置阴阳烛样式
                CandleChartDataSet *set1 = [self setKStyle: self.dataArray];
                
                _chartView.xAxis.axisMaximum = self.dataArray.count+10;
                
                // 绑定数据
                CandleChartData *data = [[CandleChartData alloc] initWithDataSet:set1];
                _chartView.data = data;
                
                //我自定义的一个MarkerView。(十字选中的提示文字)
                dwMarkerView *markerY = [[dwMarkerView alloc]init];
                markerY.chartView = _chartView;
                _chartView.marker = markerY;
                [markerY addSubview:self.markY];
                // 启动socket
                [self loadSocketData];
                
                [_chartView zoomWithScaleX:100 scaleY:0 x:0 y:0];
                CandleChartDataEntry *entry = self.dataArray.lastObject;
                //将最后的数据滑动到中间
                [_chartView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_chartView.data getDataSetByIndex:0].axisDependency duration:0.25];

            }
        }
         self.isLoading=NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [self loadSocketData];
        NSLog(@"%@",error);
         self.isLoading=NO;
    }];
}
-(NSMutableArray *)getKData:(NSArray*)sourceArray
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    self.valueColors = [[NSMutableArray alloc] init];
    for (int i = 0; i < sourceArray.count; i++)
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:sourceArray[i]];
        double high = [dic[@"high"] doubleValue] ;
        double low = [dic[@"low"] doubleValue] ;
        double open = [dic[@"open"] doubleValue];
        double close = [dic[@"close"] doubleValue];
        NSString *string = [NSString stringWithFormat:@"%@",dic[@"timestamp"]];//model.modifyTime;
//        double second = string.doubleValue;
        CandleChartDataEntry * entry = [[CandleChartDataEntry alloc] initWithX:i shadowH:high shadowL:low open:open close:close data:dic];
        [yVals1 addObject:entry];
        
        // 添加蜡烛颜色
        if (open>close)
        {
            [self.valueColors addObject:[UIColor redColor]];
        }
        else
        {
             [self.valueColors addObject:[UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f]];
        }
        
        // 获取最后一个蜡烛的时间
        
    }
    return yVals1;
}
-(CandleChartDataSet*)setKStyle:(NSMutableArray*)yVals1
{
    // 蜡烛样式
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:yVals1 label:@"Data Set"];
    set1.axisDependency = AxisDependencyLeft;
    //        [set1 setColor:[UIColor redColor]];
    //        NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor],[UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f], nil];
    //        [set1 setColors:colors];
    
    set1.colors = self.valueColors;
    
    set1.drawIconsEnabled = NO;
    set1.shadowWidth = 1;
    set1.decreasingColor = UIColor.redColor;
    set1.decreasingFilled = YES;
    set1.increasingColor = [UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f];
    set1.increasingFilled = YES;
    //        set1.neutralColor = UIColor.blueColor;
    
    // 十字交叉线的样式
    set1.drawHorizontalHighlightIndicatorEnabled = YES;
    set1.drawVerticalHighlightIndicatorEnabled = YES;
    set1.highlightColor = [UIColor whiteColor];
    set1.drawValuesEnabled = NO; // 不显示提示文字
    // 设置这项上显示的数据点的字体大小
    set1.valueFont = [UIFont systemFontOfSize:10];
    set1.valueTextColor = [UIColor whiteColor];
    
    return set1;
}
- (void)loadSocketData
{
    _webSocketNumber.delegate = nil;
    [_webSocketNumber close];
//    ws://103.20.249.35:9516 
    _webSocketNumber = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://103.20.249.35:9506"]]];
    
    //    NSOperationQueue * que = [NSOperationQueue new];
    _webSocketNumber.delegate = self;
    //    [_webSocketNumber setDelegateDispatchQueue:queue];
    //    [_webSocketNumber setDelegateOperationQueue:[NSOperationQueue mainQueue]];
    [_webSocketNumber open];
    
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocketNumber = nil;
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    
    if (self.isLoading) {
        return;
    }
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    NSArray * array = dic[@"quote"];
    
    //    NSLog(@"==%@",array);
    
    for (NSDictionary * productInfoDict in array) {
        
        NSString * name = [NSString stringWithFormat:@"%@",productInfoDict[@"symbol"]];
        
//        BOOL isFivebool = [self.fiveArray containsObject:name];
//        BOOL isThreebool = [self.threeArray containsObject:name];
//        BOOL isTwobool = [self.twoArray containsObject:name];
//        
        if ([self.nameString isEqualToString:name]) {
//
//            double high = [productInfoDict[@"high"] doubleValue];
//            double low = [productInfoDict[@"low"] doubleValue];
            double bid = [productInfoDict[@"bid"] doubleValue];
            double time = [productInfoDict[@"time"] doubleValue];
            
            // 刷新实时价格线
            [self.ll1 setLimit:bid];
            [self.ll1 setLabel:[NSString stringWithFormat:@"%.2f",bid]];
            
            // 更新最后一个蜡烛的数据
            if (self.chartView.data.dataSets.count>0)
            {
                CandleChartDataSet *set1 = (CandleChartDataSet *)self.chartView.data.dataSets[0];
                // 创建数据
//                NSMutableArray *yVals1 =[[NSMutableArray alloc] initWithArray:set1.values];
                CandleChartDataEntry *lastEntry = self.dataArray.lastObject;
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:lastEntry.data];
                double high = [dic[@"high"] doubleValue];
                double low = [dic[@"low"] doubleValue];
                double open = [dic[@"open"] doubleValue];
                double lasttime = [dic[@"timestamp"] doubleValue];
                
                NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:lasttime];
                NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:time];
                // 判断是否需要更新主数据
                bool isNeedReload = [self ShouldReLoad:lastDate nowDate:nowDate];
                
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                if (!isNeedReload)
                {
                    dataDic[@"high"] = dic[@"high"];
                    dataDic[@"low"] = dic[@"low"];
                    dataDic[@"open"] = dic[@"open"];
                    dataDic[@"timestamp"] = dic[@"timestamp"];
                }
                else
                {
                    dataDic[@"high"] = dic[@"high"];
                    dataDic[@"low"] = dic[@"low"];
//                    dataDic[@"close"] = productInfoDict[@"bid"];
                    dataDic[@"open"] = productInfoDict[@"bid"];
                    dataDic[@"timestamp"] =productInfoDict[@"time"];
                }
                // 重新绑定最后一个数据
                CandleChartDataEntry * nowEntry = [[CandleChartDataEntry alloc] initWithX:self.dataArray.count-1 shadowH:high shadowL:low open:open close:bid data:dataDic];
                [self.dataArray replaceObjectAtIndex: self.dataArray.count-1 withObject:nowEntry];
                
                // 设置最后蜡烛颜色
                if (open>bid)
                {
                    [self.valueColors replaceObjectAtIndex:self.valueColors.count-1 withObject:[UIColor redColor]];
                }
                else
                {
                     [self.valueColors replaceObjectAtIndex:self.valueColors.count-1 withObject:[UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f]];
                }
                set1.colors = self.valueColors;
                
                // 通知界面刷新
//                [_chartView.data notifyDataChanged];
                
                // 时间戳 -> NSDate *
               
                if (isNeedReload)
                {
                    // 如果时间已经过时了，使用长链接获取数据
//                    [self loadData];
                    self.isLoading=YES;
                    [ self.dataArray addObject:nowEntry];
                    // 设置最后蜡烛颜色
                    if (open>bid)
                    {
                        [self.valueColors addObject:[UIColor redColor]];
                    }
                    else
                    {
                        [self.valueColors addObject:[UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f]];
                    }
                    self.isLoading=NO;
                }
                 set1.values = self.dataArray;
            }
            
            
            // 通知控件刷新界面
             [_chartView notifyDataSetChanged];
            
        }
    }
    
}
-(bool)ShouldReLoad:(NSDate*)lastDate nowDate:(NSDate*)nowDate
{
     bool isNeedReload = NO;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 日期减
    unsigned int unitFlags = kCFCalendarUnitMinute;//年、月、日、时、分、秒、周等等都可以
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:lastDate toDate:nowDate options:0];
    NSInteger minute = [comps minute];//时间差
    if ([self.buttonString isEqualToString:@"m1"])
    {
        if (minute!=0)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"m5"])
    {
        if (minute>=5)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"m15"])
    {
        if (minute>=15)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"m30"])
    {
        if (minute>=30)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"h1"])
    {
        if (minute>=60)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"h4"])
    {
        if (minute>=60*4)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"d1"])
    {
        if (minute>=60*24)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"w1"])
    {
        if (minute>=60*24*7)
        {
            isNeedReload=YES;
        }
    }
    if ([self.buttonString isEqualToString:@"mn1"])
    {
        isNeedReload=NO;
    }
    return isNeedReload;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _webSocketNumber = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonString = @"m1";
    self.nameString = @"XAUUSDapp";
    self.title = @"Candle Stick Chart";
    
    // 设置表格样式
    _chartView.delegate = self;
    _chartView.chartDescription.enabled = NO;
    _chartView.backgroundColor = [UIColor blackColor];
    
//    _chartView.maxVisibleCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.scaleXEnabled = YES;
//    _chartView.scaleYEnabled = NO;
    _chartView.autoScaleMinMaxEnabled=YES;
    
    
    _chartView.drawGridBackgroundEnabled = YES;
    _chartView.gridBackgroundColor = [UIColor blackColor];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
//    xAxis.labelCount=8;
    xAxis.labelTextColor = [UIColor whiteColor];
    xAxis.axisLineColor = [UIColor whiteColor];
    xAxis.drawGridLinesEnabled = YES;
    
    DateValueFormatter *dateValueFormatter = [[DateValueFormatter alloc]init];
    dateValueFormatter.dtType = self.buttonString;
    dateValueFormatter.starDateStr = @"2017-09-13 10:06:03";
    xAxis.valueFormatter = dateValueFormatter; //设置y轴的数据格式
   
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.enabled = NO;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
//    rightAxis.axisMaximum=7;
    rightAxis.labelCount=7;
    rightAxis.forceLabelsEnabled = YES;//不强制绘制指定数量的label
    rightAxis.decimals=2;
    rightAxis.labelTextColor = [UIColor whiteColor];
    rightAxis.drawGridLinesEnabled = YES;
    rightAxis.drawAxisLineEnabled = YES;
    rightAxis.axisLineColor = [UIColor whiteColor];;
    //rightAxis.
//    _chartView.
    // 设置线段
    _chartView.xAxis.gridLineDashLengths = @[@1.0, @1.0];
    self.ll1 = [[ChartLimitLine alloc] init];
    self.ll1.lineWidth = 1.0;
    self.ll1.lineDashLengths = @[@0.f, @0.f];
    self.ll1.lineColor = [UIColor whiteColor];
    self.ll1.labelPosition = ChartLimitLabelPositionRightTop;
    self.ll1.valueFont = [UIFont systemFontOfSize:10.0];
    self.ll1.valueTextColor = [UIColor whiteColor];
    [rightAxis addLimitLine:self.ll1];
//    rightAxis.axisMaximum = 1.21101;
//    rightAxis.axisMinimum = 1.21095;
    rightAxis.gridLineDashLengths = @[@1.f, @1.f];
    rightAxis.drawZeroLineEnabled = NO;
    rightAxis.drawLimitLinesBehindDataEnabled = YES;
    
    _chartView.legend.enabled = NO;
    
    // 获取数据
    [self loadData];
}
- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
//    [self setDataCount:_sliderX.value + 1 range:_sliderY.value];
}
//懒加载
- (UILabel *)markY{
    if (!_markY) {
        _markY = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 10)];
        _markY.font = [UIFont systemFontOfSize:10.0];
        _markY.textAlignment = NSTextAlignmentLeft;
        _markY.text =@"";
        _markY.textColor = [UIColor whiteColor];
        _markY.backgroundColor = [UIColor grayColor];
    }
    return _markY;
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleShadowColorSameAsCandle"])
    {
        for (id<ICandleChartDataSet> set in _chartView.data.dataSets)
        {
            set.shadowColorSameAsCandle = !set.shadowColorSameAsCandle;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    }
    
//    [super handleOption:key forChartView:_chartView];
}
#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
    NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:entry.data];
    double high = [dic[@"high"] doubleValue] ;
    double low = [dic[@"low"] doubleValue] ;
    double mid = low+(high-low);
    _markY.text = [NSString stringWithFormat:@"%ld",(NSInteger)mid];//改变选中的数据时候，label的值跟着变化
    //将点击的数据滑动到中间
//    [_chartView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_chartView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
