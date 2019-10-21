//
//  ViewController.m
//  GuessImage
//
//  Created by Zhuang Yang on 2019/10/18.
//  Copyright © 2019 Zhuang Yang. All rights reserved.
//

#import "ViewController.h"
#import "GKQuestion.h"

@interface ViewController ()

//所有的数据都存储在这个数组中
@property (nonatomic,strong) NSArray *questions;

//控制题目索引
@property (nonatomic,assign) int index;

//编号控件
@property (weak, nonatomic) IBOutlet UILabel *lblNo;

//标题控件
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

//图片控件
@property (weak, nonatomic) IBOutlet UIButton *imgIcon;

//金币按钮控件
@property (weak, nonatomic) IBOutlet UIButton *btnCoin;

//下一题按钮属性
@property (weak, nonatomic) IBOutlet UIButton *btnNextLet;

//存储原始form
@property(nonatomic,assign) CGRect tempFrame;

//遮罩按钮控件
@property (strong, nonatomic) UIButton *conver;

@property (weak, nonatomic) IBOutlet UIView *optionsView;

@property (weak, nonatomic) IBOutlet UIView *answerView;

//提示按钮单击事件
- (IBAction)promptBtnClick;

//下一题按钮控件
- (IBAction)btnNext:(UIButton *)sender;

//大图按钮控件
- (IBAction)btnBig;

//icon图片按钮单击事件
- (IBAction)imgBtnClick:(id)sender;

@end

@implementation ViewController

//加载遮罩层
- (UIButton *)conver
{
    if (_conver==nil) {
        _conver = [[UIButton alloc] initWithFrame:self.view.bounds];
        _conver.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self.view addSubview:self.conver];
        
        _conver.alpha = 0.0;
        [_conver addTarget:self action:@selector(changeImg) forControlEvents:UIControlEventTouchUpInside];
    }
    return _conver;
}

//封面点击事件
- (IBAction)imgBtnClick:(id)sender {
    [self changeImg];
}

/// 加载数据
- (NSArray *)questions
{
    if (_questions == nil) {
        _questions = [GKQuestion questionList];
    }
    return _questions;
}

//改变状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;    //浅色
}

//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.index = -1;
    [self nextClick];
    
    CGFloat rootW = self.view.frame.size.width;
    CGFloat roowH = self.view.frame.size.height;
    //设置控件初始位置
    self.btnCoin.frame = CGRectMake(rootW-100, 40, 100, 30);
    self.lblNo.frame = CGRectMake((rootW-50)/2, 70, 50, 30);
    self.lblTitle.frame = CGRectMake(0, 110, rootW, 30);
    self.imgIcon.frame = CGRectMake((rootW-160)/2, 150, 160, 160);
    
}


//下一题执行方法
- (IBAction)btnNext:(UIButton *)sender {
    
    [self nextClick];
    
}

- (void)nextClick
{
    //启用待选区
    self.optionsView.userInteractionEnabled = YES;
    //当前下标+1
    self.index++;
    
    if(self.index>self.questions.count-1)
    {
        self.index = -1;
        [self nextClick];
    }
    
    //从数据中按照索引取出对应模型
    GKQuestion *model =  self.questions[self.index];
    
    //动态创建答案按钮
    [self createAnswerBtn:model];
    
    //动态创建待选区按钮
    [self createOptionBtn:model];
    
    //设置基本控件基本信息
    [self setUpBasicInfo:model];
}
-(void)createOptionBtn:(GKQuestion *)question
{
    [self.optionsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //获取当前答案的文字个数
    NSInteger len = question.options.count;
    //设置每个按钮相隔距离
    CGFloat margin = 15;
    CGFloat w = 40;
    CGFloat h = 40;
    //设置每行显示的个数
    int columns = 7;
    CGFloat marginLeft = (self.optionsView.frame.size.width-((columns*w)+(columns-1)*margin))/2;
    //循环创建答案n按钮
    for (int i=0; i<len; i++) {
        //创建按钮
        UIButton *btn = [[UIButton alloc]init];
        //设置普通状态按钮背景
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        //设置高亮状态按钮背景
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        
        int colIdx = i % columns;
        int rowIdx = i / columns;
        CGFloat x = marginLeft+colIdx*(w+margin);
        CGFloat y = 0+rowIdx*(h+margin);
        //设置按钮frame
        btn.frame = CGRectMake(x, y, w, h);
        
        [btn setTitle:question.options[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTag:i];
        
        //绑定单击事件
        [btn addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.optionsView addSubview:btn];
    }
}

-(void)optionButtonClick:(UIButton *)sender
{
    BOOL isFull = YES;
    //获取当前点击按钮的文字
    NSString *text = sender.currentTitle;
    //赋值点击按钮的文字到答案区
    for (UIButton *btn in self.answerView.subviews) {
        if (btn.currentTitle==nil) {
            [btn setTitle:text forState:UIControlStateNormal];
            [btn setTag:sender.tag];
            break;
        }
    }
    NSMutableString *answerStr = [NSMutableString string];
    for (UIButton *btn in self.answerView.subviews) {
        if (btn.currentTitle==nil) {
            isFull = NO;
        }
        else
        {
            [answerStr appendString:btn.currentTitle];
        }
    }
    //如果答案按钮被填满
    if (isFull) {
        //禁用待选区
        self.optionsView.userInteractionEnabled = NO;
        
        GKQuestion *model = self.questions[self.index];
        //比较答案是否正确
        if ([model.answer isEqualToString:answerStr]) {
            //如果答案正确 设置答案文字颜色为蓝色
            [self setAnswerTitleColor:[UIColor blueColor]];
            
            //加分数
            [self changeSore:100];
            
            //等待0.5秒进入下一题
            [self performSelector:@selector(nextClick) withObject:nil afterDelay:0.5];
        }else{
            //如果答案错误设置答案颜色为红色
            [self setAnswerTitleColor:[UIColor redColor]];
        }
    }
    sender.hidden = YES;
}

-(void)changeSore:(int)sore
{
    //取出当前分数
    int currentSore = self.btnCoin.currentTitle.intValue;
    
    currentSore += sore;
    
    [self.btnCoin setTitle:[NSString stringWithFormat:@"%D",currentSore] forState:UIControlStateNormal];
}


/// 设置答案按钮标题颜色
/// @param color 颜色
-(void)setAnswerTitleColor:(UIColor *)color
{
    for (UIButton *btn in self.answerView.subviews) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}

-(void)answerButtonClick:(UIButton *)sender
{
    //还原待选区文字并显示出来
    for (UIButton *btn in self.optionsView.subviews) {
        if (btn.tag == sender.tag) {
            btn.hidden = NO;
            break;
        }
    }
    
    //当前文字置nil
    [sender setTitle:nil forState:UIControlStateNormal];
    
    self.optionsView.userInteractionEnabled = YES;
    
    [self setAnswerTitleColor:[UIColor blackColor]];
}

-(void)createAnswerBtn:(GKQuestion *)question
{
    //清空当前view里面所有的按钮
    [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //获取当前答案的文字个数
    NSInteger len = question.answer.length;
    //设置每个按钮相隔距离
    CGFloat w = 40;
    CGFloat h = 40;
    CGFloat y = 0;
    CGFloat margin = 10;
    CGFloat marginLeft = (self.answerView.frame.size.width-((len*w)+(len-1)*margin))/2;
    //循环创建答案n按钮
    for (int i=0; i<len; i++) {
        //创建按钮
        UIButton *btn = [[UIButton alloc]init];
        //设置普通状态按钮背景
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        //设置高亮状态按钮背景
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        CGFloat x = marginLeft+i*(w+margin);
        //设置按钮frame
        btn.frame = CGRectMake(x, y, w, h);
        
        [self.answerView addSubview:btn];
        
        //为答案按钮注册单击事件
        [btn addTarget:self action:@selector(answerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

//放大图片
- (IBAction)btnBig {
    NSLog(@"点击大图按钮");
    [self changeImg];
    
    
}

//封面图片（变大/缩小）
-(void)changeImg{
    //判断当前按钮是否已经被放大
    if(self.conver.alpha==0.0)
    {
        //记录原来的frame值
        self.tempFrame = self.imgIcon.frame;
        //将图片按钮置顶
        [self.view bringSubviewToFront:self.imgIcon];
        
        //放大图片
        CGFloat imgIconW = self.view.frame.size.width;
        CGFloat imgIconH = imgIconW;
        CGFloat imgIconX = 0;
        CGFloat imgIconY = (self.view.frame.size.height-imgIconH)/2;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.imgIcon.frame = CGRectMake(imgIconX, imgIconY, imgIconH, imgIconW);
            self.conver.alpha = 1.0;
        }];
    }else
    {
        [UIView animateWithDuration:1.0 animations:^{
            self.imgIcon.frame = self.tempFrame;
            self.conver.alpha = 0.0;
        }];
        
    }
}


/// 设置控件基本信息
/// @param question 数据模型
-(void)setUpBasicInfo:(GKQuestion *)question
{
    self.lblTitle.text = question.title;
    self.lblNo.text = [NSString stringWithFormat:@"%d/%ld",self.index+1,self.questions.count];
    [self.imgIcon setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];
    
    //如果达到最后一题，禁用当前按钮
    self.btnNextLet.enabled = (self.index < self.questions.count - 1);
    
}
- (IBAction)promptBtnClick {
    // 把答题区中所有按钮清空
    for (UIButton *btn in self.answerView.subviews) {
        // 用代码点击答题按钮的操作
        [self answerButtonClick:btn];
    }
    GKQuestion *question = self.questions[self.index];
    NSString *first = [question.answer substringToIndex:1];
    
    UIButton *btn = [self optionButtonWithTitle:first isHidden:NO];
    
    [self optionButtonClick:btn];
    
    [self changeSore:-100];
}

-(UIButton *)optionButtonWithTitle:(NSString *)title isHidden:(BOOL) isHidden
{
    for (UIButton *btn in self.optionsView.subviews) {
        if ([btn.currentTitle isEqualToString:title] && btn.isHidden == isHidden) {
            return btn;
        }
    }
    return nil;
}
@end
