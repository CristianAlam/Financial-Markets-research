//+------------------------------------------------------------------+
//|                                          Point_Value_Testing.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#property script_show_inputs
//--- day of week
enum Confirmation_HTF
  {
   H4_Break= 0,
   H4_Closure = 1,
  };
//--- input parameters
input Confirmation_HTF H4_CONFIRMATION  ;

input int someNumber ;
int OnInit()
  {
//---
   
//---
   if(!ChartScreenShot(0,"somefile.png",1260,720,ALIGN_CENTER)){
      Print("failed to take screenshot , Error: " + GetLastError());
   }
   Print("Point value of this pair :" + Point());
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
