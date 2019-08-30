//+------------------------------------------------------------------+
//|                                              DLLSampleTester.mq4 |
//|                 Copyright © 2005-2016, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005-2016, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#import "hello-world.dll"
int    GetIntValue(int);
double GetDoubleValue(double);
string GetStringValue(string);
double GetArrayItemValue(double &arr[],int,int);
bool   SetArrayItemValue(double &arr[],int,int,double);
double GetRatesItemValue(MqlRates &rates[],int,int,int);
int GetStringValueDupa(int);
bool DupaMessageBox(int);
#import

#define TIME_INDEX   0
#define OPEN_INDEX   1
#define LOW_INDEX    2
#define HIGH_INDEX   3
#define CLOSE_INDEX  4
#define VOLUME_INDEX 5
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   double ret;
   string sret;
   int    cnt;

   ret=GetDoubleValue(11);
   Print("Returned value is ",ret);

   sret=GetStringValue("some string");
   Print("Returned value is ",sret);
   
   if(
   DupaMessageBox(1)==true
  // 1==1
  )
   
   {
   Comment("YES");
   }
   else
   {
   Comment("NO");
   }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| array functions call                                             |
//+------------------------------------------------------------------+
int start()
  {
 // Comment(GetStringValue("dupa"));
  }
//+------------------------------------------------------------------+
