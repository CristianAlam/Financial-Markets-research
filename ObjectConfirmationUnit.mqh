//+------------------------------------------------------------------+
//|                                       ObjectConfirmationUnit.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

/*
   This class is responsible for all the proccess of confirming a new object. it prevents adding new objects if the previous was not confirmed. 
*/

class ObjectConfirmationUnit
  {
private:
                     string confirmationObjectID ;
                     string objectType ;
                     bool waitingToBeConfirmed ;
                     

public:
                     ObjectConfirmationUnit();
                    ~ObjectConfirmationUnit();
                    
                    // GETTERS 
                    string getObjectType(){ return objectType ;}
                    bool getWaitingStatus(){ return waitingToBeConfirmed ;}
                    string getConfirmationObjectId(){return confirmationObjectID;}
                    
                    // SETTERS
                    void setObjectType(string _type){ objectType = _type ;}
                    void setWaitingStatus(bool _waitStatus){ waitingToBeConfirmed = _waitStatus ;}
                    void setConfirmationObjectId(int _Id){ confirmationObjectID = IntegerToString(_Id) ;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ObjectConfirmationUnit::ObjectConfirmationUnit()
  {
   waitingToBeConfirmed = false ; // initialize with false value
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ObjectConfirmationUnit::~ObjectConfirmationUnit()
  {
  }
//+------------------------------------------------------------------+
