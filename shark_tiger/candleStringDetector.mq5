//+------------------------------------------------------------------+
//|                                         candleStringDetector.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include "Algo_Skeleton_Functions.mqh"

int last_Color_candle = -1 ;
int daily_streak_counter = 0 ;

string timeInStr = "--" ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---



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

   if(newCandleDetectorDaily.isNewCandle())
     {
      //objectsManager.drawVerticalLine(clrAliceBlue, TimeCurrent());
      if(candleClosedBullish(PERIOD_D1,1) && last_Color_candle != 1)  // this is the first daily bullish candle
        {

         // save  the timeInStr and the daily streak counter in a row in excel
         string fileName = "daily_candle_streak.csv" ; // if you want to find the csv file, go to file -> open data folder -> mql5 -> files .  all from the visual mode
         int fileHandle = FileOpen(fileName,FILE_READ|FILE_WRITE/* |FILE_CSV|FILE_ANSI*/);
         FileSeek(fileHandle,0,SEEK_END);
         FileWrite(fileHandle,timeInStr,daily_streak_counter);

         FileClose(fileHandle);

         datetime time = TimeCurrent(); // save the date of this day
         timeInStr = TimeToString(time,TIME_DATE);
         last_Color_candle = 1 ; // convert the flag to bullish
         daily_streak_counter = 0 ; // reset the counter

        }
      else if(candleClosedBullish(PERIOD_D1,1) && last_Color_candle == 1)
        {

         daily_streak_counter++ ;
        }


      if(candleClosedBearish(PERIOD_D1,1) && last_Color_candle != 0)  // this is the first daily bearish candle
        {

         // save  the timeInStr and the daily streak counter in a row in excel
         string fileName = "daily_candle_streak.csv" ; // if you want to find the csv file, go to file -> open data folder -> mql5 -> files .  all from the visual mode
         int fileHandle = FileOpen(fileName,FILE_READ|FILE_WRITE/* |FILE_CSV|FILE_ANSI*/);
         FileSeek(fileHandle,0,SEEK_END);
         FileWrite(fileHandle,timeInStr,daily_streak_counter);

         FileClose(fileHandle);

         datetime time = TimeCurrent();
         timeInStr = TimeToString(time,TIME_DATE);
         last_Color_candle = 0 ;
         daily_streak_counter = 0;
        }
        
        else if(candleClosedBearish(PERIOD_D1,1) && last_Color_candle == 0){
         daily_streak_counter++ ;
        }


     }

  }
//+------------------------------------------------------------------+
