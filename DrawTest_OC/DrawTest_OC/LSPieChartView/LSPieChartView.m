//
//  LSPieChartView.m
//  DrawTest_OC
//
//  Created by Lisa on 2017/4/15.
//  Copyright © 2017年 Lisa. All rights reserved.
//

#import "LSPieChartView.h"
#import <QuartzCore/QuartzCore.h>

#define kMargin 10.0
#define kStatementMargin 8.0
#define kStatementFirstLineLength 8.0
#define kStatementSecondLineLength(angle) (20.0 * fabs(sin(angle)))

#pragma mark - PieChartComponent -

@interface PieChartComponent ()

@end

@implementation PieChartComponent

- (instancetype)initWithProportion:(CGFloat)proportion statement:(NSString *)statement
{
    return [self initWithProportion:proportion
                          statement:statement
                              color:[self randomColor]];
}

- (instancetype)initWithProportion:(CGFloat)proportion statement:(NSString *)statement color:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.proportion = proportion;
        self.statement = (statement ? : [NSString stringWithFormat:@"%f %%", proportion * 100.0]);
        self.color = (color ? : [self randomColor]);
    }
    return self;
}

#pragma mark - Setters

- (void)setStatement:(NSString *)statement {
    _statement = statement;
}

- (void)setProportion:(CGFloat)proportion {
    if (proportion > 1.0) {
        NSLog(@"PieChart_Component-Error: 所占比例大于100%%!");
    }
    _proportion = proportion;
}

- (void)setColor:(UIColor *)color {
    _color = color;
}

#pragma mark - Tools

- (UIColor *)randomColor {
    CGFloat redValue = (arc4random() % 256) / 255.0;
    CGFloat greenValue = (arc4random() % 256) / 255.0;
    CGFloat blueValue = (arc4random() % 256) / 255.0;
    
    return [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1];
}

@end


#pragma mark - LSPieChartView -

@interface LSPieChartView ()

@property (nonatomic, strong) NSMutableArray <PieChartComponent *> *components;

@end

@implementation LSPieChartView

#pragma mark - Initial

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initData];
    }
    return self;
}

- (void)initData {
    _enablePersentInFan = YES;
    _enableAnnotation = YES;
    _hasInnerCircle = YES;
    _centerPoint = self.center;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    _maxRadius = (width < height ? width : height) / 4;
    _minRadius = _maxRadius * 0.4;
}

#pragma mark - Public

- (BOOL)addComponent:(PieChartComponent *)component {
    CGFloat rate = 0;
    for (PieChartComponent *c in self.components) {
        rate += c.proportion;
        if (CGColorEqualToColor(component.color.CGColor, c.color.CGColor)) {
            NSLog(@"(PieChart)Error: %@ 与 %@ 模块颜色相同！", component.statement, c.statement);
            return false;
        }
    }
    if (rate + component.proportion > 1) {
        NSLog(@"(PieChart)Error: 总占比例已大于100%%!");
        return false;
    }
    [self.components addObject:component];
    return true;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat startAngle = 0, endAngle;
    for (PieChartComponent *component in self.components) {
        endAngle = 2 * M_PI * component.proportion + startAngle;
        [self addFanShapeWithColor:component.color.CGColor fromAngle:startAngle toAngle:endAngle inContext:context];
        if (_enablePersentInFan) {
            [self addPercentInFan:component.proportion atAngle:(startAngle + endAngle)/2];
        }
        if (_enableAnnotation) {
            [self addStatement:component.statement withAngle:(startAngle + endAngle)/2 inContext:context];
        }
        startAngle = endAngle;
    }
    if (_hasInnerCircle) {
        [self addInnerCircleWithColor:[UIColor whiteColor].CGColor inContext:context];
    }
}

#pragma mark - Getters

- (NSMutableArray *)components {
    if (!_components) {
        _components = [NSMutableArray array];
    }
    return _components;
}

- (NSDictionary *)titleAttributes {
    if (!_titleAttributes) {
        _titleAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14] };
    }
    return _titleAttributes;
}

- (NSDictionary *)statementAttributes {
    if (!_statementAttributes) {
        _statementAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14] };
    }
    return _statementAttributes;
}

#pragma mark - Private Draw

// 添加扇形
- (void)addFanShapeWithColor:(CGColorRef)colorRef
                   fromAngle:(CGFloat)startAngle
                     toAngle:(CGFloat)endAngle
                   inContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, colorRef);
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
    CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _maxRadius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
}

// 添加说明
- (void)addStatement:(NSString *)statement withAngle:(CGFloat)angle inContext:(CGContextRef)context
{
    CGFloat distance = _maxRadius + kStatementMargin; // 园外点与圆心的距离
    CGFloat sineValue = sin(angle + M_PI/2.0);
    CGFloat cosineValue = cos(angle + M_PI/2.0);
    
    CGPoint firstPoint = CGPointMake(_centerPoint.x + sineValue * distance, _centerPoint.y - cosineValue * distance);
    CGPoint secondPoint = CGPointMake(firstPoint.x + sineValue * kStatementFirstLineLength, firstPoint.y - cosineValue * kStatementFirstLineLength);
    
    BOOL isAtLeft = secondPoint.x < _centerPoint.x;
    CGFloat lineLength = kStatementSecondLineLength(angle);
    CGPoint thirdPoint = CGPointMake( isAtLeft ? (secondPoint.x - lineLength) : (secondPoint.x + lineLength), secondPoint.y);
    
    // 绘折线
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    CGContextAddLineToPoint(context, secondPoint.x, secondPoint.y);
    CGContextAddLineToPoint(context, thirdPoint.x, thirdPoint.y);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 绘文字
    CGRect rect = [statement boundingRectWithSize:CGSizeMake((isAtLeft ? thirdPoint.x : (self.bounds.size.width - thirdPoint.x)) - kMargin - 3, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.statementAttributes context:nil];
    [statement drawInRect:CGRectOffset(rect, isAtLeft ? (thirdPoint.x - rect.size.width - 3) : thirdPoint.x + 3, thirdPoint.y - rect.size.height / 2) withAttributes:self.statementAttributes];
}

// 添加百分比
- (void)addPercentInFan:(CGFloat)percent atAngle:(CGFloat)angle
{
    CGFloat distance = _hasInnerCircle ? (_maxRadius + _minRadius) * 0.5 : (_maxRadius * 0.6);
    CGFloat sineValue = sin(angle + M_PI/2.0);
    CGFloat cosineValue = cos(angle + M_PI/2.0);
    CGPoint strCenter = CGPointMake(_centerPoint.x + sineValue * distance, _centerPoint.y - cosineValue * distance);
    
    NSString *percentStr = [NSString stringWithFormat:@"%.1f%%", percent * 100];
    CGRect rect = [percentStr boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:self.statementAttributes context:nil];
    rect.origin.x = strCenter.x - rect.size.width / 2.0;
    rect.origin.y = strCenter.y - rect.size.height / 2.0;
    
    [percentStr drawInRect:rect withAttributes:self.statementAttributes];
}

// 添加内圆
- (void)addInnerCircleWithColor:(CGColorRef)colorRef
                      inContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, colorRef);
    CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _minRadius, 0, 2*M_PI, 0);
    CGContextSetShadow(context, CGSizeZero, 10.0);
    CGContextDrawPath(context, kCGPathFill);
    
    if (self.title) {
        CGRect rect = [self.title boundingRectWithSize:CGSizeMake(_minRadius * 2, _minRadius) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.titleAttributes context:nil];
        rect.origin.x = self.center.x - rect.size.width / 2.0;
        rect.origin.y = self.center.y - rect.size.height / 2.0;
        [self.title drawInRect:rect withAttributes:self.titleAttributes];
    }
}

@end
