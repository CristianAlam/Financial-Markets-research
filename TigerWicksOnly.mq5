//+------------------------------------------------------------------+
//|                                                TigerObserver.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Algo_Skeleton_Functions.mqh"




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   cleanBuyTradesArr();
   cleanSellTradesArr();
   secureProfitIfNeeded();

    // BUYS 
   if(waitForBottomWickToForm == true && wickLengthCounter == wickLengthInMinutes) // waited wickLengthInMinutes time, and now its the time to check if the wick is valid
     {
            
             bottomWickValidationState = handleBottomWickValidation();
             updateBottomWickState(bottomWickValidationState);           
              
     }
         
    if(bottomWickFormed){
         datetime currTime = TimeCurrent();
         if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) >= buyStopPrice && !wickTradeTaken){
               double stopLossPrice = iLow(_Symbol,PERIOD_CURRENT,0) - stopLossUnderWickBy;
               
               double stopLossBased_H1  = iLow(_Symbol,PERIOD_H1,1);
               double stopLossBased_M30  = iLow(_Symbol,PERIOD_M30,1);
               double stopLossBased_M15 = iLow(_Symbol,PERIOD_M15,1);
               
                stopLossBased_H1 = stopLossBased_H1 - stopLossUnderWickBy ;
                stopLossBased_M30 = stopLossBased_M30 - stopLossUnderWickBy ;
                stopLossBased_M15 = stopLossBased_M15 - stopLossUnderWickBy ;
               
               
               if((SymbolInfoDouble(_Symbol,SYMBOL_ASK) - stopLossPrice) < minimumStopLossInPips){
                  stopLossPrice = stopLossBased_M30 ;
                  if(stopLossIsValidBuys(stopLossBased_H1,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_H1 ;
                  }
                  else if(stopLossIsValidBuys(stopLossBased_M30,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_M30 ;
                  }
                  
                  else if(stopLossIsValidBuys(stopLossBased_M15,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_M15 ;
                  }
                }
                else if(!stopLossIsValidBuys(stopLossPrice,maxPipsRiskAmount)){
                  stopLossPrice = -1 ;
                }
               double lotsToBuy = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               int indexToNewTrade ;
               if(((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1) && stopLossPrice != -1)
                    {

                     
                     activeTradeId = buyEntryManager.takeBuyTradeTiger(lotsToBuy,stopLossPrice) ;

                     BuyTradeManagerTiger* tempTigerManager= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                     BuyActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                     buysCount++;
                     wickTradeTaken = true ;
                     Comment("Took a bUY. stop loss: above current wick, " + "Active trade id: " + activeTradeId);

                    }
                  else
                    {

                     Comment("i cant take a trade because the arrray is full");
                    }
               Comment(TimeToString(currTime,TIME_MINUTES) +  ": price has reached the candle high, im taking a buy");
         }
         
    }

   
   // SELLS
   
   if(waitForTopWickToForm == true && wickLengthCounter == wickLengthInMinutes){ // waited wickLengthInMinutes time, and now its the time to check if the wick is valid
      topWickValidationState = handleTopWickValidation();
      updateTopWickState(topWickValidationState);
   }
   
   if(topWickFormed){
      datetime currTime = TimeCurrent();
      if((SymbolInfoDouble(_Symbol,SYMBOL_BID) <= sellStopPrice) && !wickTradeTaken){
               double stopLossPrice = iHigh(_Symbol,PERIOD_CURRENT,0) + stopLossAboveWickBy;
               
               
               double stopLossBased_H1  = iHigh(_Symbol,PERIOD_H1,1);
               double stopLossBased_M30  = iHigh(_Symbol,PERIOD_M30,1);
               double stopLossBased_M15 = iHigh(_Symbol,PERIOD_M15,1);
               
                stopLossBased_H1 = stopLossBased_H1 + stopLossAboveWickBy ;
                stopLossBased_M30 = stopLossBased_M30 + stopLossAboveWickBy ;
                stopLossBased_M15 = stopLossBased_M15 + stopLossAboveWickBy ;
                
                if((stopLossPrice - SymbolInfoDouble(_Symbol,SYMBOL_BID)) < minimumStopLossInPips){
                  stopLossPrice = stopLossBased_M30 ;
                  if(stopLossIsValidSells(stopLossBased_H1,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_H1 ;
                  }
                  else if(stopLossIsValidSells(stopLossBased_M30,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_M30 ;
                  }
                  
                  else if(stopLossIsValidSells(stopLossBased_M15,maxPipsRiskAmount)){
                     stopLossPrice = stopLossBased_M15 ;
                  }
                }
                else if(!stopLossIsValidSells(stopLossPrice,maxPipsRiskAmount)){
                  stopLossPrice = -1 ;
                }
                
                
               
               double lotsToSell = lsCalc.calculateLotSize(riskDollars,stopLossPrice);
               
               int indexToNewTrade ;

                  if(((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1) && stopLossPrice != -1)
                    {

                     
                     activeTradeId = sellEntryManager.takeSellTradeTiger(lotsToSell,stopLossPrice) ;

                     SellTradeManagerTiger* tempTigerManager= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                     SellActiveTradesArray[indexToNewTrade] = tempTigerManager ;// put the new object in the array
                     sellsCount++;
                     wickTradeTaken = true ;
                     Comment("Took a sell. stop loss: under current wick, " + "Active trade id: " + activeTradeId);

                    }
                  else
                    {

                     Comment("i cant take a trade because the arrray is full");
                    }
               
               
               Comment(TimeToString(currTime,TIME_MINUTES) +  ": price has reached the candle low, im taking a sell");
         }
   }





   if(newCandleDetectorM1.isNewCandle())
     {
      
      // BUY CASE
      if(waitForBottomWickToForm == true && wickLengthCounter < wickLengthInMinutes)
        {
            wickLengthCounter++ ;
        }             

      // SELL CASE
      
       if(waitForTopWickToForm == true && wickLengthCounter < wickLengthInMinutes){
            wickLengthCounter++;
       }
     }




   if(newCandleDetectorM15.isNewCandle())
     {

      manageRiskIfNeeded();

     }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(newCandleDetector30M.isNewCandle())
     {
      wickTradeTaken = false ;
      if(bottomWickFormed){ // reset the bottomWickFormed flag. this is for the cases that bottom wick has formed, but m30 candle closed and the trade still not taken
         bottomWickFormed = false ;
         buyStopPrice = -1; 
      }
      
      if(topWickFormed){ // reset the topWickFormed flag. this is for the cases that top wick has formed, but m30 candle closed and the trade still not taken
         topWickFormed = false ;
         sellStopPrice = -1;
      }
      trailAllOpenPositionsIfNeeded(PERIOD_M30);

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

         Print("first resistcane price is: "+ firstResistancePrice);
         if(zoneContainer_M30.getNumberOfActiveZones() > 0 && firstResistancePrice != -1 && brokenZoneTypeResistance == "TYPE_RESISTANCE_BREAKOUT")
           {


            Comment("Price Broke and closed above resistance zone, im waiting for a bottom wick to form");
            waitForBottomWickToForm = true ;
            
           }
           
           else  if(zoneContainer_M30.getNumberOfActiveZones() == 0  && brokenZoneTypeResistance == "TYPE_RESISTANCE_BREAKOUT")
           {


            Comment("Price Broke and closed above resistance zone, im waiting for a bottom wick to form");
            waitForBottomWickToForm = true ;
            
           }


        }
      if(updateBreakBelowStructureAndDelete(zoneContainerSupport_M30,PERIOD_M30,"PERIOD_M30",brokenSupportHigherPrice,brokenZoneTypeSupport)
         && sellBreakerCandleIsValid(PERIOD_M30, SIZE_OF_BREAKER_CANDLE_BODY)
         && ((sessionIsNy() && TRADE_NEW_YORK_ALLOWED) || (sessionIsLondon() && TRADE_LONDON_ALLOWED)) && SELLS_ALLOWED)   // means M30 candle broke structure, and the breaker candle is valid (big enough),and time is in the sessions (ny or london or both, based on what the user chose))
        {


         double firstSupportPrice = findClosestSupportPrice(zoneContainerSupport_M30);
         double cleanRangeValueSells = SymbolInfoDouble(_Symbol, SYMBOL_BID) - firstSupportPrice;

         if(zoneContainerSupport_M30.getNumberOfActiveZones() > 0 && firstSupportPrice != -1 && brokenZoneTypeSupport == "TYPE_SUPPORT_BREAKOUT")
           {
            waitForTopWickToForm = true ;
            Comment("Price Broke and closed below support zone, im waiting for a top wick to form");
           

           }
           
           else if(zoneContainerSupport_M30.getNumberOfActiveZones() == 0 && brokenZoneTypeSupport == "TYPE_SUPPORT_BREAKOUT"){
               waitForTopWickToForm = true ;
            Comment("Price Broke and closed below support zone, im waiting for a top wick to form");
           
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



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
