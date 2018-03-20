//
//  CycleScrollView.m
//  CycleScrollView
//
//  Created by YeYiFeng on 2018/3/20.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "CycleScrollView.h"
#import "CycleScrollViewCell.h"
#import "CycleScrollViewFlowLayout.h"
#import "UIImageView+WebCache.h"
#define SCREENWIDTH     [UIScreen mainScreen].bounds.size.width
@interface CycleScrollView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) CycleScrollViewFlowLayout *flowLayout;//瀑布流的参数配置
@property (nonatomic,strong) UICollectionView *collectionView;//创建collectionView
@property (nonatomic,strong) NSArray *imgArr;//图片数组
@property (nonatomic,assign) NSInteger totalItems;//item总数
@property (nonatomic,strong) NSTimer *timer;//定时器
@property (nonatomic,assign) NSUInteger currentpage;//当前页
@end
static NSString * const cellId = @"cellID";
@implementation CycleScrollView
{
    float _oldPoint;
    NSInteger _dragDirection;
}

+(instancetype)cycleScrollViewWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop imageGroups:(NSArray<NSString*>*)imageGroups;
{
    CycleScrollView * cycleScrollView = [[CycleScrollView alloc]initWithFrame:frame];
    cycleScrollView.infiniteLoop = infiniteLoop;
    cycleScrollView.imgArr = imageGroups;

    return cycleScrollView;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefault];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
    }
    return self;
}
#pragma mark - 初始化参数
-(void)initDefault
{
    
    _infiniteLoop = YES; //循环
    _autoScroll = YES;//自然滚动
    _isZoom = NO;// 缩放
    _itemWidth = self.bounds.size.width;//宽度
    _itemSpace = 0;// 间距
    _autoScrollTimeInterval = 2;//自然滚动的间隔
    _bannerImageViewContentMode = UIViewContentModeScaleAspectFill;//填充模式
}
-(void)layoutSubviews{
    
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height-30, self.bounds.size.width, 30);
    self.flowLayout.itemSize = CGSizeMake(_itemWidth, self.bounds.size.height);
    self.flowLayout.minimumLineSpacing = self.itemSpace;
    
    if(self.collectionView.contentOffset.x == 0 && _totalItems > 0)
    {
        NSInteger targeIndex = 0;
        if(self.infiniteLoop)
        {//无线循环
            // 如果是无限循环，应该默认把 collection 的 item 滑动到 中间位置。
            // 注意：此处 totalItems 的数值，其实是图片数组数量的 100 倍。
            // 乘以 0.5 ，正好是取得中间位置的 item 。图片也恰好是图片数组里面的第 0 个。
            targeIndex = _totalItems * 0.5;
        }else
        {
            targeIndex = 0;
        }
        //设置图片默认位置
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:targeIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        _oldPoint = self.collectionView.contentOffset.x;
    
}
}
// 滑动就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.collectionView.userInteractionEnabled = NO;
    if (!self.imgArr.count) return;
    self.pageControl.currentPage = [self currentIndex] % self.imgArr.count;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _oldPoint = scrollView.contentOffset.x;
    if (self.autoScroll) {
        [self invaliteTimer];
    }
}
// 停止拖拽 开始执行
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self openTimer];
    }
}
// 减速停止的时候开始执行
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.collectionView.userInteractionEnabled = YES;
    if (!self.imgArr.count) return; // 解决清除timer时偶尔会出现的问题
}
//手离开屏幕的时候
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //如果是向右滑或者滑动距离大于item的一半，则像右移动一个item+space的距离，反之向左
    float currentPoint = scrollView.contentOffset.x;
    float moveWidth = currentPoint-_oldPoint;
    int shouldPage = moveWidth/(self.itemWidth/2);
    if (velocity.x>0 || shouldPage > 0) {
        _dragDirection = 1;
    }else if (velocity.x<0 || shouldPage < 0){
        _dragDirection = -1;
    }else{
        _dragDirection = 0;
    }
}

- (void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView{
    //松开手指滑动开始减速的时候，设置滑动动画
    NSInteger currentIndex = (_oldPoint + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex + _dragDirection inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}
#pragma mark  - setter or getter
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView) {
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.frame = self.collectionView.frame;
        bgImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:bgImageView];
        [self insertSubview:bgImageView belowSubview:self.collectionView];
        self.backgroundImageView = bgImageView;
    }
    
    self.backgroundImageView.image = placeholderImage;
    
}
-(void)setItemWidth:(CGFloat)itemWidth
{
    _itemWidth = itemWidth;
    self.flowLayout.itemSize = CGSizeMake(itemWidth, self.bounds.size.height);
}
-(void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    self.flowLayout.minimumLineSpacing = itemSpace;
}
-(void)setIsZoom:(BOOL)isZoom
{
    _isZoom = isZoom;
    self.flowLayout.isZoom = isZoom;
}
-(void)setImgArr:(NSArray *)imgArr
{
    _imgArr = imgArr;
    self.pageControl.numberOfPages = imgArr.count;
    //如果循环则100倍，
    _totalItems = self.infiniteLoop?imgArr.count * 100:imgArr.count;
    if(_imgArr.count > 1)
    {
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    }else
    {
        //不循环
        self.collectionView.scrollEnabled = NO;
        [self invaliteTimer];
    }
    
    [self.collectionView reloadData];
    
}
-(void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    //创建之前，停止定时器
    [self invaliteTimer];
    
    if (_autoScroll) {
        [self openTimer];
    }
}
#pragma mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItems;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CycleScrollViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    long itemIndex = (int) indexPath.item % self.imgArr.count;
    NSString *imagePath = self.imgArr[itemIndex];
    
    if ([imagePath hasPrefix:@"http"]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.cellPlaceholderImage];
    } else {
        UIImage *image = [UIImage imageNamed:imagePath];
        if (!image) {
            [UIImage imageWithContentsOfFile:imagePath];
        }
        cell.imageView.image = image;
    }
    cell.imageView.contentMode = self.bannerImageViewContentMode;
    cell.imgCorneRadious = self.imgCornerRadius;
    
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    // 返回点击的视图和索引
    if ([self.delegate respondsToSelector:@selector(rebackScrollView:didSelectItemIndex:)]) {
        [self.delegate rebackScrollView:self didSelectItemIndex:[self currentIndex] % self.imgArr.count];
    }
}

#pragma mark - 定时器的操作
-(void)invaliteTimer
{
    [_timer invalidate];
    _timer = nil;
}
-(void)openTimer{
    [self invaliteTimer];
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timer = timer;
}
#pragma mark - 自然滚动
-(void)automaticScroll
{
    if (_totalItems == 0) {
        return;
    }
    NSInteger currentIndex = [self currentIndex];
    NSInteger targetIndex = currentIndex+1;//计算滑动到下一个索引
    [self scrollToIndex:targetIndex];
    
    
}
-(void)scrollToIndex:(NSInteger)index
{
    if (index>= _totalItems) {
        index = _totalItems * 0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        /*
         //水平布局时使用的  对应左中右
         UICollectionViewScrollPositionLeft                 = 1 << 3,
         UICollectionViewScrollPositionCenteredHorizontally = 1 << 4,
         UICollectionViewScrollPositionRight                = 1 << 5
         */
        return;
      
    }
     [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}
#pragma mark - 返回当前索引
-(NSInteger)currentIndex{
    
    if (self.collectionView.frame.size.width == 0 || self.collectionView.frame.size.height == 0)return 0;
    
    NSInteger index = 0;
    // 计算 = (滑动值 + (宽度+ 间距)/2)/(间距+宽度)
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {//水平滑动
        index = (self.collectionView.contentOffset.x + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    }else{// 垂直滑动
        index = (self.collectionView.contentOffset.y + _flowLayout.itemSize.height * 0.5)/ _flowLayout.itemSize.height;
    }
    return MAX(0,index);
    
}
#pragma mark - 懒加载属性
-(CycleScrollViewFlowLayout *)flowLayout
{
    if (_flowLayout == nil) {
        _flowLayout = [[CycleScrollViewFlowLayout alloc]init];
        _flowLayout.isZoom = self.isZoom;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0;
    }
    return _flowLayout;
}
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {

        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;//        scrollsToTop是UIScrollView的一个属性，主要用于点击设备的状态栏时，是scrollsToTop == YES的控件滚动返回至顶部。
        _collectionView.pagingEnabled = YES;//开启平移
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator =NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CycleScrollViewCell class] forCellWithReuseIdentifier:cellId];
    }
    return _collectionView;
}
- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        }
    return _pageControl;
}
@end
