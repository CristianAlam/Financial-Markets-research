//+------------------------------------------------------------------+
//|                                               Phoenix_Reborn.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Phoenix_Functions.mqh"


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+




int OnInit()
  {
//---
   
//---
   iOpen(_Symbol,PERIOD_M5,1);
   iOpen(_Symbol,PERIOD_M15,1);
    iOpen(_Symbol,PERIOD_M30,1);
   iOpen(_Symbol,PERIOD_H1,1);
   iOpen(_Symbol,PERIOD_H4,1);
   
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
      
     
      
      /*if(newCandleDetectorM1.isNewCandle()){
         
        datetime currTime = TimeCurrent();
        Comment(TimeToString(currTime,TIME_MINUTES) + ": Sell Below: " + currentSupportLowerEdge + " Buy Above: "+ currentResistanceHighEdge);
        
        findAndDrawFractalsAndZones(PERIOD_M1,"PERIOD_M1");
        
        if(candleClosedBelowSupportZone()){
            datetime currTime = TimeCurrent();
                    
            Comment(TimeToString(currTime,TIME_MINUTES) + ": im taking a sell !");
            
            
            if(((indexToNewTrade = findAvailableSpotInSellManagerArr()) != -1 ) )
                    {

                     Print("indexToNewTrade: ----------------------------------------------" + indexToNewTrade);
                     double stopLossPrice ;
                     if(currentResistanceHighEdge != -1){
                        stopLossPrice = currentResistanceHighEdge + stopLossAboveWickBy ; 
                     }
                     else{
                        stopLossPrice = iHigh(_Symbol,PERIOD_M30,1) - stopLossAboveWickBy; // if there is no higher zone , take the last m30 candle's high
                     }
                     activeTradeId = sellEntryManager.takeSellTradeTiger(lotSize,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_BID)- netTakeProfit ) ;

                     SellTradeManagerTiger* tempTigerManagerSell= new SellTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                     
                     tempTigerManagerSell.setBrokenSupportHigherEdge(currentSupportHighEdge);
                     tempTigerManagerSell.setBrokenSupportLowerEdge(currentSupportLowerEdge);
                     SellActiveTradesArray[indexToNewTrade] = tempTigerManagerSell ;// put the new object in the array
                     
                     sellsCount++;
                                       

                    }
                  else
                    {

                     Comment("i cant take a trade because the arrray is full");
                    }
                    
                    currentSupportLowerEdge = -1;
                    currentSupportHighEdge = -1;
        }
        
        
        if(candleClosedAboveResistanceZone()){
            datetime currTime = TimeCurrent();
            Comment(TimeToString(currTime,TIME_MINUTES) + ": im taking a buy !");
            
            
            
            if(((indexToNewTrade = findAvailableSpotInBuyManagerArr()) != -1))
                    {

                     Print("indexToNewTrade:-------------------------------------------- " + indexToNewTrade);
                     double stopLossPrice ;
                     if(currentSupportLowerEdge != -1){
                        stopLossPrice = currentSupportLowerEdge - stopLossUnderWickBy ; 
                     }
                     else{
                        stopLossPrice = iLow(_Symbol,PERIOD_M30,1) - stopLossUnderWickBy; // if there is no lower zone , take the last m30 candle's low
                     }
                     activeTradeId = buyEntryManager.takeBuyTradeTiger(lotSize,stopLossPrice,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+ netTakeProfit ) ;
                     
                     BuyTradeManagerTiger* tempTigerManagerBuy= new BuyTradeManagerTiger(activeTradeId); // create an object of type sellTradeManagerTiger
                     tempTigerManagerBuy.setBrokenResistanceHigherEdge(currentResistanceHighEdge);
                     tempTigerManagerBuy.setBrokenResistancetLowerEdge(currentResistanceLowEdge);
                     BuyActiveTradesArray[indexToNewTrade] = tempTigerManagerBuy ;// put the new object in the array
                     buysCount++;
                                        
                    }
                  else
                    {

                     Comment("i cant take a trade because the arrray is full");
                    }
                    
                    currentResistanceHighEdge = -1;
                    currentResistanceLowEdge = -1;
        }
      } */
   
   
   /*if(newCandleDetectorM5.isNewCandle()){
      findAndDrawFractalsAndZones(PERIOD_M5,"PERIOD_M5");
      int tradeCount = 0 ;
      for(int i=0;i<NUM_MAX_ALLOWED_TRADES;i++){
         if(BuyActiveTradesArray[i]!= NULL){
            tradeCount++ ;
         }
      }
      
     
      manageRiskIfNeededPhoenix();
   } */
   
   
   /*if(newCandleDetectorM30.isNewCandle()){
      findAndDrawFractalsAndZones(PERIOD_M30,"PERIOD_M30");
      int tradeCount = 0 ;
      for(int i=0;i<NUM_MAX_ALLOWED_TRADES;i++){
         if(BuyActiveTradesArray[i]!= NULL){
            tradeCount++ ;
         }
      }
      
     
      
       datetime currTime = TimeCurrent();          
        ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
  } */
  
  
  if(newCandleDetectorH4.isNewCandle()){
      findAndDrawFractalsAndZones(PERIOD_H4,"PERIOD_H4");
      int tradeCount = 0 ;
      
       
      
       datetime currTime = TimeCurrent();          
        ObjectSetString(0,"clockTextTiger",OBJPROP_TEXT,TimeToString(currTime,TIME_MINUTES));
  }
  
  
  if(newCandleDetectorDaily.isNewCandle()){
  
  // objectsManager.drawVerticalLine(clrAqua, TimeCurrent());
  }
  
  if(newCandleDetectorWeekly.isNewCandle()){
     
      objectsManager.drawVerticalLine(clrRed, TimeCurrent());;
   }
  }
//+------------------------------------------------------------------+



