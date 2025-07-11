//+------------------------------------------------------------------+
//|                                             SellTradeManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include <Telegram_Handler.mqh>
#include <TradeManagersAttributes.mqh>
#include  <Trade/Trade.mqh>
CTrade tradeInTradeManager;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SellTradeManager
  {
private:
   int               tradeId ;
   ulong             rejectionByOneCandleTradeArray[3]; // index 0 : half the contract  ,   index 1 : quarter of the contract ,  index 2 : quarter of the contract


   string            firstSecureMethod ;
   bool              firstSecureMethodFound;
   int               numberOfTakeProfits ;
   bool              securedFirstLevelProfit ;
   bool              securedSecondLevelProfit;
   double            partialToClose ;
   bool              isTradeRunning ;


public:
                     SellTradeManager();
                    ~SellTradeManager();


   void              fillRejectionByOneCandleTradeArray(int _index, ulong _id) {rejectionByOneCandleTradeArray[_index] = _id ;}
   ulong             getRejectionByOneCandleTradeTicket(int _index) {return rejectionByOneCandleTradeArray[_index] ;}
   void              printRejectionByOneCandleTradeArray();

   void              checkAndSecureTradeIfNeeded(double _ratio, double _riskInDollars);
   string            findFirstSecureMethod();

   bool              reachedProfitRatio(int _indexInArr);
   bool              closeTrade(int _indexInArr);
   bool              positionBreakEven(int _indexInArr);

   void              addTpAtIndex(int _index, double tpPrice) {tpArray[_index] = tpPrice;}
   int               countRemainingTakeProfits();
   bool              reachedClosestTakeProfit();
   void              deleteClosestTp();
   int               findClosestTpIndex();

   void              cleanOrderDataStructures();

   void              setTradeRunning(bool _setting) {isTradeRunning = _setting ;}
   bool              tradeIsRunning() {return isTradeRunning ;}

   double            tpArray[3];

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellTradeManager::SellTradeManager()
  {
   for(int i=0; i<3; i++)
     {
      tpArray[i] = -1;
     }
   securedFirstLevelProfit = false ;
   securedSecondLevelProfit = false ;
   firstSecureMethodFound = false ;
   firstSecureMethod = "NOT_FOUND" ;
   partialToClose = -1 ;
   isTradeRunning = false ;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SellTradeManager::~SellTradeManager()
  {
  }

//+------------------------------------------------------------------+
void SellTradeManager:: printRejectionByOneCandleTradeArray()
  {

   Print("Printing the tickets :");
   for(int i=0 ; i<3 ; i++)
     {
      Print((int)rejectionByOneCandleTradeArray[i]);
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellTradeManager:: checkAndSecureTradeIfNeeded(double _ratio, double _riskInDollars)
  {


   if(securedFirstLevelProfit == false)  // in this case im searching for 2 cases: either RR 1:1.5 , OR reaching the first TP , if any of them happened im gonna close half the order and updatae the remaining stop losses
     {


      if(!firstSecureMethodFound)
        {

         firstSecureMethod = findFirstSecureMethod();
         if(firstSecureMethod != "FAILED")
           {
            firstSecureMethodFound = true ;
           }
         else
            if(firstSecureMethod == "FAILED")
              {
               Print("Failed to find the first secure method, go check the function : findFirstSecureMehod() !");
              }

        }

      if(firstSecureMethodFound == true)
        {

         if(firstSecureMethod == "RATIO_METHOD")
           {
            cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
            if(reachedProfitRatio(0))
              {
               ChartRedraw(); // Make sure the chart is up to date
               ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
               SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                   "If you see this message it means we reached the first secure method, which is ratio method, after this message, half of the order must be closed (2 trades will remain active), and the first quarter will be put into Break even " + TimeToString(TimeLocal()), fileName);
               if(closeTrade(0)) // close the half
                 {

                  rejectionByOneCandleTradeArray[0] = -1;
                  Print("Closed Half Of the position due to reaching the first secure Ratio!");
                 }
               else
                 {
                  Print("Failed Closing Half of the order by reaching the first secure Ratio !");
                 }

               cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
               if(positionBreakEven(1))  // put the first quarter at break even
                 {

                  Print(" First quarter has been put into break even due to reaching the first secure Ratio!");
                 }
               else
                 {
                  Print("Failed to Put the first quarter into break even");
                 }

               numberOfTakeProfits = countRemainingTakeProfits();

               Print("Number of remaining tps is: " + numberOfTakeProfits);

               securedFirstLevelProfit = true ;
              }





           }
         else
            if(firstSecureMethod == "FIRST_TP_METHOD")
              {
               if(countRemainingTakeProfits() > 1)   // there is at least 2 tp in the tp Array (because if this is the last tp then we want to close the whole order and not just a part of it)
                 {
                  if(reachedClosestTakeProfit())  // 2. Check if reached the first Tp
                    {
                     ChartRedraw(); // Make sure the chart is up to date
                     ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                     SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                         "If you see this message it means we reached the first secure method which is tp1, after this message, half of the order must be closed (2 trades will remain active), and the first quarter will be put into Break even " + TimeToString(TimeLocal()), fileName);
                     // close the first half and update remaining partials sl's and delete the closest take profit from the array
                     cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
                     if(closeTrade(0)) // close the half
                       {

                        rejectionByOneCandleTradeArray[0] = -1;
                        Print("Closed Half Of the position due to reaching the first TP!");

                       }
                     else
                       {
                        Print("Failed Closing Half of the order by reaching the first TP !");
                       }
                     cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
                     if(positionBreakEven(1))  // put the first quarter at break even
                       {

                        Print(" First quarter has been put into break even due to reaching the first TP!");
                       }
                     else
                       {
                        Print("Failed to Put the first quarter into break even");
                       }
                     deleteClosestTp();
                     numberOfTakeProfits = countRemainingTakeProfits(); // update the number of remaining take profits
                     // calculate the remaining tps

                     Print("Number of remaining tps is: " + numberOfTakeProfits);

                     securedFirstLevelProfit = true ;


                    }
                 }
               else
                  if(numberOfTakeProfits = countRemainingTakeProfits() == 1)
                    {
                     if(reachedClosestTakeProfit())
                       {
                        // close everything remained
                       }
                    }
              }

        }



     }
   else
      if(securedFirstLevelProfit == true)  // after securing the first level i just want to close the remaining partials by reaching the tp's
        {

         if(countRemainingTakeProfits() == 1)
           {
            if(reachedClosestTakeProfit())
              {
               // close everything
               cleanOrderDataStructures();
               for(int i=0 ; i<3 ; i++)
                 {
                  closeTrade(i);
                 }
               Print("Closed every thing because price reached the last Take Profit !");
               
               ChartRedraw(); // Make sure the chart is up to date
               ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
               SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                   "If you see this message it means that all order are closed as a result of reaching the last tp " + TimeToString(TimeLocal()), fileName);
               deleteClosestTp();
              }
           }
         else
            if(countRemainingTakeProfits() > 1)
              {
               if(reachedClosestTakeProfit())
                 {
                  cleanOrderDataStructures();
                  if(PositionSelectByTicket(rejectionByOneCandleTradeArray[1])) // DEALING WITH THE FIRST QUARTER
                    {
                     double currentLot = PositionGetDouble(POSITION_VOLUME);
                     if(partialToClose == -1)
                       {
                        partialToClose = currentLot/numberOfTakeProfits ;
                       }
                     if(tradeInTradeManager.PositionClosePartial(rejectionByOneCandleTradeArray[1],NormalizeDouble(partialToClose,2)))
                       {
                        uint res = tradeInTradeManager.ResultRetcode();
                        if(res == 10009)
                          {
                           Print("Closed Partials successfully on the first quarter !");
                          }
                        else
                          {
                           Print("The returned code is: " + res + " go check what it means !");
                          }

                       }
                    }
                  else
                    {
                     Print("Failed to select position by ticket, Error: " + GetLastError());
                     Print("The EA tried to close partials on the first quarter, but it is closed, probably due to break even and thats why it couldnt select the order !");
                    }


                  cleanOrderDataStructures();
                  if(PositionSelectByTicket(rejectionByOneCandleTradeArray[2])) // DEALING WITH THE SECOND QUARTER
                    {
                     if(PositionGetDouble(POSITION_SL) > PositionGetDouble(POSITION_PRICE_OPEN)) // this is to put the second quarter at break even if its not already at break even
                       {
                        positionBreakEven(2);

                       }
                     double currentLot = PositionGetDouble(POSITION_VOLUME);
                     if(partialToClose == -1)
                       {
                        partialToClose = currentLot/numberOfTakeProfits ;
                       }
                     if(tradeInTradeManager.PositionClosePartial(rejectionByOneCandleTradeArray[2],NormalizeDouble(partialToClose,2)))
                       {
                        uint res = tradeInTradeManager.ResultRetcode();
                        if(res == 10009)
                          {
                           Print("Closed Partials successfully on the second quarter!");
                          }
                        else
                          {
                           Print("The returned code is: " + res + " go check what it means !");
                          }

                       }

                    }
                  deleteClosestTp();
                  Print("Number Of Remained tps is: " + countRemainingTakeProfits());
                  
                  
                  ChartRedraw(); // Make sure the chart is up to date
                  ChartScreenShot(0, fileName, 1024, 768, ALIGN_RIGHT);
                  SendTelegramMessage(TelegramApiUrl, TelegramBotToken, ChatId,
                                      "If you see this message it means we reached a tp level (different than the first secure level), so partial positions will be closed, and the scond quarter must be in break even!" + TimeToString(TimeLocal()), fileName);
                 }

              }


        }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SellTradeManager:: findFirstSecureMethod()
  {

   cleanOrderDataStructures(); // this is used each time before we are choosing an order by ticket
   if(PositionSelectByTicket(rejectionByOneCandleTradeArray[0]))
     {
      double positionStopLoss = PositionGetDouble(POSITION_SL);
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double firstTakeProfit = tpArray[findClosestTpIndex()];
      if(((positionOpenPrice-firstTakeProfit)/(positionStopLoss-positionOpenPrice) > firstSecureRatio))  // firstTp > ratio
        {
         Print("Found the first profit secure method !");
         Print("The first TP RR is: 1:" + (positionOpenPrice-firstTakeProfit)/(positionStopLoss-positionOpenPrice) + "the firstSecureRatio is: 1:" + firstSecureRatio);
         Print("The tp ratio is greater than the firstSecure so:");
         Print("The first secure method is RATIO_METHOD");
         return"RATIO_METHOD";
        }
      else
         if((positionOpenPrice-firstTakeProfit)/(positionStopLoss-positionOpenPrice)< firstSecureRatio)
           {
            Print("Found the first profit secure method !");
            Print("The first TP RR is: 1:" + (positionOpenPrice-firstTakeProfit)/(positionStopLoss-positionOpenPrice) + "the firstSecureRatio is: 1:" + firstSecureRatio);
            Print("The tp ratio is less than the firstSecure so:");
            Print("The first secure method is FIRST_TP_METHOD");
            return "FIRST_TP_METHOD" ;
           }
     }
   else
     {
      Print("Failed to select position by ticket 1, Error: " + GetLastError());
     }

   return "FAILED" ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellTradeManager:: reachedProfitRatio(int _indexInArr)
  {
   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))
        {
         if(PositionGetDouble(POSITION_PROFIT)/(0.5*riskDollars) >= firstSecureRatio)    // checking if the first half of the contract reached the ratio of first secure profit
           {
            Print("reached profit ratio !");
            return true ;
           }
        }
      else
        {
         Print("Failed to select the position by ticket 4 ,Error: " + GetLastError());

        }

     }

   return false ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  SellTradeManager:: closeTrade(int _indexInArr)
  {


   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))
        {

         // close the first half and update remaining partials sl's
         if(tradeInTradeManager.PositionClose(_ticket))
           {
            return true ;

           }
         else
           {

            Print("Failed to close  positon, Error:" + GetLastError());
            return false;
           }

        }
      else
        {

         Print("Failed to select position by ticket 2, Error: "+ GetLastError());
         return false;
        }

     }


   return false ;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  SellTradeManager::  positionBreakEven(int _indexInArr)
  {

   ulong _ticket = rejectionByOneCandleTradeArray[_indexInArr];
   if(_ticket != -1)
     {
      if(PositionSelectByTicket(_ticket))  // select the first quarter
        {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double positionTp = PositionGetDouble(POSITION_TP);
         double positionSl = PositionGetDouble(POSITION_SL);

         if(tradeInTradeManager.PositionModify((_ticket),openPrice,positionTp))
           {


            return true ;
           }
         else
           {
            Print("Failed to modify oder , ERROR: " + GetLastError());
            return false ;
           }

        }
      else
        {
         Print("Failed to select position by ticket 3");
         return false ;
        }
     }


   return false ;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SellTradeManager:: countRemainingTakeProfits()
  {

   int counter = 0 ;
   for(int i=0; i<3 ; i++)
     {
      if(tpArray[i] != -1)
        {
         counter++ ;
        }
     }

   return counter;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellTradeManager:: deleteClosestTp()
  {

   int closestTpIndex =findClosestTpIndex();
   tpArray[closestTpIndex] = -1;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SellTradeManager:: findClosestTpIndex()
  {
   int closestTpIndex = 0;

   for(int i=1; i<3; i++)
     {
      if(tpArray[i] > tpArray[closestTpIndex])
        {
         closestTpIndex = i ;
        }
     }

   return closestTpIndex ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellTradeManager:: reachedClosestTakeProfit()
  {


   double closestTakeProfitValue = tpArray[findClosestTpIndex()];
//Print("im in reached closest take profit function ,the current price is: " + SymbolInfoDouble(_Symbol, SYMBOL_BID) + " and the tp is: " + closestTakeProfitValue);
   if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= closestTakeProfitValue) // we want the ASK because we are basically buying the asset again (in a cheaper price), and we want to buy it on the ASK (which is the price that a seller is willing to sell us)
     {
      return true ;
     }
   return false ;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellTradeManager:: cleanOrderDataStructures()
  {
// this is to make sure, that every closed order is removed from the data strucutre !

   for(int i=0; i<3; i++)
     {
      if(!PositionSelectByTicket(rejectionByOneCandleTradeArray[i]))
        {
         if(GetLastError() == 4753)
           {
            rejectionByOneCandleTradeArray[i] = -1 ;
           }
        }
     }

  }
//+------------------------------------------------------------------+
