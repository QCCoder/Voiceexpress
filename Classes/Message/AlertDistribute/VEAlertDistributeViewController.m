//
//  VEAlertDistributeViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-12-23.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAlertDistributeViewController.h"
#import "VEImageDetailViewController.h"
#import "VEContactViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+fixOrientation.h"
#import "VEContactViewController.h"
#import "VENTokenField.h"
#import "ZLPhoto.h"
#import "VEGroupListViewController.h"

static const NSInteger k3MImageDataSize = 3 * 1024 * 1024;
extern       NSString  *sessionToken;
static const NSInteger kColumnTypeActionSheetTag = 170;
static const NSInteger kAddImageActionSheetTag   = 171;
static const NSInteger kLoadWarnningTypeListTag = 172;
static const NSInteger kMaxCountsofImages        = 5;

static NSString * const kUploadImageCache       = @"UploadImageCache";
static NSString * const kOriginalImageURLKey    = @"VEOriginalImageURL";
static NSString * const kThumbImageURLKey       = @"VEThumbImageURL";
static NSString * const kImageNameKey           = @"VEImageName";
static NSString * const kShouldUploadKey        = @"VEShouldUpload";

BOOL VEAlertDistributeViewSuccessDistribute = NO;
extern BOOL backFromVEContactVC;

@interface VEAlertDistributeViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VENTokenFieldDelegate, VENTokenFieldDataSource, UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView              *scrollView;
@property (weak, nonatomic) IBOutlet UITextField               *textFieldAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel                   *labelType;
@property (weak, nonatomic) IBOutlet VENTokenField             *tokenField;
@property (weak, nonatomic) IBOutlet UILabel                   *labelWarnningType;

@property (weak, nonatomic) IBOutlet UITextView                *contentTextView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UILabel                   *lableTip;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UIButton                  *addImageBtn;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIButton *selectGroupBtn;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray       *imageViewCollection;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray          *removeImageBtnCollection;

@property (nonatomic, strong) FYNHttpRequestLoader  *httpRequestContactsListLoader;
@property (nonatomic, strong) FYNHttpRequestLoader  *httpRequestImageLoader;
@property (nonatomic, strong) FYNHttpRequestLoader  *httpRequestDistributeLoader;

@property (nonatomic, strong) NSMutableArray        *readyToUploadImageList;
@property (nonatomic, strong) NSMutableArray        *uploadedImageNameList;

@property (nonatomic, strong) NSMutableArray        *checkedContactsList;

@property(nonatomic,strong )  NSMutableArray        *warnningTypeList;

@property (nonatomic, strong) NSMutableArray        *checkedGroupsList;
@property (nonatomic, strong) NSMutableArray        *checkedCommonGroupsList;
@property (nonatomic, strong) NSMutableArray        *checkedCustomGroupsList;

@property (nonatomic, strong) UIActionSheet         *addImageActionSheet;
@property (nonatomic, strong) UIActionSheet         *columnTypeActionSheet;
@property(nonatomic,strong ) UIActionSheet          *loadWarnningTypeActionSheet;

@property (nonatomic, copy)   NSString              *uploadImageDiskCachePath;
@property (nonatomic, assign) BOOL                  isAlreadySuccesToUploadPictures;
@property (nonatomic, assign) IntelligenceColumnType    comeFromColumnType;

@property (nonatomic, strong) NSMutableArray        *filteredContactsList;
@property (nonatomic, strong) NSMutableArray        *contactsList;
@property (nonatomic, strong) UITableView           *filterTableView;
@property (nonatomic, strong) NSMutableArray        *localWarnningTypeList;
@property (weak, nonatomic) IBOutlet UIView *photosView;

- (IBAction)addImage:(UIButton *)sender;
- (IBAction)removeImageFromImageCollection:(UIButton *)sender;
- (IBAction)editContact:(UIButton *)sender;
- (IBAction)editType:(UIButton *)sender;
- (IBAction)distributeAlert:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *warnLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *warnTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn1;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn2;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn3;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn4;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn5;

@end

@implementation VEAlertDistributeViewController

-(NSMutableArray *)warnningTypeList{
    if (_warnningTypeList == nil) {
        _warnningTypeList = [[NSMutableArray alloc] init];
    }
    return _warnningTypeList;
}
-(NSMutableArray *)localWarnningTypeList{
    if (_localWarnningTypeList) {
        _localWarnningTypeList = [NSMutableArray array];
    }
    return _localWarnningTypeList;
}

- (NSMutableArray *)readyToUploadImageList
{
    if (_readyToUploadImageList == nil)
    {
        _readyToUploadImageList = [[NSMutableArray alloc] init];
    }
    return _readyToUploadImageList;
}

- (NSMutableArray *)uploadedImageNameList
{
    if (_uploadedImageNameList == nil)
    {
        _uploadedImageNameList = [[NSMutableArray alloc] init];
    }
    return _uploadedImageNameList;
}

- (NSMutableArray *)checkedContactsList
{
    if (_checkedContactsList == nil)
    {
        _checkedContactsList = [[NSMutableArray alloc] init];
    }
    return _checkedContactsList;
}

- (NSMutableArray *)checkedGroupsList
{
    if (_checkedGroupsList == nil)
    {
        _checkedGroupsList = [[NSMutableArray alloc] init];
    }
    return _checkedGroupsList;
}

- (NSMutableArray *)checkedCommonGroupsList
{
    if (_checkedCommonGroupsList == nil)
    {
        _checkedCommonGroupsList = [[NSMutableArray alloc] init];
    }
    return _checkedCommonGroupsList;
}

- (NSMutableArray *)checkedCustomGroupsList
{
    if (_checkedCustomGroupsList == nil)
    {
        _checkedCustomGroupsList = [[NSMutableArray alloc] init];
    }
    return _checkedCustomGroupsList;
}


- (void)dealloc
{
    @autoreleasepool {
        [self.httpRequestDistributeLoader cancelAsynRequest];
        self.httpRequestDistributeLoader = nil;
        
        [self.httpRequestImageLoader cancelAsynRequest];
        self.httpRequestImageLoader = nil;
        
        if (_readyToUploadImageList)
        {
            [self.readyToUploadImageList removeAllObjects];
            self.readyToUploadImageList = nil;
        }
        
        if (_uploadedImageNameList)
        {
            [self.uploadedImageNameList removeAllObjects];
            self.uploadedImageNameList = nil;
        }
        
        if (_checkedContactsList)
        {
            [self.checkedContactsList removeAllObjects];
            self.checkedContactsList = nil;
        }
        
        if (_checkedGroupsList)
        {
            [self.checkedGroupsList removeAllObjects];
            self.checkedGroupsList = nil;
        }
        
        if (_checkedCommonGroupsList)
        {
            [self.checkedCommonGroupsList removeAllObjects];
            self.checkedCommonGroupsList = nil;
        }
        
        if (_checkedCustomGroupsList)
        {
            [self.checkedCustomGroupsList removeAllObjects];
            self.checkedCustomGroupsList = nil;
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
        
        // 清理联系人
        [VEContactViewController clearContactList];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithWarnningTypeAgent:(WarnningTypeAgent *)agent{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _warnningTypeAgent = agent;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self reload];
    self.contentTextView.textContainer.lineFragmentPadding = 5;
    
    self.scrollView.contentSize = CGSizeMake(0, self.view.height + 5);
    _contentTextView.height = 200;
    
    [self loadLocalWarnningTypeList];
    
    [self setUp];
    [self loadContactsList];
    [self loadWarnningTypeList];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _deleteBtn1.ve_height = _deleteBtn1.ve_width = 20;
    _deleteBtn2.ve_height = _deleteBtn2.ve_width = 20;
    _deleteBtn3.ve_height = _deleteBtn3.ve_width = 20;
    _deleteBtn4.ve_height = _deleteBtn4.ve_width = 20;
    _deleteBtn5.ve_height = _deleteBtn5.ve_width = 20;
    
    
    
    UIImageView *imageView1 = _imageViewCollection[0];
    imageView1.ve_height = 60;
    
    _deleteBtn1.center = CGPointMake(CGRectGetMaxX(imageView1.frame) - 6, 17);
    
    
    UIImageView *imageView2 = _imageViewCollection[1];
    imageView2.ve_y = imageView1.ve_y;
    imageView1.ve_height = 60;
    _deleteBtn2.center = CGPointMake(CGRectGetMaxX(imageView2.frame) - 6, 17);
    
    
    UIImageView *imageView3 = _imageViewCollection[2];
    _deleteBtn3.center = CGPointMake(CGRectGetMaxX(imageView3.frame) - 6, 90);
    
    
    UIImageView *imageView4 = _imageViewCollection[3];
    _deleteBtn4.center = CGPointMake(CGRectGetMaxX(imageView4.frame) - 6, 90);
    
    
    UIImageView *imageView5 = _imageViewCollection[4];
    _deleteBtn5.center = CGPointMake(CGRectGetMaxX(imageView5.frame) - 6, 90);
}

-(void)reload{
    _warnLevelLabel.text = self.config[WarnLevel];
    _contentLabel.text = self.config[WarnContent];
    _imageLabel.text = self.config[WarnImage];
    _titleLabel.text = self.config[WarnTitle];
    _warnTypeLabel.text = self.config[WarnType];
    [_selectGroupBtn setImage:[QCZipImageTool imageNamed:self.config[Icon_Group_Add]] forState:UIControlStateNormal];
    [_addImageBtn setImage:[QCZipImageTool imageNamed:self.config[Icon_Image_Add]] forState:UIControlStateNormal];
    [_deleteBtn1 setImage:[QCZipImageTool imageNamed:self.config[Icon_Delete]] forState:UIControlStateNormal];
    [_deleteBtn2 setImage:[QCZipImageTool imageNamed:self.config[Icon_Delete]] forState:UIControlStateNormal];
    [_deleteBtn3 setImage:[QCZipImageTool imageNamed:self.config[Icon_Delete]] forState:UIControlStateNormal];
    [_deleteBtn4 setImage:[QCZipImageTool imageNamed:self.config[Icon_Delete]] forState:UIControlStateNormal];
    [_deleteBtn5 setImage:[QCZipImageTool imageNamed:self.config[Icon_Delete]] forState:UIControlStateNormal];
}

- (void)initTokenField:(VENTokenField *)tokenField
{
    self.tokenField.delegate = self;
    self.tokenField.toLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.tokenField.toLabelTextColor = readFontColor;
    self.tokenField.dataSource = self;
    self.tokenField.toLabelText = self.config[Recriver];
    [self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.tokenField.maxHeight = 5000;
    self.tokenField.minInputWidth = 50;
}

- (void)setUp
{
    self.promptView.layer.cornerRadius = 5.0;
    [self initTokenField:self.tokenField];
    VEAlertDistributeViewSuccessDistribute = NO;
    
    // 添加手势
    for (UIImageView *singleImageView in self.imageViewCollection)
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(imageViewTapped:)];
        
        [singleImageView addGestureRecognizer:tapGestureRecognizer];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(editType:)];
    
    [self.labelType addGestureRecognizer:tapGestureRecognizer2];
    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(toggleWarnningType:)];
    
    [self.labelWarnningType addGestureRecognizer:tapGestureRecognizer3];
    
    // 情报类型
    NSString *typeName = nil;
    self.comeFromColumnType = self.columnType;
    switch (self.columnType)
    {
        case IntelligenceColumnInstant:
            typeName = self.config[IntelligenceInstant];
            break;
            
        case IntelligenceColumnDaily:
            typeName = self.config[IntelligenceDaily];
            break;
            
        case IntelligenceColumnInternational:
            typeName = self.config[IntelligenceInternational];
            break;
            
        default:
            self.columnType = IntelligenceColumnInstant;
            typeName = self.config[IntelligenceInstant];
            break;
    }
    self.labelType.text = typeName;
    
    // 来自转发
    [self setUpForward];
    
    [self setupNav];
}
-(void)setupNav{
    [self setTitle:self.config[WarnAlert]];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(distributeAlert:) image:Config(Tab_Icon_Ok) highImage:nil];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goBack) image:Config(Tab_Icon_Back) highImage:nil];
}

- (void)setUpForward
{
    if (self.forwardAgent)
    {
        // 标题
        self.textFieldAlertTitle.text = (self.forwardAgent.title.length ? self.forwardAgent.title : @"");
        
        // 内容
        NSString * needUploadImage = @"1";
        if (self.forwardFromType == ForwardFromIntelligenceAlert ||
            self.forwardFromType == ForwardFromInternet)
        {
            needUploadImage = @"1";
            self.contentTextView.text = (self.forwardArticleContent.length ? self.forwardArticleContent : @"");
        }
        else if (self.forwardFromType == ForwardFromWarnAlert)
        {
            self.contentTextView.text = [self forwardContentFromWarnAlert];
        }
        
        // 是否有无图片
        // 来自［情报交互］的转发，图片无需再次上传；
        // 来自其它的转发，图片需上传至服务端
        NSMutableArray *imageUrls = [NSMutableArray array];
        [imageUrls addObjectsFromArray:self.forwardImageUrls];
        
        if ([self.forwardAgent respondsToSelector:@selector(imageUrls)])
        {
            NSArray *tempImageUrls = [self.forwardAgent performSelector:@selector(imageUrls)];
            [imageUrls addObjectsFromArray:tempImageUrls];
        }
        
        if (imageUrls.count > 0)
        {
            NSInteger index = 0;
            NSInteger imageViewCounts = [self.imageViewCollection count];
            
            for (NSString *singleURL in imageUrls)
            {
                if (singleURL.length > 0)
                {
                    if (index < imageViewCounts)
                    {
                        NSString *thumbImgURL = nil;
                        NSString *imageName = @"";
                        NSArray *listItems = [singleURL componentsSeparatedByString:@"name="];
                        
                        if (listItems.count == 2)
                        {
                            imageName = [listItems lastObject];
                            imageName = [imageName stringByReplacingOccurrencesOfString:@"-big" withString:@""];
                        }
                        
                        thumbImgURL = [singleURL stringByReplacingOccurrencesOfString:@"-big" withString:@""];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             singleURL, kOriginalImageURLKey,
                                             needUploadImage, kShouldUploadKey,
                                             imageName, kImageNameKey, nil];
                        
                        [self.readyToUploadImageList addObject:dic];
                        
                        UIImageView *imageView = [self.imageViewCollection objectAtIndex:index];
                        [imageView imageWithUrlStr:thumbImgURL phImage:Image(Icon_Picture_Min)];
                        imageView.hidden = NO;
                        ((UIButton *)[self.removeImageBtnCollection objectAtIndex:index]).hidden = NO;
                        
                        ++index;
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }
}

// 组构来自预警转发的内容

- (NSString *)forwardContentFromWarnAlert
{
    NSString *content = @"";
    if (self.forwardAgent)
    {
        content = @"\n-------------原文-------------\n";
        if ([self.forwardAgent respondsToSelector:@selector(author)])
        {
            NSString *author = [self.forwardAgent performSelector:@selector(author)];
            if (author.length > 0)
            {
                content = [content stringByAppendingFormat:@"作者：%@\n",author];
            }
        }
        
        if ([self.forwardAgent respondsToSelector:@selector(site)])
        {
            NSString *site = [self.forwardAgent performSelector:@selector(site)];
            if (site.length > 0)
            {
                content = [content stringByAppendingFormat:@"来源：%@\n", site];
            }
        }
        
        if (self.forwardAgent.timePost.length > 0)
        {
            content = [content stringByAppendingFormat:@"发文时间：%@\n", self.forwardAgent.timePost];
        }
        
        if ([self.forwardAgent respondsToSelector:@selector(url)])
        {
            NSString *webURL = [self.forwardAgent performSelector:@selector(url)];
            if (webURL.length > 0)
            {
                content = [content stringByAppendingFormat:@"原文链接：%@\n", webURL];
            }
        }
        
        if (self.forwardArticleContent.length > 0)
        {
            content = [content stringByAppendingFormat:@"内容：%@", self.forwardArticleContent];
        }
    }
    
    return content;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setContentTextView:nil];
    [self setImageViewCollection:nil];
    [self setRemoveImageBtnCollection:nil];
    [self setTextFieldAlertTitle:nil];
    [self setPromptView:nil];
    [self setLableTip:nil];
    [self setIndicator:nil];
    [self setLabelType:nil];
    [self setAddImageBtn:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (backFromVEContactVC)
    {
        backFromVEContactVC = NO;
        [self.tokenField reloadData];
        [self layoutTokenField];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
}

- (void)cancelAllHttpRequester
{
    if (_httpRequestImageLoader)
    {
        [self.httpRequestImageLoader cancelAsynRequest];
    }
    if (_httpRequestDistributeLoader)
    {
        [self.httpRequestDistributeLoader cancelAsynRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    
    // 清理缓存的图片
    [self clearUploadImageCaches];
}

// 添加图片

- (IBAction)addImage:(UIButton *)sender
{
    [self.textFieldAlertTitle resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    [self tokenFieldResignResponser];
    
    if ([self currentNumberofAddedImage] >= kMaxCountsofImages)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"至多支持添加%ld张图片", (long)kMaxCountsofImages]
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        if (self.addImageActionSheet == nil)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"拍照", @"相册", nil];
            actionSheet.tag = kAddImageActionSheetTag;
            self.addImageActionSheet = actionSheet;
        }
        [self.addImageActionSheet showInView:self.view];
    }
}

// 移除当前图片

- (IBAction)removeImageFromImageCollection:(UIButton *)sender
{
    @autoreleasepool {
        NSInteger tag = sender.tag;
        if (tag >= 1000  && tag < (1000 + kMaxCountsofImages))
        {
            NSInteger index = (tag - 1000);
            sender.hidden = YES;
            
            UIImageView *imageView = (UIImageView *)[self.imageViewCollection objectAtIndex:index];
            imageView.hidden = YES;
            imageView.image = nil;
            
            if (index >= 0 && index < self.readyToUploadImageList.count)
            {
                [self.readyToUploadImageList removeObjectAtIndex:index];
            }
            
            for (int i = (int)index; i < (kMaxCountsofImages - 1); ++i)
            {
                UIImageView *curentImageView = (UIImageView *)[self.imageViewCollection objectAtIndex:i];
                UIImageView *nextImageView   = (UIImageView *)[self.imageViewCollection objectAtIndex:(i + 1)];
                
                UIButton *currentRemoveBtn = (UIButton *)[self.removeImageBtnCollection objectAtIndex:i];
                UIButton *nextRemoveBtn    = (UIButton *)[self.removeImageBtnCollection objectAtIndex:(i + 1)];
                
                if (nextImageView.image == nil)
                {
                    break;
                }
                else
                {
                    curentImageView.image = nil;
                    curentImageView.image = nextImageView.image;
                    curentImageView.hidden = NO;
                    currentRemoveBtn.hidden = NO;
                    
                    nextImageView.image = nil;
                    nextImageView.hidden = YES;
                    nextRemoveBtn.hidden = YES;
                }
            }
        }
    }
}

// 选择收信人

- (IBAction)editContact:(UIButton *)sender
{
    [self.textFieldAlertTitle resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    [self.tokenField resignFirstResponder];
    [self removeFilterTableView];
    
    backFromVEContactVC = NO;
    VEContactViewController *contactViewController = [[VEContactViewController alloc]
                                                      initWithNibName:@"VEContactViewController" bundle:nil];
    
    contactViewController.checkedContactsList       = self.checkedContactsList;
    contactViewController.checkedAllGroupsList      = self.checkedGroupsList;         // 所有联系人
    contactViewController.checkedCommonGroupsList   = self.checkedCommonGroupsList;   // 常用联系人
    contactViewController.checkedCustomGroupsList   = self.checkedCustomGroupsList;   // 自定义分组

//    VEGroupListViewController *contactViewController = [[VEGroupListViewController alloc]init];
    [self.navigationController pushViewController:contactViewController animated:YES];
}

// 选择类型

- (IBAction)editType:(UIButton *)sender
{
    [self tokenFieldResignResponser];
    [UIView animateWithDuration:0.7 animations:^{
        self.scrollView.contentOffsetY = 0;
    }];
    
    if (self.columnTypeActionSheet == nil)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:self.config[IntelligenceInstant], self.config[IntelligenceDaily], self.config[IntelligenceInternational], nil];
        actionSheet.tag = kColumnTypeActionSheetTag;
        self.columnTypeActionSheet = actionSheet;
    }
    
    [self.columnTypeActionSheet showInView:self.view];
}
- (IBAction)toggleWarnningType:(id)sender {
    [self.view endEditing:YES];
    if (self.loadWarnningTypeActionSheet == nil)
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:  nil];
        for (WarnningTypeAgent *agent in self.warnningTypeList) {
            [actionSheet addButtonWithTitle:agent.levelName];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
        actionSheet.actionSheetStyle = UIBarStyleDefault;
        
        actionSheet.tag = kLoadWarnningTypeListTag;
        self.loadWarnningTypeActionSheet = actionSheet;
    }
    
    [self.loadWarnningTypeActionSheet showInView:self.view];
}

// 发布预警

- (IBAction)distributeAlert:(id)sender
{
    @autoreleasepool {
        self.editing = NO;
        self.textFieldAlertTitle.text = [self.textFieldAlertTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (self.textFieldAlertTitle.text.length == 0)
        {
            [self showPromptInfo:@"标题不能为空，请填写标题。"];
            return;
        }
        
        if (self.checkedContactsList.count == 0)
        {
            [self showPromptInfo:@"联系人不能为空，请添加联系人。"];
            return;
        }
        
        [self.contentTextView resignFirstResponder];
        self.contentTextView.text = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (self.contentTextView.text.length == 0)
        {
            [self showPromptInfo:@"内容不能为空，请填写内容。"];
            return;
        }
        
        if (self.labelType.text.length == 0)
        {
            [self showPromptInfo:@"类型不能为空，请选择类型。"];
            return;
        }
        
        // 有图片先上传图片
        if (self.isAlreadySuccesToUploadPictures == NO)
        {
            [self.uploadedImageNameList removeAllObjects];
            
            NSMutableArray *shouldUploadImagelist = [NSMutableArray array];
            for (NSDictionary *item in self.readyToUploadImageList)
            {
                BOOL shouldUpload = [[item valueForKey:kShouldUploadKey] boolValue];
                if (shouldUpload)
                {
                    NSObject *obj = [item valueForKey:kOriginalImageURLKey];
                    if (obj)
                    {
                        [shouldUploadImagelist addObject:obj];
                    }
                }
                else
                {
                    NSString *uploadedImageName = [item valueForKey:kImageNameKey];
                    if (uploadedImageName.length > 0)
                    {
                        [self.uploadedImageNameList addObject:uploadedImageName];
                    }
                }
            }
            
            // 有待上传的图片
            if (shouldUploadImagelist.count > 0)
            {
                [self startShowPromptViewWithTip:@"正在压缩图片,请稍等..."];
                
                double delayInSeconds = 0.2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self uploadImagesToServer:shouldUploadImagelist];
                });
                
                return;
            }
        }
        
        [self startShowPromptViewWithTip:@"正在发布预警,请稍等..."];
        [self doDistributeAlertAction];
        
       
    }
}

#pragma mark - actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case kAddImageActionSheetTag:
        {
            if (buttonIndex == 0)  // 拍照
            {
                [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            }
            else if (buttonIndex == 1)  // 相册
            {
                [self addImageFromPickVer];
            }
        }
            break;
            
        case kColumnTypeActionSheetTag:
        {
            if (buttonIndex == 0)
            {
                self.labelType.text = self.config[IntelligenceInstant];
                self.columnType = IntelligenceColumnInstant;
            }
            else if (buttonIndex == 1)
            {
                self.labelType.text = self.config[IntelligenceDaily];
                self.columnType = IntelligenceColumnDaily;
            }
            else if (buttonIndex == 2)
            {
                self.labelType.text = self.config[IntelligenceInternational];
                self.columnType = IntelligenceColumnInternational;
            }
            break;
        }
        case kLoadWarnningTypeListTag:
        {
            if (buttonIndex == self.loadWarnningTypeActionSheet.numberOfButtons-1) {
                break;
            }
            self.labelWarnningType.text = [self.loadWarnningTypeActionSheet buttonTitleAtIndex:buttonIndex];
            self.warnningTypeAgent = [self.warnningTypeList objectAtIndex:buttonIndex];
            
            for (WarnningTypeAgent *agent in self.warnningTypeList) {
                DLog(@"levelName%@",agent.levelName);
                DLog(@"levelTip%@",agent.levelTip);
                DLog(@"levelCode%@",agent.levelCode);
                DLog(@"levelColor%@",agent.levelColor);
            }
            
        }
            break;
            
        default:
            break;
    }
}

-(void)addImageFromPickVer{
    ZLPhotoPickerViewController *pickerVC = [[ZLPhotoPickerViewController alloc] init];
    pickerVC.maxCount = 5 - self.readyToUploadImageList.count;
    pickerVC.status = PickerViewShowStatusCameraRoll;
    pickerVC.callBack = ^(NSArray *status){
        for (ZLPhotoAssets *asset in status) {
            [self showImageViewCollection:[asset thumbImage]];
        }
        for (ZLPhotoAssets *asset in status) {
            [self prepareProcessImage:[asset originImage] completion:^(NSDictionary *dict) {}];
        }
    };
    [pickerVC showPickerVc:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self tokenFieldResignResponser];
    if (textView.tag == 100)
    {
        [UIView animateWithDuration:0.7 animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 125);
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self tokenFieldResignResponser];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [original drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return final;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 原始图片
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 预处理图片
    [self prepareProcessImage:originalImage completion:^(NSDictionary *dict) {
        NSString *thumbImagePath = dict[kThumbImageURLKey];
        [self showImageViewCollection:[UIImage imageWithContentsOfFile:thumbImagePath]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self imagePickerControllerDidCancel:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MyMethods

// 预处理图片

- (void)prepareProcessImage:(UIImage *)image completion:(void (^) (NSDictionary *dict))completion
{
    [self startShowPromptViewWithTip:@"正在预处理图片,请稍等..."];
    self.addImageBtn.enabled = NO;
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        
        @autoreleasepool {
            __block UIImage *originalImage = nil;
            originalImage = [image fixOrientation]; // 重要的，否则上传到服务端图片会倒转
            
            // 如果图片大小超过3M，尺寸剪辑一半
            NSData *orignalImageData = UIImageJPEGRepresentation(originalImage, 1.0);
            if (orignalImageData.length > k3MImageDataSize)
            {
                originalImage = [self shrinkImage:originalImage
                                           toSize:CGSizeMake(originalImage.size.width / 2, originalImage.size.height /2)];
            }
            UIImage *thumbImage = [self shrinkImage:originalImage toSize:CGSizeMake(400, 300)];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                // 创建缓存上传图片的路径
                [self createUploadImageCachePath];
                
                // 将图片缓存到本地，防止内存不足
                NSString *imagefileName = [VEUtility createUUID];
                NSString *thumbImageFileName = [NSString stringWithFormat:@"%@-thumb", imagefileName];
                
                NSString *imagefilePath      = [self.uploadImageDiskCachePath stringByAppendingPathComponent:imagefileName];
                NSString *thumbImagefilePath = [self.uploadImageDiskCachePath stringByAppendingPathComponent:thumbImageFileName];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:imagefilePath
                                     contents:UIImageJPEGRepresentation(originalImage, 1.0)
                                   attributes:nil];
                
                [fileManager createFileAtPath:thumbImagefilePath
                                     contents:UIImageJPEGRepresentation(thumbImage, 1.0)
                                   attributes:nil];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     imagefilePath, kOriginalImageURLKey,
                                     thumbImagefilePath, kThumbImageURLKey,
                                     @"1", kShouldUploadKey,
                                     @"", kImageNameKey, nil];
                
                // 显示缩略图
                [self.readyToUploadImageList addObject:dic];
                [self stopShowPromptView];
                self.addImageBtn.enabled = YES;
                completion(dic);
            }];
        }
    }];
}

// 拍照、相册

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = sourceType;
        imagePicker.delegate = self;
        imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else
    {
        NSString *message = nil;
        if (sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            message = @"当前设置不支持拍照";
        }
        else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            message = @"当前设置不支持相册";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

// 获取当前添加的图片数量

- (NSInteger)currentNumberofAddedImage
{
    NSInteger counts = 0;
    for (UIImageView *imgView in self.imageViewCollection)
    {
        if (imgView.image == nil)
        {
            break;
        }
        else
        {
            ++counts;
        }
    }
    
    return counts;
}

// 清理缓存图片

- (void)clearUploadImageCaches
{
    if (self.uploadImageDiskCachePath.length > 0)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.uploadImageDiskCachePath
                                                   error:nil];
    }
}

// 创建缓存上传图片的路径

- (void)createUploadImageCachePath
{
    if (self.uploadImageDiskCachePath.length == 0)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.uploadImageDiskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kUploadImageCache];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.uploadImageDiskCachePath])
    {
        [fileManager createDirectoryAtPath:self.uploadImageDiskCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
}

-(void)showImageViewCollection:(UIImage *)image{
    int index = 0;
    for (UIImageView *imageView in self.imageViewCollection) {
        if (imageView.image == nil) {
            imageView.image = image;
            imageView.hidden = NO;
            ((UIButton *)[self.removeImageBtnCollection objectAtIndex:index]).hidden = NO;
            break;
        }
        ++index;
    }
}

//// 添加图片，并显示其缩略图
//- (void)addImageToImageViewCollection:(NSDictionary *)imgFilePathDic
//{
//    int index = 0;
//    for (UIImageView *imageView in self.imageViewCollection)
//    {
//        if (imageView.image == nil)
//        {
//            imageView.image = [[UIImage alloc] initWithContentsOfFile:[imgFilePathDic valueForKey:kThumbImageURLKey]];
//
//            imageView.hidden = NO;
//            ((UIButton *)[self.removeImageBtnCollection objectAtIndex:index]).hidden = NO;
//
//            if (imgFilePathDic)
//            {
//                [self.readyToUploadImageList addObject:imgFilePathDic];
//            }
//            break;
//        }
//
//        ++index;
//    }
//}

// 预览原始图

- (void)imageViewTapped:(UITapGestureRecognizer *)sender
{
    NSInteger tag = sender.view.tag;
    NSInteger index = (tag - 1000);
    
    if (index >= 0 && index  < kMaxCountsofImages)
    {
        VEImageDetailViewController *imageDetailViewController = [[VEImageDetailViewController alloc]
                                                                  initWithNibName:@"VEImageDetailViewController" bundle:nil];
        if (index < self.readyToUploadImageList.count)
        {
            NSString *originalImageURL = [[self.readyToUploadImageList objectAtIndex:index] valueForKey:kOriginalImageURLKey];
            imageDetailViewController.imageURL = originalImageURL;
        }
        
        [self presentViewController:imageDetailViewController animated:YES completion:nil];
    }
}

// 显示提示信息

- (void)showPromptInfo:(NSString *)tip
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:tip
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)startShowPromptViewWithTip:(NSString *)tip
{
    self.promptView.alpha = 0;
    self.lableTip.text = tip;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPromptView
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.lableTip.text = nil;
                     }
     ];
}

// 压缩图片

- (NSArray *)compressedImagesListOnImageSources:(NSArray *)imagesList
{
    NSMutableArray *compressedImagesList = [NSMutableArray array];
    
    // 创建缓存上传图片的路径
    [self createUploadImageCachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *singleImagePath in imagesList)
    {
        @autoreleasepool {
            if (singleImagePath.length > 0)
            {
                UIImage *singleImage = nil;
                if ([singleImagePath hasPrefix:@"http"])
                {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:singleImagePath]];
                    singleImage = [UIImage imageWithData:data];
                }
                else
                {
                    singleImage  = [[UIImage alloc] initWithContentsOfFile:singleImagePath];
                }
                
                if (singleImage != nil)
                {
                    NSData *compressedImageData = [VEUtility compressImage:singleImage withMaxSize:kMaxImageSize];
                    
                    NSString *name = [VEUtility createUUID];
                    NSString *compressedImageName = [NSString stringWithFormat:@"%@-compressed", name];
                    
                    NSString *imagefilePath = [self.uploadImageDiskCachePath stringByAppendingPathComponent:compressedImageName];
                    
                    [fileManager createFileAtPath:imagefilePath
                                         contents:compressedImageData
                                       attributes:nil];
                    
                    if (imagefilePath.length > 0)
                    {
                        [compressedImagesList addObject:imagefilePath];
                    }
                }
            }
        }
    }
    
    return compressedImagesList;
}

// 上传图片至服务端

- (void)uploadImagesToServer:(NSArray *)imagesList
{
    if (self.httpRequestImageLoader == nil)
    {
        self.httpRequestImageLoader = [[FYNHttpRequestLoader alloc] init];
    }
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@/PhotoUpload?qqfile=hihihihi.jpg&br=%@", kBaseURL, kBranch];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    // 压缩图片
    NSArray *compressedImagesList = [self compressedImagesListOnImageSources:imagesList];
    
    self.lableTip.text = @"正在上传图片,请稍等...";
    
    [self.httpRequestImageLoader cancelAsynRequest];
    [self.httpRequestImageLoader startAsynUploadWithURL:url withImages:compressedImagesList];
    
    __weak typeof(self) weakSelf = self;
    [self.httpRequestImageLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateUploadedImagesList:[jsonParser retrieveImagesValues]];
                return;
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
        
        [weakSelf stopShowPromptView];
    }];
}

// 更新

- (void)updateUploadedImagesList:(NSArray *)imagesList
{
    self.isAlreadySuccesToUploadPictures = YES;
    [self.uploadedImageNameList addObjectsFromArray:[imagesList valueForKey:@"image"]];
    
    self.lableTip.text = @"正在发布预警,请稍等...";
    [self doDistributeAlertAction];
}

// 发布预警信息

- (void)doDistributeAlertAction
{
    if (self.httpRequestDistributeLoader == nil)
    {
        self.httpRequestDistributeLoader = [[FYNHttpRequestLoader alloc] init];
    }
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@/CustomWarnAddForGA", kBaseURL];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    // 3DES加密 标题和内容
    NSString *encode3DESTitle = [DES3Util encrypt:self.textFieldAlertTitle.text];
    NSString *encode3DESContent= [DES3Util encrypt:self.contentTextView.text];
    if (!self.warnningTypeAgent) {
        if (!self.warnningTypeList) {
            self.warnningTypeAgent = [[WarnningTypeAgent alloc] init];
            self.warnningTypeAgent.levelTip = @"";
            self.warnningTypeAgent.levelCode = @"";
        }else{
            self.warnningTypeAgent = self.warnningTypeList[0];
        }
    }
    // UTF8编码
    NSString *encodeTitle = [VEUtility encodeToPercentEscapeString:encode3DESTitle];
    NSString *encodeContent = [VEUtility encodeToPercentEscapeString:encode3DESContent];
    NSString *encodeLevelCode = [VEUtility encodeToPercentEscapeString:self.warnningTypeAgent.levelCode];
    NSString *encodeLevelTip = [VEUtility encodeToPercentEscapeString:self.warnningTypeAgent.levelTip];
#warning  this a tag
    NSString *suggest = [VEUtility encodeToPercentEscapeString:[DES3Util encrypt:_suggest]];
    NSString *numberTitle = [VEUtility encodeToPercentEscapeString:[DES3Util encrypt:_showTitle]];
    NSString *paramsStr = [NSString stringWithFormat:@"numberTitle=%@&proposals=%@&title=%@&content=%@&contacts=%@&level=3&exchangeType=%ld&sendtype=%ld&deviceInfo=IOS-%@&levelCode=%@&levelTip=%@",numberTitle,suggest,
                           encodeTitle, encodeContent, [self retrieveCheckedContactsList], (long)self.columnType, (long)self.sendType, [VEUtility getUMSUDID],encodeLevelCode,encodeLevelTip];
    NSString *strImageNameList = [NSString string];
    
    for (NSString *imageName in self.uploadedImageNameList)
    {
        strImageNameList = [strImageNameList stringByAppendingString:imageName];
        if (imageName != [self.uploadedImageNameList lastObject])
        {
            strImageNameList = [strImageNameList stringByAppendingString:@"_"];
        }
    }
    if (strImageNameList.length > 0)
    {
        paramsStr = [paramsStr stringByAppendingFormat:@"&images=%@", strImageNameList];
    }
    
    
    
    DLog(@"paramsStr IS %@",paramsStr);
    [self.httpRequestDistributeLoader cancelAsynRequest];
    [self.httpRequestDistributeLoader startAsynRequestWithURL:url withParams:paramsStr];
    
    __weak typeof(self) weakSelf = self;
    [self.httpRequestDistributeLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        [weakSelf stopShowPromptView];
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateDistributeAlertAction];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
#warning self.warnningTypeAgent 赋值为空
    self.warnningTypeAgent = nil;
}

- (void)updateDistributeAlertAction
{
    if (self.comeFromColumnType == self.columnType)
    {
        VEAlertDistributeViewSuccessDistribute = YES;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"发送成功"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
    if (self.sendSuccess) {
        self.sendSuccess();
    }
    [self goBack];
}

-(void)loadLocalWarnningTypeList{
    if (self.warnningTypeAgent) {
        self.labelWarnningType.text = self.warnningTypeAgent.levelName;
    }else{
        self.labelWarnningType.text = @"无";
    }
    
}

- (void)loadWarnningTypeList
{
    FYNHttpRequestLoader *loadWarnningType = [[FYNHttpRequestLoader alloc]init];
    NSString *stringUrl = [NSString stringWithFormat:@"%@/CustomWarnLevelsForGA", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *paramsStr = [NSString stringWithFormat:@"sessionToken=%@",sessionToken];
    __weak typeof(self) weakSelf = self;
    [loadWarnningType startAsynRequestWithURL:url withParams:paramsStr];
    [loadWarnningType setCompletionHandler:^( NSDictionary *dict, NSString *error) {
        NSMutableArray *strArray = [NSMutableArray array];
        for (NSDictionary *d in [dict objectForKey:@"list"]) {
            WarnningTypeAgent *agent = [[WarnningTypeAgent alloc]initWithDictionary:d];
            [weakSelf.warnningTypeList addObject:agent];
            [strArray addObject:agent.levelName];
        }
        [[NSUserDefaults standardUserDefaults]setObject:strArray forKey:@"levelName"];
    }];
}


// 获取收信人列表

- (NSString *)retrieveCheckedContactsList
{
    NSString *allContacts = [NSString string];
    for (ContactAgent *checkedAgent in self.checkedContactsList)
    {
        allContacts = [allContacts stringByAppendingFormat:@"%ld", (long)checkedAgent.userId];
        if (checkedAgent != [self.checkedContactsList lastObject])
        {
            allContacts = [allContacts stringByAppendingString:@"_"];
        }
    }
    return allContacts;
}

- (void)loadContactsList
{
    if (self.httpRequestContactsListLoader == nil)
    {
        self.httpRequestContactsListLoader = [[FYNHttpRequestLoader alloc] init];
    }
    
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/CustomGroupList", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [self.httpRequestContactsListLoader cancelAsynRequest];
    [self.httpRequestContactsListLoader startAsynRequestWithURL:url withParams:@""];
    
    __weak typeof(self) weakSelf = self;
    [self.httpRequestContactsListLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateContactListData:[jsonParser retrieveAllUsersListValue]];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)updateContactListData:(NSArray *)contactsList
{
    if (self.contactsList == nil)
    {
        self.contactsList = [NSMutableArray array];
    }
    
    [self.contactsList removeAllObjects];
    for (NSDictionary *item in contactsList)
    {
        ContactGroupAgent *groupAgent = [[ContactGroupAgent alloc] initWithDictionary:item];
        [self.contactsList addObject:groupAgent];
    }
}

- (void)layoutTokenField
{
    self.secondView.top = (self.tokenField.top + self.tokenField.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                             (self.secondView.top + self.secondView.height + 10));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.textFieldAlertTitle isFirstResponder])
    {
        [self.textFieldAlertTitle resignFirstResponder];
    }
    if ([self.contentTextView isFirstResponder])
    {
        [self.contentTextView resignFirstResponder];
    }
    [self.tokenField resignFirstResponder];
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification
{
    if (self.addImageActionSheet)
    {
        if (self.addImageActionSheet.numberOfButtons)
        {
            [self.addImageActionSheet dismissWithClickedButtonIndex:(self.addImageActionSheet.numberOfButtons - 1)
                                                           animated:NO];
        }
    }
    
    if (self.columnTypeActionSheet)
    {
        if (self.columnTypeActionSheet.numberOfButtons)
        {
            [self.columnTypeActionSheet dismissWithClickedButtonIndex:(self.columnTypeActionSheet.numberOfButtons - 1)
                                                             animated:NO];
        }
    }
}

#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    if (index < self.checkedContactsList.count)
    {
        ContactAgent *contactAgent = [self.checkedContactsList objectAtIndex:index];
        return contactAgent.userName;
    }
    return @"";
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return self.checkedContactsList.count;
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    NSString *tip = nil;
    if (self.checkedContactsList.count > 0)
    {
        ContactAgent *contactAgent = [self.checkedContactsList objectAtIndex:0];
        tip = contactAgent.userName;
        
        if (self.checkedContactsList.count > 1)
        {
            ContactAgent *contactAgent2 = [self.checkedContactsList objectAtIndex:1];
            tip = [NSString stringWithFormat:@"%@ %@", tip, contactAgent2.userName];
        }
        
        if (self.checkedContactsList.count > 2)
        {
            tip = [NSString stringWithFormat:@"%@...等%lu人", tip, (unsigned long)self.checkedContactsList.count];
        }
    }
    return tip;
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenFieldDidBeginEditing:(VENTokenField *)tokenField;
{
    [self layoutTokenField];
    [UIView animateWithDuration:0.7 animations:^{
        CGFloat y = 44;
        CGFloat diff = ((self.tokenField.height > 70) ? (self.tokenField.height - 70) : 0);
        y += diff;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, y);
    }];
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [self tokenFieldResignResponser];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    if (index < self.checkedContactsList.count)
    {
        [self.checkedContactsList removeObjectAtIndex:index];
    }
    [self.tokenField reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tokenField becomeFirstResponder];
    });
}

- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    if (text.length > 0)
    {
        [self updateFilteredContentForSearchString:text];
    }
    else
    {
        [self removeFilterTableView];
    }
}

- (void)showFilterTableView
{
    if (self.filterTableView == nil)
    {
        self.filterTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.filterTableView.dataSource = self;
        self.filterTableView.delegate = self;
        
        self.filterTableView.tableFooterView = [[UIView alloc] init];
    }
    
    self.filterTableView.hidden = NO;
    if (self.filterTableView.superview == nil)
    {
        self.filterTableView.frame = self.secondView.frame;
        [self.scrollView addSubview:self.filterTableView];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, (self.filterTableView.top + self.filterTableView.height + 10));
    }
}


#pragma mark - Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.filteredContactsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ContactGroupAgent *groupAgent = [self.filteredContactsList objectAtIndex:section];
    NSInteger rows = groupAgent.groupMember.count;
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellContactIdentifier = @"defaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellContactIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellContactIdentifier];
        cell.textLabel.textColor = plainTextColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    ContactGroupAgent *groupAgent = [self.filteredContactsList objectAtIndex:section];
    ContactAgent *contactAgent = [groupAgent.groupMember objectAtIndex:row];
    
    cell.textLabel.text = contactAgent.userName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    ContactGroupAgent *groupAgent = [self.filteredContactsList objectAtIndex:section];
    ContactAgent *contactAgent = [groupAgent.groupMember objectAtIndex:row];
    
    [self addContactAgent:contactAgent];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ContactGroupAgent *groupAgent = [self.filteredContactsList objectAtIndex:section];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    lable.font = [UIFont boldSystemFontOfSize:14];
    lable.text = [NSString stringWithFormat:@"   %@", groupAgent.groupName];
    lable.backgroundColor = selectedBackgroundColor;
    
    return lable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

#pragma mark - Content Filtering

- (void)updateFilteredContentForSearchString:(NSString *)searchString
{
    @autoreleasepool {
        [self.filteredContactsList removeAllObjects];
        if (searchString.length > 0)
        {
            self.filteredContactsList = [NSMutableArray array];
            for (ContactGroupAgent *groupAgent in self.contactsList)
            {
                @autoreleasepool {
                    NSMutableArray *searchItemsPredicate = [NSMutableArray array];
                    
                    NSExpression *lhs = [NSExpression expressionForKeyPath:@"userName"];
                    NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
                    NSPredicate *finalPredicate = [NSComparisonPredicate
                                                   predicateWithLeftExpression:lhs
                                                   rightExpression:rhs
                                                   modifier:NSDirectPredicateModifier
                                                   type:NSContainsPredicateOperatorType
                                                   options:NSCaseInsensitivePredicateOption];
                    [searchItemsPredicate addObject:finalPredicate];
                    
                    lhs = [NSExpression expressionForKeyPath:@"userNamePY"];
                    rhs = [NSExpression expressionForConstantValue:searchString];
                    finalPredicate = [NSComparisonPredicate
                                      predicateWithLeftExpression:lhs
                                      rightExpression:rhs
                                      modifier:NSDirectPredicateModifier
                                      type:NSContainsPredicateOperatorType
                                      options:NSCaseInsensitivePredicateOption];
                    
                    NSExpression *lhs1 = [NSExpression expressionForKeyPath:@"allFirstLetters"];
                    NSExpression *rhs1 = [NSExpression expressionForConstantValue:[searchString substringToIndex:1]];
                    NSPredicate  *predicate1 = [NSComparisonPredicate
                                                predicateWithLeftExpression:lhs1
                                                rightExpression:rhs1
                                                modifier:NSDirectPredicateModifier
                                                type:NSContainsPredicateOperatorType                                                    options:NSCaseInsensitivePredicateOption];
                    
                    NSCompoundPredicate *andMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:finalPredicate, predicate1, nil]];
                    
                    [searchItemsPredicate addObject:andMatchPredicates];
                    
                    lhs = [NSExpression expressionForKeyPath:@"allFirstLetters"];
                    rhs = [NSExpression expressionForConstantValue:searchString];
                    finalPredicate = [NSComparisonPredicate
                                      predicateWithLeftExpression:lhs
                                      rightExpression:rhs
                                      modifier:NSDirectPredicateModifier
                                      type:NSContainsPredicateOperatorType
                                      options:NSCaseInsensitivePredicateOption];
                    [searchItemsPredicate addObject:finalPredicate];
                    
                    NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
                    
                    NSMutableArray *groupMembers = [[groupAgent.groupMember filteredArrayUsingPredicate:orMatchPredicates] mutableCopy];
                    
                    if (groupMembers.count > 0)
                    {
                        ContactGroupAgent *aGroupAgent = [[ContactGroupAgent alloc] init];
                        aGroupAgent.groupId = groupAgent.groupId;
                        aGroupAgent.groupName = groupAgent.groupName;
                        aGroupAgent.groupMember = groupMembers;
                        
                        [self.filteredContactsList addObject:aGroupAgent];
                    }
                }
            }
        }
        
        if (self.filteredContactsList.count > 0)
        {
            [self showFilterTableView];
            [self.filterTableView reloadData];
        }
        else
        {
            [self removeFilterTableView];
        }
    }
}

- (void)addContactAgent:(ContactAgent *)contactAgent
{
    BOOL existed = NO;
    NSInteger uid = contactAgent.userId;
    for (ContactAgent *contactAgent in self.checkedContactsList)
    {
        if (uid == contactAgent.userId)
        {
            existed = YES;
        }
    }
    
    if (existed == NO)
    {
        [self.checkedContactsList addObject:contactAgent];
    }
    
    [self.tokenField reloadData];
    [self removeFilterTableView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tokenField becomeFirstResponder];
    });
}

- (void)removeFilterTableView
{
    self.filterTableView.hidden = YES;
    [self.filterTableView removeFromSuperview];
    [self.filteredContactsList removeAllObjects];
    [self.filterTableView reloadData];
    
    [self layoutTokenField];
}

- (void)tokenFieldResignResponser
{
    [self.tokenField resignFirstResponder];
    [self.tokenField collapse];
    [self removeFilterTableView];
}



@end




