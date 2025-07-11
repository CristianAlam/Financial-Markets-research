//+------------------------------------------------------------------+
//|                                            NewCandleDetector.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class NewCandleDetector
  {
private:
   string timeFrame ;
   datetime beginDate ; // this datetime gets initialized only after the first call of the isNewCandle() function
   MqlDateTime       currTimeStruct;
   MqlDateTime       beginDateStruct;
   bool              firstCallHappened;
public:
                     NewCandleDetector(string _timeFrame);
                     
                    ~NewCandleDetector();

   // GETTERS
   datetime          getBeginDate() {return beginDate;}

   void              setTimeFrame(string _timeFrame) {timeFrame = _timeFrame;}
   bool              isNewCandle();
   
  };
//+------------------------------------------------------------------+

NewCandleDetector::NewCandleDetector(string _timeFrame)
  {

   timeFrame = _timeFrame ;
   firstCallHappened = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
NewCandleDetector::~NewCandleDetector()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewCandleDetector::  isNewCandle()
  {


   
   if(timeFrame == "PERIOD_M1")
     {

      if(firstCallHappened == false)
        {

         beginDate = iTime(_Symbol,PERIOD_M1,0);
         firstCallHappened = true;
        }

      if(firstCallHappened == true)
        {
         datetime currTime = iTime(_Symbol,PERIOD_M1,0);
         TimeToStruct(beginDate,beginDateStruct);
         TimeToStruct(currTime,currTimeStruct);

         if(beginDateStruct.min == currTimeStruct.min)
           {

            return false;
           }
         else
           {
            //Print("in a new candle !, asset: " + _Symbol);
            beginDate = currTime;
            return true ;

           }
        }



     }
   else
      if(timeFrame == "PERIOD_M2")
        {

        }

      else
         if(timeFrame == "PERIOD_M3")
           {

           }
         else
            if(timeFrame == "PERIOD_M4")
              {

              }
            else
               if(timeFrame == "PERIOD_M5")
                 {

                  if(firstCallHappened == false)
                    {
                     beginDate = iTime(_Symbol,PERIOD_M5,0);
                     firstCallHappened = true;
                    }

                  if(firstCallHappened == true)
                    {
                     datetime currTime = iTime(_Symbol,PERIOD_M5,0);
                     TimeToStruct(beginDate,beginDateStruct);
                     TimeToStruct(currTime,currTimeStruct);

                     if(beginDateStruct.min == currTimeStruct.min)
                       {

                        return false;
                       }
                     else
                       {
                        Print("in a new candle !, asset: " + _Symbol);
                        beginDate = currTime;
                        return true ;

                       }
                    }

                 }
               else
                  if(timeFrame == "PERIOD_M6")
                    {

                    }
                  else
                     if(timeFrame == "PERIOD_M10")
                       {

                       }
                     else
                        if(timeFrame == "PERIOD_M12")
                          {

                          }
                        else
                           if(timeFrame == "PERIOD_M15")
                             {

                              if(firstCallHappened == false)
                                {
                                 beginDate = iTime(_Symbol,PERIOD_M15,0);
                                 firstCallHappened = true;
                                }

                              if(firstCallHappened == true)
                                {
                                 datetime currTime = iTime(_Symbol,PERIOD_M15,0);
                                 TimeToStruct(beginDate,beginDateStruct);
                                 TimeToStruct(currTime,currTimeStruct);

                                 if(beginDateStruct.min == currTimeStruct.min)
                                   {

                                    return false;
                                   }
                                 else
                                   {

                                    beginDate = currTime;
                                    return true ;

                                   }
                                }

                             }
                           else
                              if(timeFrame == "PERIOD_M20")
                                {

                                }
                              else
                                 if(timeFrame == "PERIOD_M30")
                                   {
                                    if(firstCallHappened == false)
                                      {
                                       beginDate = iTime(_Symbol,PERIOD_M30,0);
                                       firstCallHappened = true;
                                      }

                                    if(firstCallHappened == true)
                                      {
                                       datetime currTime = iTime(_Symbol,PERIOD_M30,0);
                                       TimeToStruct(beginDate,beginDateStruct);
                                       TimeToStruct(currTime,currTimeStruct);

                                       if(beginDateStruct.min == currTimeStruct.min)
                                         {

                                          return false;
                                         }
                                       else
                                         {

                                          beginDate = currTime;
                                          return true ;

                                         }
                                      }
                                   }
                                 else
                                    if(timeFrame == "PERIOD_H1")
                                      {
                                       if(firstCallHappened == false)
                                         {
                                          beginDate = iTime(_Symbol,PERIOD_H1,0);
                                          firstCallHappened = true;
                                         }

                                       if(firstCallHappened == true)
                                         {
                                          datetime currTime = iTime(_Symbol,PERIOD_H1,0);
                                          TimeToStruct(beginDate,beginDateStruct);
                                          TimeToStruct(currTime,currTimeStruct);

                                          if(beginDateStruct.hour == currTimeStruct.hour)
                                            {

                                             return false;
                                            }
                                          else
                                            {

                                             beginDate = currTime;
                                             return true ;

                                            }
                                         }

                                      }
                                    else
                                       if(timeFrame == "PERIOD_H2")
                                         {

                                         }
                                       else
                                          if(timeFrame == "PERIOD_H3")
                                            {

                                            }
                                          else
                                             if(timeFrame == "PERIOD_H4")
                                               {
                                                if(firstCallHappened == false)
                                                  {
                                                   beginDate = iTime(_Symbol,PERIOD_H4,0);
                                                   firstCallHappened = true;
                                                  }

                                                if(firstCallHappened == true)
                                                  {
                                                   datetime currTime = iTime(_Symbol,PERIOD_H4,0);
                                                   TimeToStruct(beginDate,beginDateStruct);
                                                   TimeToStruct(currTime,currTimeStruct);

                                                   if(beginDateStruct.hour == currTimeStruct.hour)
                                                     {

                                                      return false;
                                                     }
                                                   else
                                                     {

                                                      beginDate = currTime;
                                                      return true ;

                                                     }
                                                  }
                                               }
                                             else
                                                if(timeFrame == "PERIOD_H6")
                                                  {

                                                  }
                                                else
                                                   if(timeFrame == "PERIOD_H8")
                                                     {

                                                     }
                                                   else
                                                      if(timeFrame == "PERIOD_H12")
                                                        {

                                                        }
                                                      else
                                                         if(timeFrame == "PERIOD_D1")
                                                           {

                                                            if(firstCallHappened == false)
                                                              {
                                                               beginDate = iTime(_Symbol,PERIOD_D1,0);
                                                               firstCallHappened = true;
                                                              }

                                                            if(firstCallHappened == true)
                                                              {
                                                               datetime currTime = iTime(_Symbol,PERIOD_D1,0);
                                                               TimeToStruct(beginDate,beginDateStruct);
                                                               TimeToStruct(currTime,currTimeStruct);

                                                               if(beginDateStruct.day == currTimeStruct.day)
                                                                 {

                                                                  return false;
                                                                 }
                                                               else
                                                                 {

                                                                  beginDate = currTime;
                                                                  return true ;

                                                                 }
                                                              }

                                                           }
                                                         else
                                                            if(timeFrame == "PERIOD_W1")
                                                              {
                                                              
                                                              
                                                                if(firstCallHappened == false)
                                                              {
                                                               beginDate = iTime(_Symbol,PERIOD_W1,0);
                                                               firstCallHappened = true;
                                                              }

                                                            if(firstCallHappened == true)
                                                              {
                                                               datetime currTime = iTime(_Symbol,PERIOD_W1,0);
                                                               TimeToStruct(beginDate,beginDateStruct);
                                                               TimeToStruct(currTime,currTimeStruct);

                                                               if(beginDateStruct.day == currTimeStruct.day)
                                                                 {

                                                                  return false;
                                                                 }
                                                               else
                                                                 {

                                                                  beginDate = currTime;
                                                                  return true ;

                                                                 }
                                                              }

                                                              }
                                                            else
                                                               if(timeFrame == "PERIOD_MN1")
                                                                 {

                                                                 }



   return true;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
