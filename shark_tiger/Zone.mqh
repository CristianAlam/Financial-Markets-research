//+------------------------------------------------------------------+
//|                                                         Zone.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "LowFractal.mqh"
#include "HighFractal.mqh"
#include "BuyEntryManager.mqh"
#include  "SellEntryManager.mqh"
#include "BuyTradeManager.mqh"
#include "SellTradeManager.mqh"

#define  SIZE_ATTACHED_FRACTALS
#define  TP_ARR_SIZE 3
class Zone
  {
private:
   string id ;
   string timeFrame ;
   string type ; // has 2 types : TYPE_SUPPORT, TYPE_RESISTANCE
   string state ; // state is one of 5 states : STATE_CLEAN , STATE_TESTED, STATE_BROKEN, STATE_BROKEN_RETESTED, STATE_WAITING(used when price breaks structure, and is waiting to confirm BOS or a liquidity sweep)
   datetime leftEdge ;
   datetime rightEdge;
   double lowerEdgePrice ;
   double higherEdgePrice ;
   double stopLossPrice ;
   double tpPrices[TP_ARR_SIZE] ;
   
  
   
    

public:                     
                     Zone();
                     Zone:: Zone(string _zoneId,double _higherEdgePrice,double _lowerEdgePrice,datetime _leftEdge,datetime _rightEdge,string _timeFrameStr,string _type);
                    ~Zone();
                    BuyEntryManager* buyEntryManager ;
                    BuyTradeManager* buyTradeManager;
                    
                    SellEntryManager* sellEntryManager ;
                    SellTradeManager* sellTradeManager ;
                    
                    

   // GETTERS
   double            getHigherEdge();
   double            getLowerEdge();
   datetime            getLeftEdge();
   datetime            getRightEdge();
   string            getId();
   string            getTimeFrame();
   string            getState();
   string            getType();
   double            getStopLossPrice();
   double            getZoneHeight();
   

   // SETTERS
   void              setLeftEdge(datetime _leftEdge);
   void              setRightEdge(datetime _rightEdge);
   void              setLowerEdgePrice(double _lowerPirce);
   void              setHigherEdgePrice(double _higherPrice);
   void              setTimeFrame(string _timeframe);
   void              setId(string _id);
   void              setType(string _type);
   void              setState(string _state);
   void              setStopLossPrice(double slPrice);
   bool              setTakeProfit(double tpVal); // returns false if there is no valid slot in the tp's array, and true on success
   

   // OTHER FUNCTIONS
   void              printTpLevels();
   void              printTradeManagerData();
   
   

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone:: Zone()
  {
  
  buyEntryManager = new BuyEntryManager();
  buyTradeManager = new BuyTradeManager();
  sellEntryManager = new SellEntryManager();
  sellTradeManager = new SellTradeManager();
  
  
  
 
  
  for(int i=0 ;i< TP_ARR_SIZE ;i++){ // initialize the tp array with -1's
   tpPrices[i] = -1 ;
  }

  }
  

Zone:: Zone(string _zoneId,double _higherEdgePrice,double _lowerEdgePrice,datetime _leftEdge,datetime _rightEdge,string _timeFrameStr,string _type){

       buyEntryManager = new BuyEntryManager();
       buyTradeManager = new BuyTradeManager();
       sellEntryManager = new SellEntryManager();
       sellTradeManager = new SellTradeManager();
       
       id = _zoneId ;
      
    timeFrame = _timeFrameStr;
    type = _type; // has 2 types : TYPE_SUPPORT, TYPE_RESISTANCE
    leftEdge = _leftEdge;
    rightEdge = _rightEdge;
    lowerEdgePrice = _lowerEdgePrice;
   higherEdgePrice = _higherEdgePrice;
       

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone::~Zone()
  {
  delete buyEntryManager;
  delete sellEntryManager;
  delete buyTradeManager;
  delete sellTradeManager;
  }
//+------------------------------------------------------------------+


// GETTERS

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Zone:: getLeftEdge()
  {

   return leftEdge;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Zone:: getRightEdge()
  {

   return rightEdge ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Zone:: getHigherEdge()
  {

   return higherEdgePrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Zone:: getLowerEdge()
  {

   return lowerEdgePrice;
  }
  
string Zone :: getState(){

   return state ;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Zone:: getId()
  {

   return id;
  }

string Zone:: getTimeFrame() {return timeFrame ;}



string Zone:: getType(){

   return type ;
}


double Zone :: getStopLossPrice(){
   return stopLossPrice ;
}

// SETTERS

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone:: setLeftEdge(datetime _leftEdge)
  {


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone:: setRightEdge(datetime _rightEdge)
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone:: setTimeFrame(string _timeframe)
  {

   timeFrame = _timeframe;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone:: setLowerEdgePrice(double _lowerPirce)
  {

   lowerEdgePrice = _lowerPirce;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone::setHigherEdgePrice(double _higherPrice)
  {

   higherEdgePrice = _higherPrice ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Zone:: setId(string _id)
  {

   id = _id;
  }



void Zone:: setType(string _type){

   type = _type ;
}


void Zone:: setState(string _state){

   state = _state ;
}


void Zone:: setStopLossPrice(double slPrice){
   
   stopLossPrice = slPrice ;
   
}


bool Zone:: setTakeProfit(double tpVal){
   for(int i=0; i<TP_ARR_SIZE; i++){
      if(tpPrices[i] == -1){
         tpPrices[i] = tpVal ; 
         if(type == "TYPE_SUPPORT"){
            buyTradeManager.tpArray[i] = tpVal;
         }
         else if(type == "TYPE_RESISTANCE"){
            sellTradeManager.tpArray[i] = tpVal ;
         }   
         
         return true ;
      }
   }
   return false;
}

// GUI FUNCTIONS




// ALGORITHM FUNCTIONS

//+------------------------------------------------------------------+
void Zone:: printTpLevels(){
   
   Print("Take Profit Levels are: ");
   for(int i=0 ; i< TP_ARR_SIZE;i++){
      if(tpPrices[i] != -1){
         Print(tpPrices[i]);
      }
   }
}


double Zone:: getZoneHeight(){

   return higherEdgePrice - lowerEdgePrice ;
}


void Zone:: printTradeManagerData(){
   
   
   if(type == "TYPE_SUPPORT"){
      Print("TP array in buyTradeManager is: ");
      for(int i=0;i<3;i++){
         Print("TP " + i + ": " + buyTradeManager.tpArray[i]);
      }
   }
   else if(type == "TYPE_RESISTANCE"){
       Print("TP array in sellTradeManager is: ");
      for(int i=0;i<3;i++){
         Print("TP " + i + ": " + sellTradeManager.tpArray[i]);
      }
   }
}