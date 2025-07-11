//+------------------------------------------------------------------+
//|                                         TempObjectAttributes.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class TempObjectAttributes
  {
private:
                     // ATTRIBUTES FOR A ZONE
                     string assetName;
                     string timeFrame ;
                     double higherEdgePrice ; 
                     double lowerEdgePrice ;
                     datetime leftEdgeTime ;
                     datetime rightEdgeTime;
                     
                     
                     // ATTRIBUTES FOR TRENDLINE
                     
                     
                     
                     // ATTRIBUTES FOR DAILY LINE
                     
                     
                     
                     // ATTRIBUTES FOR IMBALANCE
                     
                     
                     
                     // ATTRIBUTES FOR FIBONACCI LEVEL
                     
                     
                     
                     
public:
                     TempObjectAttributes();
                    ~TempObjectAttributes();
                    
                    // GETTERS FOR ZONE
                     double getHigherEdgePrice(){return higherEdgePrice;}
                     double getLowerEdgePrice(){return lowerEdgePrice;}
                     datetime getLeftEdgeTime(){return leftEdgeTime ;}
                     datetime getRightEdgeTime(){return rightEdgeTime;}
                     string getSymbol(){return assetName;}
                     string getTimeFrame(){return timeFrame;}
                    
                    // SETTERS FOR ZONE
                    void setHigherEdgePrice(double _higherEdgePrice){higherEdgePrice = _higherEdgePrice;}
                    void setLowerEdgePrice(double _lowerEdgePrice){lowerEdgePrice = _lowerEdgePrice;}
                    void setLeftEdgeTime(datetime _leftEdgeTime){leftEdgeTime = _leftEdgeTime;}
                    void setRightEdgeTime(datetime _rightEdgeTime){rightEdgeTime = _rightEdgeTime;}
                    void setSymbol(){assetName = Symbol();}
                    void setTimeFrame(string _timeframe){timeFrame = _timeframe;}
                    // OTHER ZONE FUNCTIONS
                    
                    void cleanAttributesZone(){higherEdgePrice = -1;
                        lowerEdgePrice = -1;
                        leftEdgeTime = 0;
                        rightEdgeTime = 0;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TempObjectAttributes::TempObjectAttributes()
  {
  
                        higherEdgePrice = -1;
                        lowerEdgePrice = -1;
                        leftEdgeTime = 0;
                        rightEdgeTime = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TempObjectAttributes::~TempObjectAttributes()
  {
  }
//+------------------------------------------------------------------+
