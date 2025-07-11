//+------------------------------------------------------------------+
//|                                            Breakout_Fractals.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//#include "Algo_Skeleton_Functions.mqh"
#include "Phoenix_Functions.mqh"

bool trailWhenMarketOpensDaily = false ;
int OnInit()
  {
//---

//---
   for(int i=0; i<NUM_MAX_ALLOWED_TRADES ; i++)
     {
      BuyActiveTradesArray[i] = NULL ;
      SellActiveTradesArray[i] = NULL ;

     }


   objectsManager.addTextTiger();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Buys Count: " + buysCount);
   Print("Sells Count: " + sellsCount);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   cleanBuyTradesArr();
   cleanSellTradesArr();



   if(newCandleDetectorM5.isNewCandle())
     {
      if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_M5){
         trailAllOpenPositionsIfNeeded(PERIOD_M5);
      }
      if(TIME_FRAME_TO_TRADE == PERIOD_M5)
        {
         datetime currTime = TimeCurrent();
         Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);

         string timeFrameStr = timeFrameToString(TIME_FRAME_TO_TRADE);

         findAndDrawFractalsAndZones(TIME_FRAME_TO_TRADE,timeFrameStr);

         if(candleClosedBelowSupportZone(TIME_FRAME_TO_TRADE))  // SELL CASE
           {
            handleSells();
           }


         if(candleClosedAboveResistanceZone(TIME_FRAME_TO_TRADE))  // BUY CASE
           {
            handleBuys();
           }

        }
     }


   if(newCandleDetectorM15.isNewCandle())
     {
       if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_M15){
         trailAllOpenPositionsIfNeeded(PERIOD_M15);
      }
      if(TIME_FRAME_TO_TRADE == PERIOD_M15)
        {
         datetime currTime = TimeCurrent();
         Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);

         string timeFrameStr = timeFrameToString(TIME_FRAME_TO_TRADE);

         findAndDrawFractalsAndZones(TIME_FRAME_TO_TRADE,timeFrameStr);

         if(candleClosedBelowSupportZone(TIME_FRAME_TO_TRADE))  // SELL CASE
           {
            handleSells();
           }


         if(candleClosedAboveResistanceZone(TIME_FRAME_TO_TRADE))  // BUY CASE
           {
            handleBuys();
           }

        }
     }

   if(newCandleDetectorM30.isNewCandle())
     {

       if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_M30){
         trailAllOpenPositionsIfNeeded(PERIOD_M30);
      }
      if(TIME_FRAME_TO_TRADE == PERIOD_M30)
        {

         datetime currTime = TimeCurrent();
         Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);

         string timeFrameStr = timeFrameToString(TIME_FRAME_TO_TRADE);

         findAndDrawFractalsAndZones(TIME_FRAME_TO_TRADE,timeFrameStr);

         if(candleClosedBelowSupportZone(TIME_FRAME_TO_TRADE))  // SELL CASE
           {
            handleSells();
           }


         if(candleClosedAboveResistanceZone(TIME_FRAME_TO_TRADE))  // BUY CASE
           {
            handleBuys();
           }

        }

     }



   if(newCandleDetectorH1.isNewCandle())
     {
       if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_D1 && trailWhenMarketOpensDaily){
         trailAllOpenPositionsIfNeeded(PERIOD_D1);
         trailWhenMarketOpensDaily = false ;
       }
       if(APPLY_TRAIL && (TRAIL_TIME_FRAME == PERIOD_H1)){
         Print("Entered the trail !");
         trailAllOpenPositionsIfNeeded(PERIOD_H1);
      }
      if(TIME_FRAME_TO_TRADE == PERIOD_H1)
        {
         datetime currTime = TimeCurrent();
         Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);

         string timeFrameStr = timeFrameToString(TIME_FRAME_TO_TRADE);

         findAndDrawFractalsAndZones(TIME_FRAME_TO_TRADE,timeFrameStr);

         if(candleClosedBelowSupportZone(TIME_FRAME_TO_TRADE))  // SELL CASE
           {
            handleSells();
           }


         if(candleClosedAboveResistanceZone(TIME_FRAME_TO_TRADE))  // BUY CASE
           {
            handleBuys();
           }

        }
     }

   if(newCandleDetectorH4.isNewCandle())
     {
       if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_H4){
         trailAllOpenPositionsIfNeeded(PERIOD_H4);
      }
       if(TIME_FRAME_TO_TRADE == PERIOD_H4)
        {

         datetime currTime = TimeCurrent();
         Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);

         string timeFrameStr = timeFrameToString(TIME_FRAME_TO_TRADE);

         findAndDrawFractalsAndZones(TIME_FRAME_TO_TRADE,timeFrameStr);

         if(candleClosedBelowSupportZone(TIME_FRAME_TO_TRADE))  // SELL CASE
           {
            handleSells();
           }


         if(candleClosedAboveResistanceZone(TIME_FRAME_TO_TRADE))  // BUY CASE
           {
            handleBuys();
           }

        }
     }


   if(newCandleDetectorDaily.isNewCandle())
     {
       if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_D1){
         trailWhenMarketOpensDaily = true ;
         trailAllOpenPositionsIfNeeded(PERIOD_D1);
      }
      objectsManager.drawVerticalLine(clrAqua, TimeCurrent());
     }

   if(newCandleDetectorWeekly.isNewCandle())
     {
      if(APPLY_TRAIL && TRAIL_TIME_FRAME == PERIOD_W1){
         trailAllOpenPositionsIfNeeded(PERIOD_W1);
      }
      objectsManager.drawVerticalLine(clrRed, TimeCurrent());;
     }

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleSells()
  {

   datetime currTime = TimeCurrent();

   Comment(TimeToString(currTime,TIME_MINUTES) + ": im taking a sell !");

   if(((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1))
     {

      double stopLossPrice = calculateStopLossBasedOnFractalsSells(stopLossFractalsPeriod,stopLossTimeFrame) ;
      stopLossPrice = stopLossPrice + stopLossAboveWickByActual ;

      if(stopLossIsValidSells(stopLossPrice,maxPipsRiskAmountActual))
        {
         if(rrFactor != -1 && lotSize == -1)  // tp based rr metehod
           {
            if(SELLS_ALLOWED){
               double stopLossInPips = stopLossPrice - SymbolInfoDouble(_Symbol,SYMBOL_BID)  ;
            double netTp = rrFactor * stopLossInPips ;
            double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
            activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_BID)- netTp) ;

            SellTradeManagerTiger* tempTigerManagerSell= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger

            tempTigerManagerSell.setBrokenSupportHigherEdge(currentSupportHighEdge);
            tempTigerManagerSell.setBrokenSupportLowerEdge(currentSupportLowerEdge);
            SellActiveTradesArray[indexToNewTrade] = tempTigerManagerSell ;// put the new object in the array

            sellsCount++;
            }
            
           }

         else
            if(rrFactor == -1 && lotSize == -1)  // tp based net take profit method
              {
               if(SELLS_ALLOWED){
                  double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_BID)- netTakeProfit) ;

               SellTradeManagerTiger* tempTigerManagerSell= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger

               tempTigerManagerSell.setBrokenSupportHigherEdge(currentSupportHighEdge);
               tempTigerManagerSell.setBrokenSupportLowerEdge(currentSupportLowerEdge);
               SellActiveTradesArray[indexToNewTrade] = tempTigerManagerSell ;// put the new object in the array

               sellsCount++;
               }
               
              }
              
              else if(lotSize != -1){ // taking an entry based on fixed lot , and managing risk via trail
                  if(SELLS_ALLOWED){
                     activeTradeId = sellEntryManager.takeSellTradeTiger(lotSize,stopLossPrice) ;
                  SellTradeManagerTiger* tempTigerManagerSell= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                  tempTigerManagerSell.setBrokenSupportHigherEdge(currentSupportHighEdge);
                  tempTigerManagerSell.setBrokenSupportLowerEdge(currentSupportLowerEdge);
                  SellActiveTradesArray[indexToNewTrade] = tempTigerManagerSell ;// put the new object in the array

                  sellsCount++;
                  }
                  
              }
              
              

        }
      else
        {
         Print("stop loss is not valid sells!");
        }


     }
   else
     {

      Comment("i cant take a trade because the arrray is full");
     }

   currentSupportLowerEdge = -1;
   currentSupportHighEdge = -1;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleBuys()
  {

   datetime currTime = TimeCurrent();
   Comment(TimeToString(currTime,TIME_MINUTES) + ": im taking a buy !");



   if(((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1))
     {

      Print("indexToNewTrade:-------------------------------------------- " + indexToNewTrade);

      double stopLossPrice = calculateStopLossBasedOnFractalsBuys(stopLossFractalsPeriod,stopLossTimeFrame);
      stopLossPrice = stopLossPrice - stopLossUnderWickByActual ;
      
      if(stopLossIsValidBuys(stopLossPrice,maxPipsRiskAmountActual))
        {

         if(rrFactor != -1  && lotSize == -1)
           {
            if(BUYS_ALLOWED){
               double stopLossInPips = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - stopLossPrice ;
            double netTp = rrFactor * stopLossInPips ;
            double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
            activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+ netTp) ;

            BuyTradeManagerTiger* tempTigerManagerBuy= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
            tempTigerManagerBuy.setBrokenResistanceHigherEdge(currentResistanceHighEdge);
            tempTigerManagerBuy.setBrokenResistancetLowerEdge(currentResistanceLowEdge);
            BuyActiveTradesArray[indexToNewTrade] = tempTigerManagerBuy ;// put the new object in the array
            buysCount++;
            }
            
           }
         else
            if(rrFactor == -1 && lotSize == -1)
              {
               if(BUYS_ALLOWED){
                   double lotsToTrade = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToTrade,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+ netTakeProfit) ;

               BuyTradeManagerTiger* tempTigerManagerBuy= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
               tempTigerManagerBuy.setBrokenResistanceHigherEdge(currentResistanceHighEdge);
               tempTigerManagerBuy.setBrokenResistancetLowerEdge(currentResistanceLowEdge);
               BuyActiveTradesArray[indexToNewTrade] = tempTigerManagerBuy ;// put the new object in the array
               buysCount++;
               }
              
              }
              
              else if(lotSize != -1){  // taking an entry based on fixed lot , and managing risk via trail
               
               if(BUYS_ALLOWED){
                  activeTradeId = buyEntryManager.takeBuyTradeTiger(lotSize,stopLossPrice) ;

               BuyTradeManagerTiger* tempTigerManagerBuy= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
               tempTigerManagerBuy.setBrokenResistanceHigherEdge(currentResistanceHighEdge);
               tempTigerManagerBuy.setBrokenResistancetLowerEdge(currentResistanceLowEdge);
               BuyActiveTradesArray[indexToNewTrade] = tempTigerManagerBuy ;// put the new object in the array
               buysCount++;
               }
                
              }

        }
      else
        {
         Print("stop loss is not valid buys !");
        }


     }
   else
     {

      Comment("i cant take a trade because the arrray is full");
     }

   currentResistanceHighEdge = -1;
   currentResistanceLowEdge = -1;
  }
//+------------------------------------------------------------------+
