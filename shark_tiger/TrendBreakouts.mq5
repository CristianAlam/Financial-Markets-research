//+------------------------------------------------------------------+
//|                                               TrendBreakouts.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#define NUM_WEEKS_RESEARCH 48
#include "Algo_Skeleton_Functions.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int bullishCandlesCount = 0 ;
int conditionMetBullish = 0 ;
int secondConditionMetBullish = 0;
int bearishCandlesCount = 0;
int conditionMetBearish = 0 ;
int secondConditionMetBearish = 0 ;

input group "Conditions"
input bool firstCondition = false ;
input bool secondCondition = false ;
input bool noCondition = false ;

int OnInit()
  {
//---

//---
  /* string fileName = "First_Condition_Bullish.csv" ; // if you want to find the csv file, go to file -> open data folder -> mql5 -> files .  all from the visual mode
   int fileHandle = FileOpen(fileName,FILE_READ|FILE_WRITE |FILE_CSV|FILE_ANSI);

   FileSeek(fileHandle,0,SEEK_END);
   FileWrite(fileHandle,"-----","Size of Week 1","Size of Week 2", "Monday", "Tuesday","Wednesday","Thursday","Friday","Retracement Measure","Low below previous close","Day of lowest point"); */
   
   
   string fileName1 = "First_Condition_Bearish.csv" ; // if you want to find the csv file, go to file -> open data folder -> mql5 -> files .  all from the visual mode
   int fileHandle1 = FileOpen(fileName1,FILE_READ|FILE_WRITE |FILE_CSV|FILE_ANSI);

   FileSeek(fileHandle1,0,SEEK_END);
   FileWrite(fileHandle1,"-----","Size of Week 1","Size of Week 2", "Monday", "Tuesday","Wednesday","Thursday","Friday","Retracement Measure","High above previous close","Day of Highest point");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Count: "+ bullishCandlesCount + " First Condition: " + conditionMetBullish + " Second Condition: " + secondConditionMetBullish);
   Print("Count: "+ bearishCandlesCount + " First Condition: " + conditionMetBearish + " Second Condition: " + secondConditionMetBearish);


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




     }

   int shift = 2 ;
   if(newCandleDetectorWeekly.isNewCandle())
     {
      objectsManager.drawVerticalLine(clrRed, TimeCurrent());

      if(candleClosedBullish(PERIOD_W1,shift))
        {
         if(!bullishCandleIsWeak(PERIOD_W1,shift,WICK_RATIO_REJECTION))
           {

            bullishCandlesCount++ ;
            
            if(firstCondition){
                   if((iHigh(_Symbol,PERIOD_W1,1) > iHigh(_Symbol,PERIOD_W1,2)) && (iLow(_Symbol,PERIOD_W1,1) >iLow(_Symbol,PERIOD_W1,2)))
              {              
               saveInCsv("firstCondition_Bullish.csv");
               conditionMetBullish++ ;
              }
            }
           
            if(secondCondition){
               if((iHigh(_Symbol,PERIOD_W1,1) > iClose(_Symbol,PERIOD_W1,2)) && (iLow(_Symbol,PERIOD_W1,1) > iLow(_Symbol,PERIOD_W1,2)))
              {
                  saveInCsv("secondCondition_Bullish.csv");
                  secondConditionMetBullish++ ;
              }
            }
            
            if(noCondition){
               saveInCsv("noCondition_Bullish.csv");
               
            }

            
           }

        }

      if(candleClosedBearish(PERIOD_W1,shift))
        {

         if(!bearishCandleIsWeak(PERIOD_W1,shift,WICK_RATIO_REJECTION))
           {

            bearishCandlesCount++ ;
            if((iLow(_Symbol,PERIOD_W1,1) < iLow(_Symbol,PERIOD_W1,2)) && (iHigh(_Symbol,PERIOD_W1,1) < iHigh(_Symbol,PERIOD_W1,2)))
              {
               conditionMetBearish++ ;
              }


            if((iLow(_Symbol,PERIOD_W1,1) < iClose(_Symbol,PERIOD_W1,2)) && (iHigh(_Symbol,PERIOD_W1,1) < iHigh(_Symbol,PERIOD_W1,2)))
              {
               secondConditionMetBearish++ ;
              }



           }

        }

      //Print("bearish candles count: " + bearishCandlesCount);
      //Print("bullish canldes count: " + bullishCandlesCount);

     }

  }
//+------------------------------------------------------------------+


void saveInCsv(string csvFileName){
int lastWeekDaysArr[5] ;
               for(int i=0; i<5; i++)
                 {
                  lastWeekDaysArr[i]= -1;
                 }
               for(int i=5 ; i>0 ; i--)
                 {
                  if(candleClosedBullish(PERIOD_D1,i))
                    {
                     lastWeekDaysArr[5-i] = 1 ;
                    }
                  if(candleClosedBearish(PERIOD_D1,i))
                    {
                     lastWeekDaysArr[5-i] = 0 ;
                    }
                 }
                 
               double firstWeekSize = iHigh(_Symbol,PERIOD_W1,2) - iLow(_Symbol,PERIOD_W1,2) ;
               double secondWeekSize = iHigh(_Symbol,PERIOD_W1,1) - iLow(_Symbol,PERIOD_W1,1) ;
               
               
               datetime time = iTime(_Symbol,PERIOD_W1,2);
               string timeInStr = TimeToString(time,TIME_DATE);
               
               string fileName = csvFileName ; // if you want to find the csv file, go to file -> open data folder -> mql5 -> files .  all from the visual mode
               int fileHandle = FileOpen(fileName,FILE_READ|FILE_WRITE/* |FILE_CSV|FILE_ANSI*/);
               
               
               
               FileSeek(fileHandle,0,SEEK_END);
               FileWrite(fileHandle,timeInStr,firstWeekSize,secondWeekSize,lastWeekDaysArr[0],lastWeekDaysArr[1],lastWeekDaysArr[2],lastWeekDaysArr[3],lastWeekDaysArr[4]);

               FileClose(fileHandle);
}