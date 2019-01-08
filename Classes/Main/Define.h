//
//  Define.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-11.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#ifndef voiceexpress_Define_h
#define voiceexpress_Define_h



#define Config(NAME)        [QCZipImageTool getDictionaryWithName:kConfig][(NAME)]
#define Image(NAME)     [QCZipImageTool imageNamed:Config((NAME))]

#define kConfig                     @"Config.plist"
#define RELOADIMAGE @"reloadImage"
/**
*                                   公共部分
 */
#define MainColor                   @"MainColor"

#define Tab_Ico_List                @"tab_icon_list"
#define Tab_Ico_List_Red            @"tab_icon_list_red"
#define Tab_Icon_More               @"tab_icon_more"
#define Tab_Icon_Back               @"tab_icon_back"
#define Tab_Icon_Refresh            @"tab_icon_refresh"
#define Tab_Icon_Ok                 @"tab_icon_ok"
#define Icon_Write                  @"icon_write"
#define Icon_New                    @"icon_new"
#define Icon_Add                    @"icon_add"
#define Icon_Share                  @"icon_share"
#define Icon_Lock                   @"icon_lock"
#define Icon_Upload                 @"icon_upload"
#define Icon_Unlock                 @"icon_unlock"
#define Icon_Selected               @"icon_selected"
#define Icon_Favourite2             @"icon_favourite2"
#define Icon_Nofavourite2           @"icon_nofavourite2"
#define Icon_Favorite_Alerts        @"icon_favorite_alerts"
#define Icon_Favorite_Recommend     @"icon_favorite_recommend"
#define Icon_Checkbox_Pressed       @"icon_checkbox_pressed"
#define Icon_Checkbox_Normal        @"icon_checkbox_normal"
#define Icon_Circle_Yellow @"icon_circle_yellow"
#define Icon_Circle_Red @"icon_circle_red"
#define Icon_Circle_Blue @"icon_circle_blue"
#define Icon_List_Red @"icon_list_red"
#define Icon_List_Blue @"icon_list_blue"
#define Icon_List_Yellow @"icon_list_yellow"
#define Icon_List_Green @"icon_list_green"
#define Icon_Wangan @"icon_wangan"
#define Icon_Delete @"icon_delete"
#define Icon_Image_Add @"icon_image_add"
#define Icon_Group @"icon_group"
#define Icon_Group_Down @"icon_group_down"
#define Icon_Group_Up @"icon_group_up"
#define Icon_Check_Normal @"icon_check_normal"
#define Icon_Check_Selected @"icon_check_selected"
#define Login_Keep_Normal @"login_keep_normal"
#define Login_Keep_Pressed @"login_keep_pressed"
#define Icon_Unread @"unread"
#define Icon_Arr_Down @"arr_down"
#define Icon_Arr_Up @"arr_up"
#define Icon_Tipnew @"ico_tipnew"
#define Ico_Next @"ico_next"
#define Icon_Intellig_Down @"icon_intellig_down"
#define Bg_fj_active @"bg_fj_active"
#define Bg_fj_normal @"bg_fj_normal"
#define Icon_Read @"read"
#define Menu_Icon_Setting @"menu_icon_setting"
#define Icon_Iogo @"logo"
#define Icon_Picture_Min @"picture-min"
#define Icon_Group_Add @"icon_group_add"
#define Icon_Search @"icon_search"
#define MobileToken @"mobileToken"
#define Icon_Lock_On @"icon_lock_on"
#define Icon_Lock_Normal @"icon_lock_normal"
/**
*                                   菜单页
 */
#define Menu_Icon_User              @"menu_icon_user"
#define Menu_Icon_Key               @"menu_icon_key"
#define Menu_Icon_Red_Point         @"menu_icon_red_point"
#define Menu_Cell_Selected_Img      @"menu_cell_selected_img"
#define Menu_Cell_Normal_Color @"Menu_Cell_Normal_Color"
#define Menu_Cell_Selected_Color    @"Menu_Cell_Selected_Color"
/**
*                                   情报交互
 */
#define Msg_Title                   @"Msg_Title"
#define ToMe                        @"ToMe"
#define SenderTo                    @"SenderTo"
#define RelativeMe                  @"RelativeMe"
#define MarkToRead                  @"MarkToRead"
#define RefreshAllData              @"RefreshAllData"
#define Cancle                      @"Cancle"
#define DeptName                    @"DeptName"
#define Body                        @"Body"
#define Recriver                    @"Recriver"
#define Sender                      @"Sender"
#define Reply                       @"Reply"
#define Relative                    @"Relative"
#define Loading                     @"Loading"
#define IntelligenceDaily           @"IntelligenceDaily"
#define IntelligenceInternational   @"IntelligenceInternational"
#define IntelligenceAllIntelligence @"IntelligenceAllIntelligence"
#define IntelligenceInstant         @"IntelligenceInstant"
#define ImageTip_Right              @"ImageTip_Right"
#define ImageTip_Left               @"ImageTip_Left"
#define WarnAlert                   @"WarnAlert"
#define WarnTitle                   @"WarnTitle"
#define WarnType                    @"WarnType"
#define WarnLevel                   @"WarnLevel"
#define WarnContent                 @"WarnContent"
#define WarnImage                   @"WarnImage"

/**
*                                   自定义组
 */
#define SelectPersion               @"SelectPersion"
#define NoPerson                    @"NoPerson"
#define NoGroup                     @"NoGroup"
#define AllGruop                    @"AllGruop"
#define FastGroup                   @"FastGroup"
#define CustomGroup                 @"CustomGroup"
#define GroupManner                 @"GroupManner"
#define AddGroup                    @"AddGroup"
/**
*                                   信息上报
 */
#define InternetTitle               @"InternetTitle"
#define InsideInternet              @"InsideInternet"
#define OutsideInternet             @"OutsideInternet"
#define AllDept                     @"AllDept"
#define AllArea                     @"AllArea"

/**
*                                   舆情预警
 */
#define WarnAlertTitle              @"WarnAlertTitle"
#define FitterContent               @"FitterContent"
#define FitterResults_Left          @"FitterResults_Left"
#define FitterResults_Right         @"FitterResults_Right"
#define Normal                      @"Normal"
#define Import                      @"Import"
#define Urgent                      @"Urgent"
#define WarnLevelTip                @"WarnLevelTip"
/**
*                                   推荐阅读
 */
#define ReadTitle                   @"ReadTitle"
#define Read_Icon_Default           @"read_icon_default"

/**
*                                   舆情搜索
 */
#define WarnSearch                  @"WarnSearch"
#define WarnAlertSearch             @"WarnAlertSearch"
#define ReadSearch                  @"ReadSearch"
#define SearchTypeArea              @"SearchTypeArea"
#define SearchTypeHistory           @"SearchTypeHistory"
#define SearchResult_Right          @"SearchResult_Right"
#define SearchResult_Left           @"SearchResult_Left"

/**
*                                   收藏夹
 */
#define Favourites                  @"Favourites"
#define Icon_Nofavourite            @"icon_nofavourite"
#define Icon_Favourite              @"icon_favourite"
/**
*                                   信息审核
 */
#define InformationTitle            @"InformationTitle"
#define NoInformation               @"NoInformation"
#define HasInformation              @"HasInformation"

/**
*                                   设置
 */
#define Setting_Title               @"setting_title"
#define User_Option                 @"user_option"
#define Data_Option                 @"data_option"
#define System_Option               @"system_option"
#define User_Name                   @"user_name"
#define Modefy_Password             @"modefy_password"
#define Notify_Option               @"notify_option"
#define Receive_Image               @"receive_image"
#define Device_Lock                 @"device_lock"
#define Auto_Login                  @"auto_Login"
#define Version_Check               @"version_check"
#define Upload_Log                  @"upload_log"
#define Help_Us                     @"help_us"
#define About_Us                    @"about_us"
#define Logo_Cyyun                  @"logo_cyyun"
#define Icon_Message                @"icon_message"
#define Icon_Telephone              @"icon_telephone"

    /////////////////////////////////////////////////////////////////////////////
    // Color

    #define selectedBackgroundColor ([UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1.0f])
    #define plainTextColor          ([UIColor colorWithRed:4/255.0f green:4/255.0f blue:4/255.0f alpha:1.0f])
    #define unreadFontColor         ([UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.0f])
    #define readFontColor           ([UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f])
    #define detailTitleColor        ([UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f])
    #define replyCategoryColor      ([UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1.0f])
    #define patternLockTipColor     ([UIColor colorWithRed:138.0/255.0f green:138.0/255.0f blue:138.0/255.0f alpha:1.0f])
    #define lowGreenColor           ([UIColor colorWithRed:59.0/255.0f green:135.0/255.0f blue:150.0/255.0f alpha:1.0f])
    #define midGreenColor           ([UIColor colorWithRed:26.0/255.0f green:131.0/255.0f blue:255.0/255.0f alpha:1.0f])
    #define midRedColor             ([UIColor colorWithRed:255.0/255.0f green:66.0/255.0f blue:21.0/255.0f alpha:1.0f])
    #define leftPanBackgroundColor  ([UIColor colorWithRed:49.0/255.0f green:112.0/255.0f blue:124.0/255.0f alpha:1.0f])


    /////////////////////////////////////////////////////////////////////////////
    // 自定义页面路径名称
                                
    #define LoginView                           @"LoginView"
    #define LatestAlertFilterResultsView        @"LatestAlertFilterResultsView"
    #define LatestAlertFilterView               @"LatestAlertFilterView"
    #define LatestAlertView                     @"LatestAlertView"
    #define DetailView                          @"DetailView"
    #define InternetDetailView                  @"InternetDetailView"
    #define RecommendReadView                   @"RecommendReadView"
    #define RecommendColumnView                 @"RecommendColumnView"
    #define FavoriteView                        @"FavoriteView"
    #define FavoriteDetailView                  @"FavoriteDetailView"
    #define SearchView                          @"SearchView"
    #define SearchResultView                    @"SearchResultView"
    #define MoreSettingView                     @"MoreSettingView"
    #define AboutUsView                         @"AboutUsView"
    #define HelpMeView                          @"HelpMeView"
    #define HelpMeDetailView                    @"HelpMeDetailView"
    #define ChangePWView                        @"ChangePassWordView"
    #define UploadLogView                       @"UploadLogView"
    #define OriginalWebView                     @"OriginalWebView"
    #define AlertRulesView                      @"AlertRulesView"
    #define NewOrChangeAlertRuleView            @"NewOrChangeAlertRuleView"
    #define AlertDistributeView                 @"AlertDistributeView"
    #define AlertContactsView                   @"AlertContactsView"
    #define AlertNotificationView               @"AlertNotificationView"
    #define MessageAlertView                    @"MessageAlertView"
    #define CustomAlertView                     @"CustomAlertView"
    #define CustomAlertDetailView               @"CustomAlertDetailView"
    #define CommentView                         @"CommentView"
    #define LeftPanView                         @"LeftPanView"
    #define InternetView                        @"InternetView"
    #define IntelligenceListView                @"IntelligenceListView"

    /////////////////////////////////////////////////////////////////////////////
    // 自定义事件

    #define PullDownToRefreshEvent                  @"PullDownToRefresh"     
    #define AddFavoriteEvent                        @"AddFavorite"
    #define RemoveFavoriteEvent                     @"RemoveFavorite"

    #define ShareCopyEvent                          @"ShareCopy"
    #define ShareMailEvent                          @"ShareMail"
    #define ShareSMSEvent                           @"ShareSMS"
    #define PreviousPageEvent                       @"PreviousPage"
    #define NextPageEvent                           @"NextPage"
    #define CheckNewVersionEvent                    @"CheckNewVersion"
    #define PinchZoomInOutEvent                     @"PinchZoomInOut"
    #define SwitchLatestAlertCategoryEvent          @"SwitchLatestAlertCategory"
    #define RefreshAllLatestAlertsEvent             @"RefreshAllLatestAlerts"
    #define MarkAllLatestAlertsReadEvent            @"MarkAllLatestAlertsRead"
    #define EnterAlertRuleFromLatestAlertEvent      @"EnterAlertRuleFromLatestAlert"
    #define LatestAlertFilterEvent                  @"LatestAlertFilter"
    #define CallUsEvent                             @"CallUs"
    #define CallUsViaEmailEvent                     @"CallUsViaEmail"
    #define ChangePassWordEvent                     @"ChangePassWord"
    #define UpLoadLogEvent                          @"UpLoadLog"
    #define NewAlertRuleEvent                       @"NewAlertRule"
    #define DeleteAlertRuleEvent                    @"DeleteAlertRule"
    #define AlertDistributeEvent                    @"AlertDistribute"
    #define ClickDistributeAlertEvent               @"ClickDistributeAlert"
    #define DoForwardEvent                          @"DoForward"
    #define CreateNewAlertEvent                     @"CreateNewAlert"

#endif














