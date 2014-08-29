//
//  FBDetail2Controller.m
//  FBAuto
//
//  Created by lichaowei on 14-7-3.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FBDetail2Controller.h"
#import "FBPhotoBrowserController.h"
#import "DDPageControl.h"
#import "FBChatViewController.h"
#import "ClickImageView.h"
#import "LShareSheetView.h"
#import "GuserZyViewController.h"
#import "FBFriendsController.h"
#import "DXAlertView.h"

#import <ShareSDK/ShareSDK.h>

@interface FBDetail2Controller ()
{
    DDPageControl *pageControl;
    NSArray *imageUrlsArray;
    
    NSString *userId;//用户id
}

@end

@implementation FBDetail2Controller

@synthesize bigBgScroll,photosScroll;
@synthesize firstBgView,thirdBgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bigBgScroll.contentSize = CGSizeMake(320, self.bigBgScroll.height + 100);
    
    [self getSingleCarInfoWithId:self.infoId];
    
    
    
    if (self.isHiddenUeserInfo) {
        thirdBgView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求

- (void)getSingleCarInfoWithId:(NSString *)carId
{
    NSString *url = [NSString stringWithFormat:FBAUTO_CARSOURCE_SINGLE_SOURE,carId];
    
    NSLog(@"单个车源信息 %@",url);
    
    LCWTools *tool = [[LCWTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"单个车源发布 result %@, erro%@",result,[result objectForKey:@"errinfo"]);
        
        NSArray *dataInfo = [result objectForKey:@"datainfo"];
        
        if (dataInfo.count == 0) {
            return ;
        }
        
        NSDictionary *dic = [dataInfo objectAtIndex:0];
        
        
        NSString *carName = [dic objectForKey:@"car_name"];
        
        UILabel *nameLabel = self.car_modle_label;
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        CGFloat newHeight = [LCWTools heightForText:carName width:200 font:14];
        
        CGRect oldFrame = nameLabel.frame;
        
        CGFloat dis = newHeight - oldFrame.size.height;
        
        oldFrame.size.height = newHeight;
        nameLabel.frame = oldFrame;
        
        //        //参数
        
        
        for (int i = 1; i < 10; i ++) {
            UILabel *label = (UILabel *)[self.view viewWithTag:120 + i];
            label.top += dis;
            
            UILabel *label2 = (UILabel *)[self.view viewWithTag:100 + i];
            label2.top += dis;
        }
        
        nameLabel.text = carName;
        
        //参数
        self.car_modle_label.text = carName;
        
        NSString *price = [dic objectForKey:@"price"];
        if (price.length == 0) {
            price = @"0";
        }
        
        self.car_realPrice_label.text = [NSString stringWithFormat:@"%@万元",price];
        self.car_timelimit_label.text = [dic objectForKey:@"spot_future"];
        self.car_outColor_Label.text = [dic objectForKey:@"color_out"];
        self.car_inColor_label.text = [dic objectForKey:@"color_in"];
        self.car_standard_label.text = [dic objectForKey:@"carfrom"];
        self.car_time_label.text = [LCWTools timechange2:[dic objectForKey:@"dateline"]];
        
        NSString *detail = [dic objectForKey:@"cardiscrib"];
        
        self.car_detail_label.text = detail;
        
        self.car_detail_label.height = [LCWTools heightForText:detail width:199 font:14];
        
        self.build_time_label.text = [dic objectForKey:@"build_time"];
        //商家信息

        self.nameLabel.text = [dic objectForKey:@"username"];
        self.saleTypeBtn.titleLabel.text = [dic objectForKey:@"usertype"];//商家类型
        self.phoneNumLabel.text = [LCWTools NSStringNotNull:[dic objectForKey:@"phone"]];
        self.addressLabel.text = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"province"],[dic objectForKey:@"city"]];
        NSString *headImage = [LCWTools NSStringNotNull:[dic objectForKey:@"headimage"]];
        
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:headImage] placeholderImage:[UIImage imageNamed:@"detail_test"]];
        
        userId = [dic objectForKey:@"uid"];//用户id
        
        //车辆图片
        
        NSArray *image = [dic objectForKey:@"image"];
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:image.count];

        for (NSDictionary *aImageDic in image) {
            
            NSString *url = [aImageDic objectForKey:@"link"];
            [imageUrls addObject:url];
        }
        
        [self createFirstSectionWithImageUrls:imageUrls];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        NSLog(@"failDic %@",failDic);
        
        DXAlertView *alert = [[DXAlertView alloc]initWithTitle:[failDic objectForKey:ERROR_INFO] contentText:nil leftButtonTitle:nil rightButtonTitle:@"确定"];
        [alert show];
        
        alert.leftBlock = ^(){
            NSLog(@"确定");
            
        };
        alert.rightBlock = ^(){
            NSLog(@"取消");
            
        };
    }];
}

#pragma - mark 图片部分

- (void)createFirstSectionWithImageUrls:(NSArray *)imageUrls
{
    imageUrlsArray = imageUrls;
    
    CGFloat aWidth = (photosScroll.width - 14)/ 3;
    
    for (int i = 0; i < imageUrls.count; i ++) {
        
        ClickImageView *clickImage = [[ClickImageView alloc]initWithFrame:CGRectMake((aWidth + 7) * i, 0, aWidth, 80) target:self action:@selector(clickToBigPhoto:)];
        
        [clickImage sd_setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"detail_test"]];
        
        clickImage.tag = 100 + i;
        
        [photosScroll addSubview:clickImage];
        
    }
    
    photosScroll.contentSize = CGSizeMake(aWidth * imageUrls.count + 7 * (imageUrls.count - 1), 80);
    
    [self createPageControlSumPages:(int)imageUrls.count];
    
    if (imageUrls.count <= 2) {
        
        CGRect aFrame = photosScroll.frame;
        aFrame.size.width = aWidth * imageUrls.count;
        photosScroll.frame = aFrame;
        
        photosScroll.center = CGPointMake(150, photosScroll.center.y);
    }
}


#pragma - mark 创建 PageControl

- (void)createPageControlSumPages:(int)sum
{
    if (sum % 3 == 0) {
        sum = sum / 3;
    }else
    {
        sum = (sum / 3) + 1;
    }
    
    
    pageControl = [[DDPageControl alloc] init] ;
	[pageControl setCenter: CGPointMake(firstBgView.center.x, firstBgView.height-10.0f)] ;
    //	[pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
	[pageControl setDefersCurrentPageDisplay: YES] ;
	[pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[pageControl setOnColor: [UIColor colorWithHexString:@"ff9c00"]];
	[pageControl setOffColor: [UIColor colorWithHexString:@"b4b4b4"]] ;
	[pageControl setIndicatorDiameter: 9.0f] ;
	[pageControl setIndicatorSpace: 5.0f] ;
	[firstBgView addSubview: pageControl] ;
    
    //    pageControl.hidden = YES;
    
    [pageControl setNumberOfPages:sum];
	[pageControl setCurrentPage: 0];
}

#pragma - mark click 事件

/**
 *  http://fbautoapp.fblife.com/resource/photo/dc/0a/thumb_50_ori.jpg
 *
 *  @param btn <#btn description#>
 */
- (void)clickToBigPhoto:(ClickImageView *)btn
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *url in imageUrlsArray) {
        
        NSMutableString *str = [NSMutableString stringWithString:url];
        
        [str replaceOccurrencesOfString:@"small" withString:@"ori" options:0 range:NSMakeRange(0, str.length)];
        
        [arr addObject:str];
        
    }
    
    FBPhotoBrowserController *browser = [[FBPhotoBrowserController alloc]init];
    browser.imagesArray = arr;
    browser.showIndex = (int)btn.tag - 100;
    browser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = photosScroll.bounds.size.width ;
    float fractionalPage = photosScroll.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (pageControl.currentPage != nearestNumber)
	{
		pageControl.currentPage = nearestNumber ;
		
		// if we are dragging, we want to update the page control directly during the drag
		if (photosScroll.dragging)
			[pageControl updateCurrentPageDisplay] ;
	}
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.contentOffset.x);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[pageControl updateCurrentPageDisplay] ;
    
//    NSLog(@"%f",aScrollView.contentOffset.x);
}

#pragma - mark 点击事件

- (IBAction)clickToDial:(id)sender {
    
    NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",self.phoneNumLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
}
- (IBAction)clickToChat:(id)sender {
    
    if ([self.phoneNumLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:XMPP_USERID]]) {
        
        [LCWTools alertText:@"本人发布信息"];
        return;
    }
    
    FBChatViewController *chat = [[FBChatViewController alloc]init];
    chat.chatWithUser = self.phoneNumLabel.text;
    chat.chatWithUserName = self.nameLabel.text;
    chat.chatUserId = userId;
    [self.navigationController pushViewController:chat animated:YES];
    
}

- (IBAction)clickToPersonal:(id)sender {
    
    GuserZyViewController *personal = [[GuserZyViewController alloc]init];
    personal.title = self.nameLabel.text;
    personal.userId = userId;
    [self.navigationController pushViewController:personal animated:YES];
}

//收藏
- (void)clickToCollect:(UIButton *)sender
{
    NSLog(@"收藏");
    
    // ‘1’ 车源收藏 ‘2’ 寻车收藏
    NSString *url = [NSString stringWithFormat:FBAUTO_COLLECTION,[GMAPI getAuthkey],self.carId,1,self.infoId];
    
    NSLog(@"添加收藏 %@",url);
    
    LCWTools *tool = [[LCWTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"添加收藏 result %@, erro%@",result,[result objectForKey:@"errinfo"]);
        
        [LCWTools showDXAlertViewWithText:[result objectForKey:@"errinfo"]];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        NSLog(@"failDic %@",failDic);
        [LCWTools showDXAlertViewWithText:[failDic objectForKey:ERROR_INFO]];
        
    }];

    
}

//分享
- (void)clickToShare:(UIButton *)sender
{
    NSLog(@"分享");
    LShareSheetView *shareView = [[LShareSheetView alloc]initWithFrame:self.view.frame];
    [shareView actionBlock:^(NSInteger buttonIndex, NSString *shareStyle) {
        
//        NSArray *text =  @[@"微信",@"QQ",@"朋友圈",@"微博",@"站内好友"];
        
        NSString *contentText = [NSString stringWithFormat:@"我在e族汽车上发了一辆新车，有兴趣的来看(%@）。",self.car_modle_label.text];
        
        NSString *shareUrl = [NSString stringWithFormat:FBAUTO_SHARE_CAR_SOURCE,self.infoId];
        NSString *contentWithUrl = [NSString stringWithFormat:@"%@%@",contentText,shareUrl];
        
        ClickImageView *clickImage = (ClickImageView *)[photosScroll viewWithTag:100];
        
        UIImage *aImage = clickImage.image;
        
        buttonIndex -= 100;
        
        NSLog(@"share %d %@",buttonIndex,shareStyle);
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"微信");
                [LCWTools shareText:contentText title:self.car_modle_label.text image:aImage linkUrl:shareUrl ShareType:ShareTypeWeixiSession];
            }
                break;
            case 1:
            {
                NSLog(@"QQ");
                [LCWTools shareText:contentText title:self.car_modle_label.text image:aImage linkUrl:shareUrl ShareType:ShareTypeQQ];
            }
                break;
            case 2:
            {
                NSLog(@"朋友圈");
                [LCWTools shareText:contentText title:self.car_modle_label.text image:aImage linkUrl:shareUrl ShareType:ShareTypeWeixiTimeline];
            }
                break;
            case 3:
            {
                NSLog(@"微博");

                [LCWTools shareText:contentWithUrl title:self.car_modle_label.text image:aImage linkUrl:shareUrl ShareType:ShareTypeSinaWeibo];
            }
                break;
            case 4:
            {
                NSLog(@"站内好友");
                
                FBFriendsController *friend = [[FBFriendsController alloc]init];
                friend.isShare = YES;
                //分享的内容  {@"text",@"infoId"}
                
                NSString *infoId = [NSString stringWithFormat:@"%@,%@",self.infoId,self.carId];
                friend.shareContent = @{@"text": contentText,@"infoId":infoId};
                [self.navigationController pushViewController:friend animated:YES];
                
            }
                break;
                
            default:
                break;
        }
    }];
}


@end
