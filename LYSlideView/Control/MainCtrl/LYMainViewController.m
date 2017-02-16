//
//  LYMainViewController.m
//  LYSlideView
//
//  Created by MacBook on 2017/2/15.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import "LYMainViewController.h"
#import "UIButton+ImageTitleSpacing.h"

#import "ASRoomViewCell.h"
#import "LYAddViewController.h"
//屏幕宽和高
#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]


#define TAG_SCENES 10000
#define TAG_DEVICES 10001
@interface LYMainViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate>{
    UICollectionView *_roomCollectionView; //左右滑动
    NSArray *_groupArr;  //房间数组
    
    
    //向上滑，下部视图
    UIButton *_sceneBtn;
    UIView *_sceneView;
    UIView *_upView;
    UIView *_arrowSceneView;
    UIButton *_upViewBtn;
    UIView *_frameView;
    UITableView *_sceneTable;
    NSMutableArray *_showSceneArr;
    //向下滑，上部视图
    UIButton *_deviceBtn;
    UIView *_deviceView;
    UIView *_downView;
    
    UITableView *_deviceTable;
    NSArray *_typeArr;
    UIView *_arrowTypeView;
    //滑到哪一个房间
    NSInteger _currentIndex;
    
    NSMutableArray *_currentDeviceArr;
    UILabel *_upLineLb;
}
@property (nonatomic, strong) UIView *sceneHeaderView;
@end

@implementation LYMainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    //去掉透明后导航栏下边的黑边
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    如果不想让其他页面的导航栏变为透明 需要重置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWithView];
    [self initWithData];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //导航栏图标色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}]; //导航栏字体颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;  //纯黑色背景，白色文字
}

-(void)initWithData{
    _groupArr = @[
                 @{@"name":@"客厅",@"imageName":@"living_room_big"},
                 @{@"name":@"厨房",@"imageName":@"kitchen_big"},
                 @{@"name":@"卧室",@"imageName":@"bedroom_big"},
                 @{@"name":@"浴室",@"imageName":@"bathroom_big"},
                 @{@"name":@"餐厅",@"imageName":@"restaurant_big"},
                 @{@"name":@"厕所",@"imageName":@"toilet_big"},
                 @{@"name":@"办公室",@"imageName":@"office_big"},
                 @{@"name":@"走廊",@"imageName":@"hallway_big"}
                 ];
    _typeArr = @[
  @{@"name":@"Lights",@"imageName":@"light",@"deviceType":@"lamp"},
  @{@"name":@"Sensors",@"imageName":@"sensor",@"deviceType":@"sensor"},
  @{@"name":@"Lighting Remotes",@"imageName":@"light_remotes",@"deviceType":@"remote"},
                 ];
}


-(void)initWithView{
    //1.背景
    //背景大图
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imgView setImage:[UIImage imageNamed:@"main_background"]];
    [self.view addSubview:imgView];
    [imgView setContentMode:UIViewContentModeCenter]; //中心对齐
    imgView.clipsToBounds = YES;

    //加一层渐变色
    UIView *view = [[UIView alloc] initWithFrame:imgView.bounds];
    UIColor *colorOne = [UIColor colorWithRed:(253/255.0)  green:(190/255.0)  blue:(93/255.0)  alpha:0.85];
    UIColor *colorTwo = [UIColor colorWithRed:(255/255.0)  green:(150/255.0)  blue:(0/255.0)  alpha:0.85];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //设置开始和结束位置(设置渐变的方向)
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1,0.36);
    gradient.colors = colors;
    gradient.frame = view.frame;
    [view.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:view];
    
    //导航栏下横线
    _upLineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 0.5)];
    _upLineLb.backgroundColor = [UIColor whiteColor];
    _upLineLb.alpha = 0;
    [self.view addSubview:_upLineLb];
    //tabbar上横线
    UILabel *downLineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT -49.5, SCREEN_WIDTH, 0.5)];
    downLineLb.backgroundColor = [UIColor whiteColor];
    downLineLb.alpha = 0.5;
    [self.view addSubview:downLineLb];

    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"add_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(addBtnAction) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //房间外围白色边框
    _frameView = [[UIView alloc] initWithFrame:CGRectMake(55,64 + 55, SCREEN_WIDTH-110, SCREEN_HEIGHT-110-49-64)];
    [self.view addSubview:_frameView];
    _frameView.layer.cornerRadius = 30;
    _frameView.layer.borderWidth = 0.5;
    _frameView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //向上滑动指示箭头按钮
    UIButton *frameUpBtn = [[UIButton alloc] initWithFrame:CGRectMake((_frameView.frame.size.width - 100)/2,(_frameView.frame.size.height - 125)/2-100, 100, 100)];
    [_frameView addSubview:frameUpBtn];
    [frameUpBtn setTitle:@"Scenes" forState:UIControlStateNormal];
    [frameUpBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    CGFloat space = 80.0;
    [frameUpBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop
                                imageTitleSpace:space];
    [frameUpBtn addTarget:self action:@selector(showDownView) forControlEvents:UIControlEventTouchUpInside];
    //向下滑动指示箭头按钮
    UIButton *frameDownBtn = [[UIButton alloc] initWithFrame:CGRectMake((_frameView.frame.size.width - 100)/2,(_frameView.frame.size.height - 125)/2 + 125, 100, 100)];
    [_frameView addSubview:frameDownBtn];
    [frameDownBtn setTitle:@"Type" forState:UIControlStateNormal];
    [frameDownBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [frameDownBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleBottom imageTitleSpace:space];
    [frameDownBtn addTarget:self action:@selector(showUpView) forControlEvents:UIControlEventTouchUpInside];
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //该方法也可以设置itemSize
    layout.itemSize =CGSizeMake(_frameView.frame.size.width,145);
    
    //2.初始化collectionView
    _roomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,(_frameView.frame.size.height - 145)/2,_frameView.frame.size.width,145) collectionViewLayout:layout];
    [_frameView addSubview:_roomCollectionView];
    
    _roomCollectionView.delegate = self;
    _roomCollectionView.dataSource =self;
    _roomCollectionView.showsHorizontalScrollIndicator = NO;
    _roomCollectionView.pagingEnabled = YES;
    [_roomCollectionView registerClass:[ASRoomViewCell class] forCellWithReuseIdentifier:@"roomsCell"];
    _roomCollectionView.backgroundColor = [UIColor clearColor];
    
    //--upview 向下滑动 显示deviceView
    UISwipeGestureRecognizer *SwipeUpView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showUpView)];
    [SwipeUpView setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:SwipeUpView];
    
    //deviceView在视图的上方
    _deviceView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGHT,SCREEN_WIDTH,SCREEN_HEIGHT - 49 - 64)];
    [self.view addSubview:_deviceView];
    
    //向上滑动 隐藏刚刚显示的deviceView
    UISwipeGestureRecognizer *swipeSceneView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenUpView)];
    [swipeSceneView setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_deviceView addGestureRecognizer:swipeSceneView];
    
    //--- 隐藏deviceView的按钮 --- begin
    //下方按钮白色背景
    _arrowTypeView = [[UIView alloc] initWithFrame:CGRectMake((_deviceView.frame.size.width-120)/2,_deviceView.frame.size.height- 70,120, 70)];
    [_deviceView addSubview:_arrowTypeView];
    _arrowTypeView.alpha = 0;
    UIImageView *arrowTypeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, _arrowTypeView.frame.size.width,_arrowTypeView.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@"type_btn_bg"];
    UIEdgeInsets insets = UIEdgeInsetsMake(30, 30, 0, 30);
    // 指定为拉伸模式，伸缩后重新赋值
    bgImg = [bgImg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [arrowTypeImgV setImage:bgImg];
    [_arrowTypeView addSubview:arrowTypeImgV];
    //向上的箭头
    UIImageView *arrowUpImgV = [[UIImageView alloc] initWithFrame:CGRectMake((120-50/2)/2,10, 50/2, 35/2)];
    arrowUpImgV.image = [UIImage imageNamed:@"arrow_up_yellow"];
    [_arrowTypeView addSubview:arrowUpImgV];
    //rooms label
    UILabel *arrowTypeLb = [[UILabel alloc] initWithFrame:CGRectMake(0,70 - 30,120,20)];
    [_arrowTypeView addSubview:arrowTypeLb];
    [arrowTypeLb setTextColor:UIColorFromRGB(0xffad2c)];
    [arrowTypeLb setTextAlignment:NSTextAlignmentCenter];
    [arrowTypeLb setText:@"Room"];
    
    UIButton *downViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,_arrowTypeView.frame.size.width,_arrowTypeView.frame.size.height)];
    [_arrowTypeView addSubview:downViewBtn];
    [downViewBtn addTarget:self action:@selector(hiddenUpView) forControlEvents:UIControlEventTouchUpInside];
    //--- 隐藏deviceView的按钮 --- end
    
    //deviceView中的设备类型列表
    _deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(30,30, _deviceView.frame.size.width - 60, _deviceView.frame.size.height - (90-30 + 30)-40) style:UITableViewStylePlain];
    [_deviceTable setTag:TAG_DEVICES];
    [_deviceView addSubview:_deviceTable];
    _deviceTable.alpha = 0.1;
    _deviceTable.layer.cornerRadius = 30;
    [_deviceTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
    [_deviceTable setBackgroundColor:[UIColor whiteColor]];
    _deviceTable.tableFooterView = [[UIView alloc] init];
    _deviceTable.contentInset = UIEdgeInsetsMake(18,0,18,0);
    
    //----- ********** -----
    //向上滑动 显示sceneView
    UISwipeGestureRecognizer *SwipeDownView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDownView)];
    [SwipeDownView setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:SwipeDownView];
    _sceneView = [[UIView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-49-64)];
    [self.view addSubview:_sceneView];
    //向下滑动 隐藏已经显示的sceneView
    UISwipeGestureRecognizer *swipeDeviceView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenDownView)];
    [swipeDeviceView setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [_sceneView addGestureRecognizer:swipeDeviceView];
    
    //sceneView中的场景列表
    _sceneTable = [[UITableView alloc] initWithFrame:CGRectMake(30,90 - 30 + 40 , _sceneView.frame.size.width - 60, _sceneView.frame.size.height - (90-30 + 30)-40) style:UITableViewStylePlain];
    [_sceneTable setTag:TAG_SCENES];
    [_sceneView addSubview:_sceneTable];
    _sceneTable.alpha = 0.1;
    _sceneTable.layer.cornerRadius = 30;
    [_sceneTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _sceneTable.delegate = self;
    _sceneTable.dataSource = self;
    _sceneTable.tableHeaderView = [self sceneHeaderView];
    _sceneTable.tableFooterView = [[UIView alloc] init];
    [_sceneTable setBackgroundColor:[UIColor whiteColor]];
    _sceneTable.contentInset = UIEdgeInsetsMake(18,0,18,0);
    
    //-sceneView-- 隐藏sceneView的按钮 --- begin
    _arrowSceneView = [[UIView alloc] initWithFrame:CGRectMake((_sceneView.frame.size.width-120)/2,0,120, 70)];
    [_sceneView addSubview:_arrowSceneView];
    _arrowSceneView.alpha = 0;
    //    _arrowSceneView.layer.cornerRadius = 30;
    //    _arrowSceneView.backgroundColor = [UIColor whiteColor];
    UIImageView *arrowSceneImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, _arrowSceneView.frame.size.width,_arrowSceneView.frame.size.height)];
    UIImage *sceneBgImg = [UIImage imageNamed:@"scene_btn_bg"];
    UIEdgeInsets sceneInsets = UIEdgeInsetsMake(0, 30, 30, 30);
    // 指定为拉伸模式，伸缩后重新赋值
    sceneBgImg = [sceneBgImg resizableImageWithCapInsets:sceneInsets resizingMode:UIImageResizingModeStretch];
    [arrowSceneImgV setImage:sceneBgImg];
    [_arrowSceneView addSubview:arrowSceneImgV];
    //向下的箭头
    UIImageView *arrowDownImgV = [[UIImageView alloc] initWithFrame:CGRectMake((120-50/2)/2,70 - 10 -  35/2, 50/2, 35/2)];
    arrowDownImgV.image = [UIImage imageNamed:@"arrow_down_yellow"];
    [_arrowSceneView addSubview:arrowDownImgV];
    //rooms label
    UILabel *arrowLb = [[UILabel alloc] initWithFrame:CGRectMake(0,70 - 10 -  35/2 -10- 20,120,20)];
    [_arrowSceneView addSubview:arrowLb];
    [arrowLb setTextColor:UIColorFromRGB(0xffad2c)];
    [arrowLb setTextAlignment:NSTextAlignmentCenter];
    [arrowLb setText:@"Room"];
    
    UIButton *upViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,_arrowSceneView.frame.size.width,_arrowSceneView.frame.size.height)];
    [_arrowSceneView addSubview:upViewBtn];
    [upViewBtn addTarget:self action:@selector(hiddenDownView) forControlEvents:UIControlEventTouchUpInside];
    //-sceneView-- 隐藏sceneView的按钮 --- end
}

- (UIView *)sceneHeaderView
{
    CGFloat imgWidth = _sceneView.frame.size.width - 80*2;
    CGFloat imgHeight = imgWidth * 391 /467 ;
    if (_sceneHeaderView == nil)
    {
        _sceneHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _sceneView.frame.size.width, 80 + imgHeight + 60 + 44)];
        UIImageView *noSceneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 80, imgWidth, imgHeight)];
        [noSceneImgView setImage:[UIImage imageNamed:@"scene_table_header"]];
        [_sceneHeaderView addSubview:noSceneImgView];
        
        UIButton *nowAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 80 + imgHeight + 30, imgWidth, 44)];
        [nowAddBtn.layer setCornerRadius:22];
        [nowAddBtn setBackgroundColor:UIColorFromRGB(0Xffad2c)];
        [nowAddBtn.layer setBorderWidth:0.5];
        [nowAddBtn.layer setBorderColor:[UIColorFromRGB(0Xe49d27) CGColor]];
        [_sceneHeaderView addSubview:nowAddBtn];

        [nowAddBtn setTitle:NSLocalizedString(@"+ Add Scenes", nil) forState:UIControlStateNormal];
        [nowAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nowAddBtn addTarget:self action:@selector(addSceneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _sceneHeaderView;
}

#pragma mark - UIViewAnimation
-(void)showUpView{
    
    [UIView animateWithDuration:0.5 animations:^{
        _deviceView.frame = CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 64);
        _deviceTable.alpha = 0.8;
        
        _frameView.frame = CGRectMake(55, SCREEN_HEIGHT + 55, SCREEN_WIDTH-110, SCREEN_HEIGHT-110-49-64);
        _arrowTypeView.alpha = 0.8;
        _upLineLb.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hiddenUpView{
    [UIView animateWithDuration:0.5 animations:^{
        _deviceView.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        _deviceTable.alpha = 0.1;
        _frameView.frame = CGRectMake(55, 55 + 64, SCREEN_WIDTH-110, SCREEN_HEIGHT-110-49-64);
        _arrowTypeView.alpha = 0;
        _upLineLb.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)showDownView{
    
    [UIView animateWithDuration:0.5 animations:^{
        _sceneView.frame = CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 64);
        _sceneTable.alpha = 0.8;
        
        _frameView.frame = CGRectMake(55, - (SCREEN_HEIGHT-110-49-64) - 55-64, SCREEN_WIDTH-110, SCREEN_HEIGHT-110-49-64);
        _arrowSceneView.alpha = 0.8;
        _upLineLb.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hiddenDownView{
    [UIView animateWithDuration:0.5 animations:^{
        _sceneView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        _sceneTable.alpha = 0.1;
        _frameView.frame = CGRectMake(55, 55 + 64, SCREEN_WIDTH-110, SCREEN_HEIGHT-110-49-64);
        _arrowSceneView.alpha = 0;
        _upLineLb.alpha = 0;
    } completion:^(BOOL finished) {

    }];
}










#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _groupArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString static *identifier = @"roomsCell";
    ASRoomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (!cell) {
        NSLog(@"-----------------");
    }
    for (NSUInteger i = 0; i< _groupArr.count; i++) {
        if (indexPath.row == i) {
            cell.homeNameLb.text = [_groupArr[i] objectForKey:@"name"];
            [cell.homeTypeImgView setImage:[UIImage imageNamed:[_groupArr[i] objectForKey:@"imageName"]]];
        }
    }
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return (CGSize){_frameView.frame.size.width,_frameView.frame.size.height};
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

#pragma mark ---- UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == TAG_DEVICES) {
        return [_typeArr count];
    }else if (tableView.tag == TAG_SCENES) {
        return 0;
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView.tag == TAG_DEVICES) {
        NSString static *identifier = @"deviceCell";
        UITableViewCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!deviceCell) {
            deviceCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            deviceCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        deviceCell.textLabel.text = [_typeArr[indexPath.row] objectForKey:@"name"];
        deviceCell.imageView.image= [UIImage imageNamed:[_typeArr[indexPath.row] objectForKey:@"imageName"]];
        return deviceCell;
    }else if (tableView.tag == TAG_SCENES) {
        NSString static *identifier = @"sceneCell";
        UITableViewCell *sceneCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!sceneCell) {
            sceneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        return sceneCell;
    }else{
        return nil;
    }
    
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView.tag == TAG_SCENES) {

    }else{
       [self pushAddView];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

#pragma mark - buttonAction
-(void)addBtnAction{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加场景", @"新建房间", nil];
    [myActionSheet showInView:self.view];
}

-(void)addSceneBtnAction{
    [self pushAddView];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { //room
        [self pushAddView];
    }else if (buttonIndex == 1){  //scene
        [self pushAddView];
    }
    
}


#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    _currentIndex = round(offset.x / scrollView.frame.size.width);

    self.title = [[_groupArr objectAtIndex:_currentIndex] objectForKey:@"name"];
}

-(void)pushAddView{
    LYAddViewController *addCtrl = [[LYAddViewController alloc]init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:addCtrl animated:NO];
    [self setHidesBottomBarWhenPushed:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
