//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "Algo_Skeleton_Functions.mqh"

int OnInit()
  {
//--- create timer
   EventSetTimer(60);

// ONLY FOR VISULAZITAION ON STRATEGY TESTER
   iClose(_Symbol,PERIOD_W1,1);
   iClose(_Symbol,PERIOD_D1,1);
   iClose(_Symbol,PERIOD_H4,5);
   iClose(_Symbol,PERIOD_H1,5);
   iClose(_Symbol,PERIOD_M30,5);
   iClose(_Symbol,PERIOD_M15,5);

   objectsManager.addTextTiger();

   for(int i=0; i<NUM_MAX_ALLOWED_TRADES ; i++)
     {
      BuyActiveTradesArray[i] = NULL ;
      SellActiveTradesArray[i] = NULL ;

     }






//objectsManager.addMarketDescriptionTextTiger();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   Print("Buys Count: " + buysCount);
   Print("Sells Count: " + sellsCount);
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   cleanBuyTradesArr();
   cleanSellTradesArr();
   secureProfitIfNeeded();

   if(newCandleDetectorM15.isNewCandle())
     {
      
      manageRiskIfNeeded();

     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetector30M.isNewCandle())
     {

      //Print("zone coutner is: "+ zoneContainer_M30.getNumberOfActiveZones());
      trailAllOpenPositionsIfNeeded(PERIOD_M30);
      //Print("number of opened orders are: " + PositionsTotal());
      // DETECTING SUPPORTS AND RESISTANCES
      detectAndDrawResistanceOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrPink,clrBlue,zoneContainer_M30);
      detectAndDrawSupportOnTimeFrame(PERIOD_M30,"PERIOD_M30",clrYellow,clrGreen,zoneContainerSupport_M30);



      // VARIABLE PREPROCESSING FOR BOS
      double brokenResistanceLowerPrice = -1 ;
      string brokenZoneTypeResistance = "" ;

      double brokenSupportHigherPrice = -1;
      string brokenZoneTypeSupport = "" ;

      // BREAK OF STRUCTURE HANDLING

      if(updateBreakAboveStructureAndDelete(zoneContainer_M30,PERIOD_M30,"PERIOD_M30",brokenResistanceLowerPrice,brokenZoneTypeResistance)
         && buyBreakerCandleIsValid(PERIOD_M30, SIZE_OF_BREAKER_CANDLE_BODY)
         && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED)) && BUYS_ALLOWED)   // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
        {

         double firstResistancePrice = findClosestResistancePrice(zoneContainer_M30);
         double cleanRangeValueBuys = firstResistancePrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK);


         if(firstResistancePrice != -1 && brokenZoneTypeResistance == "TYPE_RESISTANCE_BREAKOUT")
           {
            Comment("M30 candle Broke and closed above the zone. the closest resistance price is:" + DoubleToString(firstResistancePrice));
            if(cleanRangeValueBuys >= cleanRangeUponEntry)
              {

               double stopLossBased_H1  = iLow(_Symbol,PERIOD_H1,1);
               double stopLossBased_M30  = iLow(_Symbol,PERIOD_M30,1);
               double stopLossBased_M15 = iLow(_Symbol,PERIOD_M15,1);

               stopLossBased_H1 = stopLossBased_H1 - stopLossUnderWickBy ;
               stopLossBased_M30 = stopLossBased_M30 - stopLossUnderWickBy ;
               stopLossBased_M15 = stopLossBased_M15 - stopLossUnderWickBy ;

               if(stopLossIsValidBuys(stopLossBased_M30, maxPipsRiskAmount))
                 {

                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M30);
                  int indexToNewTrade ;
                  if((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1)   // find a spot in the trades array, and save the result
                    {
                     Print("The free index found is: " + indexToNewTrade);
                     activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToEnter,stopLossBased_M30) ;

                     BuyTradeManagerTiger* tempTigerManager= new BuyTradeManagerTiger(activeTradeId); // create an object of type buyTradeManagerTiger
                     BuyActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                     buysCount++;

                     Comment("Took a buy. stop loss: based on M30, " + "Active trade id: " + activeTradeId);
                    }
                  else
                    {

                     Comment("I cant take a trade because the trades array is full");
                    }


                 }
               else
                  if(stopLossIsValidBuys(stopLossBased_M15,maxPipsRiskAmount)  && candleClosedBullish(PERIOD_M15,1))
                    {

                     double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M15);
                     int indexToNewTrade ;
                     if((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1)   // find a spot in the trades array, and save the result
                       {
                        Print("The free index found is: " + indexToNewTrade);
                        activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToEnter,stopLossBased_M15) ;

                        BuyTradeManagerTiger* tempTigerManager= new BuyTradeManagerTiger(activeTradeId); // create an object of type buyTradeManagerTiger
                        BuyActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                        buysCount++;
                        Comment("Took a buy. stop loss: based on M15, " + "Active trade id: " + activeTradeId);
                       }
                     else
                       {

                        Comment("I cant take a trade because the trades array is full");

                       }

                    }

                  else
                    {


                     Comment("Failed to find a valid stop loss on both M30 and M15 !");
                    }

              }

            else
              {
               datetime currTime = TimeCurrent();
               string timeInStr = TimeToString(currTime,TIME_MINUTES);

               Comment(timeInStr + ": Price Broke the resitance zone, but not enough clean range to take a trade");

              }

           }
         else
           {
            datetime currTime = TimeCurrent();
            string timeInStr = TimeToString(currTime,TIME_MINUTES);
            Comment(timeInStr+ ": Price broke the resistance zone but i dont see the next target zone, Or the zone price broke was not a breakout zone ");

           }

        }


      if(updateBreakBelowStructureAndDelete(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30",brokenSupportHigherPrice,brokenZoneTypeSupport)
         && sellBreakerCandleIsValid(PERIOD_M30, SIZE_OF_BREAKER_CANDLE_BODY)
         && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED)) && SELLS_ALLOWED)   // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
        {


         double firstSupportPrice = findClosestSupportPrice(zoneContainerSupport_M30);

         double cleanRangeValueSells = SymbolInfoDouble(_Symbol, SYMBOL_BID) - firstSupportPrice;

         Print("firstSupport variable is: " + firstSupportPrice);
         Print("cleanRangeValueSells :" + cleanRangeValueSells);


         if(firstSupportPrice != -1 && brokenZoneTypeSupport == "TYPE_SUPPORT_BREAKOUT")
           {
            Comment("M30 candle Broke and closed below the zone. the closest support price is:" + DoubleToString(firstSupportPrice));
            if(cleanRangeValueSells >= cleanRangeUponEntry)
              {

               double stopLossBased_H1  = iHigh(_Symbol,PERIOD_H1,1);
               double stopLossBased_M30  = iHigh(_Symbol,PERIOD_M30,1);
               double stopLossBased_M15 = iHigh(_Symbol,PERIOD_M15,1);

               stopLossBased_H1 = stopLossBased_H1 + stopLossAboveWickBy ;
               stopLossBased_M30 = stopLossBased_M30 + stopLossAboveWickBy ;
               stopLossBased_M15 = stopLossBased_M15 + stopLossAboveWickBy ;

               if(stopLossIsValidSells(stopLossBased_M30, maxPipsRiskAmount))
                 {

                  double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M30);
                  int indexToNewTrade ;

                  if((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1)
                    {

                     Print("The free index found is: " + indexToNewTrade);
                     activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToEnter,stopLossBased_M30) ;

                     SellTradeManagerTiger* tempTigerManager= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                     SellActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                     sellsCount++;
                     Comment("Took a sell. stop loss: based on M30, " + "Active trade id: " + activeTradeId);

                    }
                  else
                    {

                     Comment("i cant take a trade because the arrray is full");
                    }


                 }
               else
                  if(stopLossIsValidSells(stopLossBased_M15,maxPipsRiskAmount) && candleClosedBearish(PERIOD_M15,1))
                    {
                     double lotsToEnter = lsCalc.calculateLotSize(riskDollars,stopLossBased_M15);
                     int indexToNewTrade ;
                     if((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1)
                       {
                        Print("The free index found is: " + indexToNewTrade);
                        activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToEnter,stopLossBased_M15) ;

                        SellTradeManagerTiger* tempTigerManager= new SellTradeManagerTiger(activeTradeId); // create an object of type buyTradeManagerTiger
                        SellActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                        sellsCount++;
                        Comment("Took a sell. stop loss: based on M15, "+ "Active trade id: " + activeTradeId);
                       }
                     else
                       {
                        Comment("i cant take a trade since another one is running");
                       }
                    }

                  else
                    {


                     Comment("Failed to find a valid stop loss on both M30 and M15 !");
                    }

              }

            else
              {
               datetime currTime = TimeCurrent();
               string timeInStr = TimeToString(currTime,TIME_MINUTES);


               Comment(timeInStr + ": Price Broke the support zone, but not enough clean range to take a trade");

              }

           }
         else
           {
            datetime currTime = TimeCurrent();
            string timeInStr = TimeToString(currTime,TIME_MINUTES);
            Comment(timeInStr+ ": Price broke the support zone but i dont see the next target zone, Or the zone price broke was not a breakout zone ");

           }



        }


      datetime currTime = TimeCurrent();
      ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));


      zoneContainer_M30.printZonesSortedArray();
      zoneContainerSupport_M30.printZonesSortedArray();

     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetectorDaily.isNewCandle())
     {

      //detectAndDrawResistanceOnTimeFrame(PERIOD_D1,"PERIOD_D1",clrYellow,clrYellow,zoneContainer_D1);
      //updateBreakAboveStructureAndDelete(zoneContainer_D1,PERIOD_D1,"PERIOD_D1");
      objectsManager.drawVerticalLine(clrAqua, TimeCurrent());


     }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetectorWeekly.isNewCandle())
     {

      objectsManager.drawVerticalLine(clrRed, TimeCurrent());
     }

  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }

