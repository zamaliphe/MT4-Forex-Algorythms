#define INAME     "FFC"
#define TITLE		0
#define COUNTRY	1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6
//-------------------------------------------- EXTERNAL VARIABLE ---------------------------------------------
//------------------------------------------------------------------------------------------------------------
 bool    ReportActive      = false;                // Report for active chart only (override other inputs)
 bool    IncludeHigh       = true;                 // Include high
 bool    IncludeMedium     = false;                 // Include medium
 bool    IncludeLow        = false;                 // Include low
 bool    IncludeSpeaks     = false;                 // Include speaks
 bool    IncludeHolidays   = false;                // Include holidays
 string  FindKeyword       = "";                   // Find keyword
 string  IgnoreKeyword     = "";                   // Ignore keyword
 bool    AllowUpdates      = true;                 // Allow updates
 int     UpdateHour        = 4;                    // Update every (in hours)
 string   lb_0              = "";                   // ------------------------------------------------------------
 string   lb_1              = "";                   // ------> PANEL SETTINGS
 bool    ShowPanel         = true;                 // Show panel
 bool    AllowSubwindow    = false;                // Show Panel in sub window
 ENUM_BASE_CORNER Corner   = 2;                    // Panel side
 string  PanelTitle="Forex Calendar @ Forex Factory"; // Panel title
 color   TitleColor        = C'46,188,46';         // Title color
 bool    ShowPanelBG       = true;                 // Show panel backgroud
 color   Pbgc              = C'25,25,25';          // Panel backgroud color
 color   LowImpactColor    = C'91,192,222';        // Low impact color 
 color   MediumImpactColor = C'255,185,83';        // Medium impact color      
 color   HighImpactColor   = C'217,83,79';         // High impact color
 color   HolidayColor      = clrOrchid;            // Holidays color
 color   RemarksColor      = clrGray;              // Remarks color
 color   PreviousColor     = C'170,170,170';       // Forecast color
 color   PositiveColor     = C'46,188,46';         // Positive forecast color
 color   NegativeColor     = clrTomato;            // Negative forecast color
 bool    ShowVerticalNews  = true;                 // Show vertical lines
 int     ChartTimeOffset   = 0;                    // Chart time offset (in hours)
 int     EventDisplay      = 10;                   // Hide event after (in minutes)
 string   lb_2              = "";                   // ------------------------------------------------------------
 string   lb_3              = "";                   // ------> SYMBOL SETTINGS
 bool    ReportForUSD      = true;                 // Report for USD
 bool    ReportForEUR      = true;                 // Report for EUR
 bool    ReportForGBP      = true;                 // Report for GBP
 bool    ReportForNZD      = true;                 // Report for NZD
 bool    ReportForJPY      = true;                 // Report for JPY
 bool    ReportForAUD      = true;                 // Report for AUD
 bool    ReportForCHF      = true;                 // Report for CHF
 bool    ReportForCAD      = true;                 // Report for CAD
 bool    ReportForCNY      = false;                // Report for CNY
 string   lb_4              = "";                   // ------------------------------------------------------------
 string   lb_5              = "";                   // ------> INFO SETTINGS
 bool    ShowInfo          = true;                 // Show Symbol info ( Strength / Bar Time / Spread )
 color   InfoColor         = C'255,185,83';        // Info color
 int     InfoFontSize      = 8;                    // Info font size
 string   lb_6              = "";                   // ------------------------------------------------------------
 string   lb_7              = "";                   // ------> NOTIFICATION
 string   lb_8              = "";                   // *Note: Set (-1) to disable the Alert
 int     Alert1Minutes     = 30;                   // Minutes before first Alert 
 int     Alert2Minutes     = -1;                   // Minutes before second Alert
 bool    PopupAlerts       = false;                // Popup Alerts
 bool    SoundAlerts       = true;                 // Sound Alerts
 string  AlertSoundFile    = "news.wav";           // Sound file name
 bool    EmailAlerts       = false;                // Send email
 bool    NotificationAlerts= false;                // Send push notification
//------------------------------------------------------------------------------------------------------------
//--------------------------------------------- INTERNAL VARIABLE --------------------------------------------
//--- Vars and arrays
string xmlFileName;
string sData;
string Event[200][7];
string eTitle[10],eCountry[10],eImpact[10],eForecast[10],ePrevious[10];
int eMinutes[10];
datetime eTime[10];
string eNewsDate[10];
int anchor,x0,x1,x2,xf,xp;
int Factor;
//--- Alert
bool FirstAlert;
bool SecondAlert;
datetime AlertTime;
//--- Buffers
double MinuteBuffer[];
double ImpactBuffer[];
//--- time
datetime xmlModifed;
int TimeOfDay;
datetime Midnight;
bool IsEvent;
//Update Forex Factory
void UpdateForexFactory()
{
      xmlFileName="FFC-ffcal_week_this.xml";
      if(!FileIsExist(xmlFileName)){xmlDownload();xmlRead();}
      else {xmlDownload();xmlRead();}
}



void xmlDownload()
  {
//---
   ResetLastError();
   string sUrl="http://www.forexfactory.com/ff_calendar_thisweek.xml";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\",xmlFileName);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);

//--- check for errors   
  
//---
  }
//+------------------------------------------------------------------+
//| Read the XML file                                                |
//+------------------------------------------------------------------+
void xmlRead()
  {
//---
   ResetLastError();
   int FileHandle=FileOpen(xmlFileName,FILE_BIN|FILE_READ);
   if(FileHandle!=INVALID_HANDLE)
     {
      //--- receive the file size 
      ulong size=FileSize(FileHandle);
      //--- read data from the file
      while(!FileIsEnding(FileHandle))
         sData=FileReadString(FileHandle,(int)size);
      //--- close
      FileClose(FileHandle);
     }

//---
  }
//+------------------------------------------------------------------+
//| Check for update XML                                             |
//+------------------------------------------------------------------+
void xmlUpdate()
  {
//--- do not download on saturday
   if(TimeDayOfWeek(Midnight)==6) return;
   else
     {

      FileDelete(xmlFileName);
      xmlDownload();
      xmlRead();
      xmlModifed=(datetime)FileGetInteger(xmlFileName,FILE_MODIFY_DATE,false);

     }
//---
  }




void ExtractNewsData()
{
//---
//--- BY AUTHORS WITH SOME MODIFICATIONS
//--- define the XML Tags, Vars
   string sTags[7]={"<title>","<country>","<date><![CDATA[","<time><![CDATA[","<impact><![CDATA[","<forecast><![CDATA[","<previous><![CDATA["};
   string eTags[7]={"</title>","</country>","]]></date>","]]></time>","]]></impact>","]]></forecast>","]]></previous>"};
   int index=0;
   int next=-1;
   int BoEvent=0,begin=0,end=0;
   string myEvent="";
//--- Minutes calculation
   datetime EventTime=0;
   int EventMinute=0;
//--- split the currencies into the two parts 
   string MainSymbol=StringSubstr(Symbol(),0,3);
   string SecondSymbol=StringSubstr(Symbol(),3,3);
//--- loop to get the data from xml tags
   while(true)
     {
      BoEvent=StringFind(sData,"<event>",BoEvent);
      if(BoEvent==-1) break;
      BoEvent+=7;
      next=StringFind(sData,"</event>",BoEvent);
      if(next == -1) break;
      myEvent = StringSubstr(sData,BoEvent,next-BoEvent);
      BoEvent = next;
      begin=0;
      for(int i=0; i<7; i++)
        {
         Event[index][i]="";
         next=StringFind(myEvent,sTags[i],begin);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next==-1) continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin=next+StringLen(sTags[i]);
            end=StringFind(myEvent,eTags[i],begin);
            //---Find start of end tag and Get data between start and end tag
            if(end>begin && end!=-1)
               Event[index][i]=StringSubstr(myEvent,begin,end-begin);
           }
        }
      //--- filters that define whether we want to skip this particular currencies or events
      if(ReportActive && MainSymbol!=Event[index][COUNTRY] && SecondSymbol!=Event[index][COUNTRY])
         continue;
      if(!IsCurrency(Event[index][COUNTRY]))
         continue;
      if(!IncludeHigh && Event[index][IMPACT]=="High")
         continue;
      if(!IncludeMedium && Event[index][IMPACT]=="Medium")
         continue;
      if(!IncludeLow && Event[index][IMPACT]=="Low")
         continue;
      if(!IncludeSpeaks && StringFind(Event[index][TITLE],"Speaks")!=-1)
         continue;
      if(!IncludeHolidays && Event[index][IMPACT]=="Holiday")
         continue;
      if(Event[index][TIME]=="All Day" ||
         Event[index][TIME]=="Tentative" ||
         Event[index][TIME]=="")
         continue;
      if(FindKeyword!="")
        {
         if(StringFind(Event[index][TITLE],FindKeyword)==-1)
            continue;
        }
      if(IgnoreKeyword!="")
        {
         if(StringFind(Event[index][TITLE],IgnoreKeyword)!=-1)
            continue;
        }
      //--- sometimes they forget to remove the tags :)
      if(StringFind(Event[index][TITLE],"<![CDATA[")!=-1)
         StringReplace(Event[index][TITLE],"<![CDATA[","");
      if(StringFind(Event[index][TITLE],"]]>")!=-1)
         StringReplace(Event[index][TITLE],"]]>","");
      if(StringFind(Event[index][TITLE],"]]>")!=-1)
         StringReplace(Event[index][TITLE],"]]>","");
      //---
      if(StringFind(Event[index][FORECAST],"&lt;")!=-1)
         StringReplace(Event[index][FORECAST],"&lt;","");
      if(StringFind(Event[index][PREVIOUS],"&lt;")!=-1)
         StringReplace(Event[index][PREVIOUS],"&lt;","");

      //--- set some values (dashes) if empty
      if(Event[index][FORECAST]=="") Event[index][FORECAST]="---";
      if(Event[index][PREVIOUS]=="") Event[index][PREVIOUS]="---";
      //--- Convert Event time to MT4 time
      EventTime=datetime(MakeDateTime(Event[index][DATE],Event[index][TIME]));
      //--- calculate how many minutes before the event (may be negative)
      EventMinute=int(EventTime-TimeGMT())/60;
      //--- only Alert once
      if(EventMinute==0 && AlertTime!=EventTime)
        {
         FirstAlert =false;
         SecondAlert=false;
         AlertTime=EventTime;
        }
      //--- Remove the event after x minutes
      if(EventMinute+EventDisplay<0) continue;
      //--- Set buffers
      MinuteBuffer[index]=EventMinute;
      ImpactBuffer[index]=ImpactToNumber(Event[index][IMPACT]);
      index++;
     }
//--- loop to set arrays/buffers that uses to draw objects and alert
   for(int icc=0; icc<index; icc++)
     {
      for(int n=icc; n<10; n++)
        {
         eTitle[n]    = Event[icc][TITLE];
         eCountry[n]  = Event[icc][COUNTRY];
         eImpact[n]   = Event[icc][IMPACT];
         eForecast[n] = Event[icc][FORECAST];
         ePrevious[n] = Event[icc][PREVIOUS];
         eTime[n]     = datetime(MakeDateTime(Event[icc][DATE],Event[icc][TIME]))-TimeGMTOffset()+3600;
         eNewsDate[n] = Event[icc][DATE] + " " + Event[icc][TIME];
         eMinutes[n]  = (int)MinuteBuffer[icc];
         //--- Check if there are any events
        
        }

     }

      
  
  }
bool IsCurrency(string symbol)
  {
//---
   if(ReportForUSD && symbol == "USD") return(true);
   else if(ReportForGBP && symbol == "GBP") return(true);
   else if(ReportForEUR && symbol == "EUR") return(true);
   else if(ReportForCAD && symbol == "CAD") return(true);
   else if(ReportForAUD && symbol == "AUD") return(true);
   else if(ReportForCHF && symbol == "CHF") return(true);
   else if(ReportForJPY && symbol == "JPY") return(true);
   else if(ReportForNZD && symbol == "NZD") return(true);
   else if(ReportForCNY && symbol == "CNY") return(true);
   return(false);
//---
  }
  
  
  string MakeDateTime(string strDate,string strTime)
  {
//---
   int n1stDash=StringFind(strDate, "-");
   int n2ndDash=StringFind(strDate, "-", n1stDash+1);

   string strMonth=StringSubstr(strDate,0,2);
   string strDay=StringSubstr(strDate,3,2);
   string strYear=StringSubstr(strDate,6,4);

   int nTimeColonPos=StringFind(strTime,":");
   string strHour=StringSubstr(strTime,0,nTimeColonPos);
   string strMinute=StringSubstr(strTime,nTimeColonPos+1,2);
   string strAM_PM=StringSubstr(strTime,StringLen(strTime)-2);

   int nHour24=StrToInteger(strHour);
   if((strAM_PM=="pm" || strAM_PM=="PM") && nHour24!=12) nHour24+=12;
   if((strAM_PM=="am" || strAM_PM=="AM") && nHour24==12) nHour24=0;
   string strHourPad="";
   if(nHour24<10) strHourPad="0";
   return(StringConcatenate(strYear, ".", strMonth, ".", strDay, " ", strHourPad, nHour24, ":", strMinute));
//---
  }
//+---------------

int ImpactToNumber(string impact)
  {
//---
   if(impact == "High") return(3);
   else if(impact == "Medium") return(2);
   else if(impact == "Low") return(1);
   else return(0);
//---
  }
  
  
  
  
  
  //Populate News on the Chart
  void PopulateNewsOnChart(string User, string &CurrentCurrToTrade,datetime &CurrentDateTimeLeftToTrade, int Step)
  {
  
     ObjectsDeleteAll();
ManageProfitOnChart();
color MintColor = C'117,187,154';
color DarkBlueColor = C'51,63,80';
   
   CurrentCurrToTrade= GetSymbolToTrade(eCountry[0]);
   CurrentDateTimeLeftToTrade= eTime[0]-TimeCurrent();
   
   //Create Dashboard Login
    EditCreate("BackgroundLine1",0,10,10000,5,"FX Divergence",MintColor,MintColor);
   EditCreate("BackgroundLine2",10,0,5,10000,"FX Divergence",DarkBlueColor,DarkBlueColor);


   EditCreate("LogoHeader",20,30,300,20,"FX Divergence",MintColor,clrBlack);
   
   EditCreate("EAHeader",20,50,300,20,"MyNews EA v.2",MintColor,clrBlack);
   
   EditCreate("ServerTimeHeader",20,70,100,20,"Server time:",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("ServerTimeValue",120,70,200,20,TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),clrWhite,clrBlack);
   
   EditCreate("UserHeader",20,90,100,20,"User:",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("UserValue",120,90,200,20,User,clrWhite,clrBlack);
   
   EditCreate("LicenseHeader",20,110,100,20,"Trading Status:",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("LicenseValue",120,110,200,20,Step,clrWhite,clrBlack);

   
   
   //Create Profit windows
   
   
   
   //Create news table
   EditCreate("Header1",20,170,200,20,"Date",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("Header2",220,170,200,20,"Type",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("Header3",420,170,100,20,"Country",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("Header4",520,170,100,20,"Symbol",DarkBlueColor,clrBlack,clrWhite);
   EditCreate("Header5",620,170,150,20,"Timer",DarkBlueColor,clrBlack,clrWhite);



      int PixCounter = 190;
    for(int ncc=0; ncc<10; ncc++)
         {
         
         
         
            int secondsleft = eTime[ncc]-TimeCurrent();
   
          
            int h,m,s;
            s=secondsleft%60;
            m=((secondsleft-s)/60)%60;
            h=(secondsleft-s-m*60)/3600;
            
            
   
            EditCreate("Header1" + PixCounter,20,PixCounter,200,20,TimeToStr(eTime[ncc],TIME_DATE|TIME_SECONDS),clrWhite,clrBlack);
            EditCreate("Header2" + PixCounter,220,PixCounter,200,20,eTitle[ncc],clrWhite,clrBlack);
            EditCreate("Header3" + PixCounter,420,PixCounter,100,20,eCountry[ncc] ,clrWhite,clrBlack);
            EditCreate("Header4" + PixCounter,520,PixCounter,100,20,GetSymbolToTrade(eCountry[ncc]),clrWhite,clrBlack);
            EditCreate("Header5" + PixCounter,620,PixCounter,150,20, h + " h " + m + " min " + s + " sec",clrWhite,clrBlack);
                PixCounter = PixCounter + 20;  

         }
         
    
  
  
  }
  
  
string GetSymbolToTrade(string Currency)
{

   string ReturnSymbol = "";
   
   if (Currency=="USD"){ReturnSymbol = "EURUSD";}
   if (Currency=="GBP"){ReturnSymbol = "GBPUSD";}
   if (Currency=="JPY"){ReturnSymbol = "USDJPY";}
   if (Currency=="CHF"){ReturnSymbol = "USDCHF";}
   if (Currency=="NZD"){ReturnSymbol = "NZDUSD";}
   if (Currency=="AUD"){ReturnSymbol = "AUDUSD";}
   if (Currency=="CAD"){ReturnSymbol = "USDCAD";}
   if (Currency=="EUR"){ReturnSymbol = "EURUSD";}

   return ReturnSymbol;
}
  
  
  
  
  
  
  //+------------------------------------------------------------------+
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool EditCreate(  
               const string           name="test1",              // object name
               const int              x=0,                      // X coordinate
                const int              y=30,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
               const string           text="Text",                // Text
               const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrBlack,       // border color
                const color            clr=clrBlack,             // text color
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
               const long             chart_ID=0,               // chart's ID
                const int              sub_window=0,             // subwindow index
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=true,          // ability to edit
                
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create edit field
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  
  void ManageProfitOnChart()
{
   if((AccountEquity()-AccountBalance())!=0)
   {     
      if(ObjectFind(0,"ProfitDollar")<0){EditCreate("ProfitDollar",350,30,370,100," ",clrRed,clrBlack,clrWhite,CORNER_LEFT_UPPER);}
      if((AccountEquity()-AccountBalance())>0)
      {
         ObjectSetString(0,"ProfitDollar",OBJPROP_TEXT,NormalizeDouble((AccountEquity()-AccountBalance()),2) + " $");
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BGCOLOR,clrGreen);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BORDER_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_FONTSIZE,30);
      }
      else
      {
         ObjectSetString(0,"ProfitDollar",OBJPROP_TEXT,NormalizeDouble((AccountEquity()-AccountBalance()),2) + " $");
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BORDER_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_FONTSIZE,30);
      }
   }
   else
   {
    if(ObjectFind(0,"ProfitDollar")<0){EditCreate("ProfitDollar",350,30,370,100," ",clrRed,clrBlack,clrWhite,CORNER_LEFT_UPPER);}
         ObjectSetString(0,"ProfitDollar",OBJPROP_TEXT,"No Trades Opened");
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BGCOLOR,clrDimGray);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_BORDER_COLOR,clrBlack);
         ObjectSetInteger(0,"ProfitDollar",OBJPROP_FONTSIZE,30);
   
   }
}
