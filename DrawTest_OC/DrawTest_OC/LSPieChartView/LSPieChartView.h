//
//  LSPieChartView.h
//  DrawTest_OC
//
//  Created by Lisa on 2017/4/15.
//  Copyright © 2017年 Lisa. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - PieChartComponent -

@interface PieChartComponent : NSObject

@property (nonatomic, assign, readonly) CGFloat proportion;

@property (nonatomic, strong, readonly) NSString * _Nonnull statement;

@property (nonatomic, strong, readonly) UIColor  * _Nonnull color;

/**
 * @brief 初始化 proportion: 占比, statement: 说明
 */
- (instancetype _Nonnull )initWithProportion:(CGFloat)proportion statement:(NSString *_Nullable)statement;

/**
 * @brief 初始化 proportion: 占比, statement: 说明, color: 扇形颜色
 */
- (instancetype _Nonnull )initWithProportion:(CGFloat)proportion statement:(NSString *_Nullable)statement color:(UIColor *_Nullable)color;

@end


#pragma mark - LSPieChartView -

@interface LSPieChartView : UIView

/**
 * @brief 圆饼图中心显示名称
 */
@property (nonatomic, strong) NSString * _Nullable title;
/**
 * @brief title字体样式
 */
@property (nonatomic, strong) NSDictionary * _Nullable titleAttributes;
/**
 * @brief 注释字体样式
 */
@property (nonatomic, strong) NSDictionary * _Nullable statementAttributes;
/**
 * @brief 圆心 默认为页面中心
 */
@property (nonatomic, assign) CGPoint centerPoint;
/**
 * @brief 内圆半径 默认为外圆半径的40%
 */
@property (nonatomic, assign) CGFloat minRadius;
/**
 * @brief 外圆半径 默认为页面中宽或高（较短的那一个）的1/4
 */
@property (nonatomic, assign) CGFloat maxRadius;
/**
 * @brief 是否在扇形内显示百分比 默认为 YES
 */
@property (nonatomic, assign) BOOL enablePersentInFan;
/**
 * @brief 是否要注解 默认为 YES
 */
@property (nonatomic, assign) BOOL enableAnnotation;
/**
 * @brief 是否有内圆 默认为 YES
 */
@property (nonatomic, assign) BOOL hasInnerCircle;

/**
 * @brief 添加扇形图
 */
- (BOOL)addComponent:(PieChartComponent * _Nonnull)component;

@end
