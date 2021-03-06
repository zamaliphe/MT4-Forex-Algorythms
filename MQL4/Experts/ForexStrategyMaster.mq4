//+------------------------------------------------------------------+
//|                                          ForexStrategyMaster.mq4 |
//|                                                  Michal Papinski |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Michal Papinski"
#property link      ""
#property version   "1.00"
#property strict


// User Settings
input string SectionStrategy1= "Strategy 1";
extern bool Strategy1Active = false;
extern int Strategy1TP = 10;
extern int Strategy1SL = 10;
input string SectionStrategy2= "Strategy 2";
extern bool Strategy2Active = false;
extern int Strategy2TP = 10;
extern int Strategy2SL = 10;
input string SectionStrategy3= "Strategy 3";
extern bool Strategy3Active = false;
extern int Strategy3TP = 10;
extern int Strategy3SL = 10;
input string SectionStrategy4= "Strategy 4";
extern bool Strategy4Active = false;
extern int Strategy4TP = 10;
extern int Strategy4SL = 10;


// Define Indicator Variables
double EMA3Period1H = 0;
double EMA5Period1H = 0;
double EMA15Period1H = 0;
double EMA45Period1H = 0;
double EMA3Period15M = 0;
double EMA5Period15M = 0;
double EMA15Period15M = 0;
double EMA45Period15M = 0;
int GHL1H = 0;
int QTI1H = 0;
int GHL15M = 0;
int QTI15M = 0;
int AllEMATrend = 0;


//Strategy Variables
int Strategy1CurrentTradeType = 0;
int Strategy1CurrentStep = 0;
int Strategy2CurrentTradeType = 0;
int Strategy2CurrentStep = 0;
int Strategy3CurrentTradeType = 0;
int Strategy3CurrentStep = 0;
int Strategy4CurrentTradeType = 0;
int Strategy4CurrentStep = 0;


// Include
#include <ForexStrategyMasterStrategy1.mqh>
#include <ForexStrategyMasterStrategy2.mqh>
#include <ForexStrategyMasterStrategy3.mqh>
#include <ForexStrategyMasterStrategy4.mqh>
#include <ForexStrategyMasterDashboard.mqh>
#include <ForexStrategyMasterIndicators.mqh>
//+------------------------------------------------------------------+
//| START EA                                                         |
//+------------------------------------------------------------------+

void init()
{
//ChartApplyTemplate(0,"forex strategy master");
DrawDashboard();



}

void start()
{



// Calculate Indicators variables
EMA3Period1H = CalculateEMA3(PERIOD_H1);
EMA5Period1H = CalculateEMA5(PERIOD_H1);
EMA15Period1H = CalculateEMA15(PERIOD_H1);
EMA45Period1H = CalculateEMA45(PERIOD_H1);
EMA3Period15M = CalculateEMA3(PERIOD_M15);
EMA5Period15M = CalculateEMA5(PERIOD_M15);
EMA15Period15M = CalculateEMA15(PERIOD_M15);
EMA45Period15M = CalculateEMA45(PERIOD_M15);
GHL1H = CalculateGHL (PERIOD_H1) ;
QTI1H = CalculateQTI (PERIOD_H1) ;
GHL15M = CalculateGHL (PERIOD_M15) ;
QTI15M = CalculateQTI (PERIOD_M15) ;
AllEMATrend = CalculateAllEMATrend(PERIOD_H1);

//Run Strategies
if(Strategy1Active==true){Strategy1CheckStatus(Strategy1CurrentStep,Strategy1CurrentTradeType,EMA3Period1H,EMA5Period1H,EMA15Period1H,EMA45Period1H,GHL1H,QTI1H,EMA3Period15M,EMA5Period15M,EMA15Period15M,EMA45Period15M,GHL15M,QTI15M,Strategy1TP,Strategy1SL,AllEMATrend);}
if(Strategy2Active==true){Strategy2CheckStatus(Strategy2CurrentStep,Strategy2CurrentTradeType,EMA3Period1H,EMA5Period1H,EMA15Period1H,EMA45Period1H,GHL1H,QTI1H,EMA3Period15M,EMA5Period15M,EMA15Period15M,EMA45Period15M,GHL15M,QTI15M,Strategy2TP,Strategy2SL,AllEMATrend);}
if(Strategy3Active==true){Strategy3CheckStatus(Strategy3CurrentStep,Strategy3CurrentTradeType,EMA3Period1H,EMA5Period1H,EMA15Period1H,EMA45Period1H,GHL1H,QTI1H,EMA3Period15M,EMA5Period15M,EMA15Period15M,EMA45Period15M,GHL15M,QTI15M,Strategy3TP,Strategy3SL,AllEMATrend);}
if(Strategy4Active==true){Strategy4CheckStatus(Strategy4CurrentStep,Strategy4CurrentTradeType,EMA3Period1H,EMA5Period1H,EMA15Period1H,EMA45Period1H,GHL1H,QTI1H,EMA3Period15M,EMA5Period15M,EMA15Period15M,EMA45Period15M,GHL15M,QTI15M,Strategy4TP,Strategy4SL,AllEMATrend);}




//Update Dashboard
UpdateDashboard(Strategy1CurrentStep,Strategy1CurrentTradeType,Strategy2CurrentStep,Strategy2CurrentTradeType,Strategy3CurrentStep,Strategy3CurrentTradeType,Strategy4CurrentStep,Strategy4CurrentTradeType,EMA3Period1H,EMA5Period1H,EMA15Period1H,EMA45Period1H,GHL1H,QTI1H,EMA3Period15M,EMA5Period15M,EMA15Period15M,EMA45Period15M,GHL15M,QTI15M,AllEMATrend);


}



void deinit()
{ 

}

