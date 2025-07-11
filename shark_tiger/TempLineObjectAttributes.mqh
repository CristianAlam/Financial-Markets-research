//+------------------------------------------------------------------+
//|                                     TempLineObjectAttributes.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class TempLineObjectAttributes
  {
private:
                  
                     string id ;
                     double price ;

public:
                     TempLineObjectAttributes();
                    ~TempLineObjectAttributes();
                    
                    // GETTERS
                    string getId(){return id;}
                    double getPrice(){return price ;}
                    
                    // SETTERS
                    void setId(string _id){id =_id ;}
                    void setPrice(double _price){price = _price ;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TempLineObjectAttributes::TempLineObjectAttributes()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TempLineObjectAttributes::~TempLineObjectAttributes()
  {
  }
//+------------------------------------------------------------------+
