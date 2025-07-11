//+------------------------------------------------------------------+
//|                                            LotSizeCalculator.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LotSizeCalculator
  {
private:

public:
                     LotSizeCalculator();
                    ~LotSizeCalculator();

   double            calculateLotSize(double riskInMoney,double stopLossPrice);


   string            BaseCurrency() { return (AccountInfoString(ACCOUNT_CURRENCY)); }
   double            Point(string symbol) { return (SymbolInfoDouble(symbol, SYMBOL_POINT)); }
   double            TickSize(string symbol) { return (SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE)); }
   double            TickValue(string symbol) { return (SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE)); }

   double            PointValue(string symbol);

   void              Test(string symbol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LotSizeCalculator::LotSizeCalculator()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LotSizeCalculator::~LotSizeCalculator()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotSizeCalculator:: calculateLotSize(double riskInMoney, double stopLossPrice)
  {

   double difference ;
   double differenceInPoints ;

   if(stopLossPrice > SymbolInfoDouble(_Symbol, SYMBOL_BID))  // we are calculating for a sell
     {
      difference = stopLossPrice - SymbolInfoDouble(_Symbol, SYMBOL_BID) ;
      differenceInPoints = difference / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double pointValue = PointValue(_Symbol);

      // Situation 3, fixed risk amount and stop loss, how many lots to trade
      double riskInPoints = differenceInPoints;
      double riskLots   = riskInMoney / (pointValue * riskInPoints);

      return riskLots;
     }
     
     if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) > stopLossPrice){
      difference = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossPrice ;
      differenceInPoints = difference / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double pointValue = PointValue(_Symbol);
      double riskInPoints = differenceInPoints;
      double riskLots   = riskInMoney / (pointValue * riskInPoints);
      return riskLots;
     }


   return 0 ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotSizeCalculator:: PointValue(string symbol)
  {

   double tickSize      = TickSize(symbol);
   double tickValue     = TickValue(symbol);
   double point         = Point(symbol);
   double ticksPerPoint = tickSize / point;
   double pointValue    = tickValue / ticksPerPoint;

   PrintFormat("tickSize=%f, tickValue=%f, point=%f, ticksPerPoint=%f, pointValue=%f",
               tickSize, tickValue, point, ticksPerPoint, pointValue);

   return (pointValue);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LotSizeCalculator:: Test(string symbol)
  {

   PrintFormat("Base currency is %s", BaseCurrency());
   PrintFormat("Testing for symbol %s", symbol);

   double pointValue = PointValue(symbol);

   PrintFormat("ValuePerPoint for %s is %f", symbol, pointValue);

// Situation 3, fixed risk amount and stop loss, how many lots to trade
   double riskAmount = 100;
   double riskPoints = 5000;
   double riskLots   = riskAmount / (pointValue * riskPoints);
   PrintFormat("Risk lots for %s value %f and stop loss at %f points is %f",
               symbol, riskAmount, riskPoints, riskLots);
  }
//+------------------------------------------------------------------+
