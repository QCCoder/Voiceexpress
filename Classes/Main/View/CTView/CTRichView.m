//
//  CTRichView.m
//  
//
//  Created by Yaning Fan on 14-9-9.
//
//

#import "CTRichView.h"
#import "CTContentManager.h"

@interface CTRichView ()

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) CTContentManager  *manager;

@end

@implementation CTRichView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    self.manager = [[CTContentManager alloc] init];
    self.manager.xOffSet    = 15;
    self.manager.yOffSet    = 4.0;
    self.manager.lineSpace  = 8;
    self.manager.fontSize   = 18;
    self.manager.content    = @"";
    self.manager.viewWidth  = self.bounds.size.width;
}

- (NSString *)content
{
    return self.manager.content;
}

- (void)setContent:(NSString *)content
{
    self.manager.content = content;
    [self buildFrame];
}

- (CGFloat)fontSize
{
    return self.manager.fontSize;
}

- (void)setFontSize:(CGFloat)fontSize
{
    self.manager.fontSize = fontSize;
    [self.manager refreshCellHeigtList];
    [self.tableView reloadData];
}

- (CGFloat)lineSpace
{
    return self.manager.lineSpace;
}

- (void)setLineSpace:(CGFloat)lineSpace
{
    self.manager.lineSpace = lineSpace;
    [self.manager refreshCellHeigtList];
    [self.tableView reloadData];
}

- (CGFloat)xOffSet
{
    return self.manager.xOffSet;
}

- (void)setXOffSet:(CGFloat)xOffSet
{
    self.manager.xOffSet = xOffSet;
    [self.manager refreshCellHeigtList];
    [self.tableView reloadData];
}

- (CGFloat)yOffSet
{
    return self.manager.yOffSet;
}

- (void)setYOffSet:(CGFloat)yOffSet
{
    self.manager.yOffSet = yOffSet;
    [self.manager refreshCellHeigtList];
    [self.tableView reloadData];
}

- (void)setRichViewdelegate:(id<UIScrollViewDelegate>)richViewdelegate
{
    self.manager.richViewdelegate = richViewdelegate;
}

- (void)buildFrame
{
    [self.manager refreshCellHeigtList];
    [self refreshContent];
}

- (void)scrollToTop
{
    [self setContentOffset:CGPointZero];
}

- (CGPoint)contentOffset
{
    return self.tableView.contentOffset;
}

- (void)setContentOffset:(CGPoint)offset
{
     self.tableView.contentOffset = offset;
}

// 刷新界面
- (void)refreshContent
{
    if (self.tableView == nil)
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        self.tableView.frame = CGRectMake(0, 0, Main_Screen_Width, self.bounds.size.height);
        if (self.richViewBackgroundColor)
        {
            self.tableView.backgroundColor = self.richViewBackgroundColor;
        }
        else
        {
            self.tableView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    if (self.tableView.superview == nil)
    {
        self.tableView.delegate = self.manager;
        self.tableView.dataSource = self.manager;
        [self addSubview:self.tableView];
    }
    
    [self.tableView reloadData];
}

- (CGSize)contentSize
{
    return self.tableView.contentSize;
}

@end



