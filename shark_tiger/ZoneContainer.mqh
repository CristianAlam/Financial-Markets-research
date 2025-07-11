//+------------------------------------------------------------------+
//|                                                ZoneContainer.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include  "Zone.mqh"
#define  ZONES_SORTED_ARR_SIZE 400
class ZoneContainer
  {
private:
   int zonesIdCounter ; // number to identify each zone when we create it, it keeps adding up. if we delete a zone, we dont decrement it
   int zonesIdCounterSupport ; // used for support zones. i had to make it different from the resistance because there was a problem of collision of id's between supports and resistances zones
   int numberOfActiveZones ;

   Zone* zonesSortedArray[ZONES_SORTED_ARR_SIZE] ;
   int pivotEdges[2] ; // this array contains the indexes of the 2 zones that are closest to the current price , pivotEdges[0] = index of lower edge,   pivotEdges[1] = index of higher edge
public:
                     ZoneContainer();
                    ~ZoneContainer();

   // GETTERS
   int               getZonesIdCounter();
   int               getSupportZonesIdCounter();
   int               getNumberOfActiveZones();

   int               getLowZonePivot();
   int               getHighZonePivot();

   // SETTERS

   // OTHER FUNCTIONS
   void              incrementZonesIdCounter();
   void              incrementZonesIdCounterSupport();
   int               addZone(Zone* _newZone);
   void              addResistanceZoneTiger(Zone* _newZone);
   void              addSupportZoneTiger(Zone* _newZone);
   void              addHistoryResistanceZoneOnTop(Zone* _newZone);
   void              addHistorySupportZoneAtBottom(Zone* _newZone);
   
   
   int               updateZone(Zone* _tempZone,string _idOfOriginalZone);
   int               deleteZone(string ID);
   void              freeZonesSortedArray();
   void              printZonesSortedArray();
   void              forwardShiftZonesSortedArrayFromIndex(int _index);
   void              backwardShiftZonesSortedArrayFromIndex(int _index);

   void              findOrUpdatePivotEdgesOnConfirm(double _ask, double _bid);
   void              findOrUpdatePivotEdgesOnDelete();
   void              printPivotEdges();
   Zone*             getLowerPivotIndexZone();
   Zone*             getHigherPivotIndexZone();

   int               getZoneIndex(string _id); // returns the index of the zone in the zonesSortedArray if it was found , and returns -1 if it wasnt found
   int               searchForTheRightPlace(Zone* _zone);
   Zone*             searchZoneById(string _idOfZone);
   Zone*             getZoneByIndex(int _index);


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZoneContainer::ZoneContainer()
  {
   zonesIdCounter = 0;
   zonesIdCounterSupport = 100 ;
   pivotEdges[0] = -1;
   pivotEdges[1] = -1;
   numberOfActiveZones = 0;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZoneContainer::~ZoneContainer()
  {
  }
//+------------------------------------------------------------------+


// GETTERS

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: getZonesIdCounter()
  {
   return zonesIdCounter;
  }
  
  
int ZoneContainer:: getSupportZonesIdCounter(){

   return zonesIdCounterSupport; 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: getNumberOfActiveZones()
  {

   return numberOfActiveZones;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: getLowZonePivot()
  {

   return pivotEdges[0];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: getHighZonePivot()
  {

   return pivotEdges[1] ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone* ZoneContainer:: getZoneByIndex(int _index)
  {



   return zonesSortedArray[_index];



  }
// SETTERS


// OTHER FUNCTIONS

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: incrementZonesIdCounter()
  {
   zonesIdCounter++;
  }



void ZoneContainer:: incrementZonesIdCounterSupport(){

   zonesIdCounterSupport++ ;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: addZone(Zone* _newZone)
  {
   int result = -1;
   if(numberOfActiveZones == 0)  // means the array is empty
     {
      zonesSortedArray[0] = _newZone;
      numberOfActiveZones++;

      return 1 ;
     }
   else
      if(_newZone.getHigherEdge() < zonesSortedArray[0].getLowerEdge())  // in this case the new zone should be put in the first place in the array
        {
         forwardShiftZonesSortedArrayFromIndex(0); // shift all the array
         zonesSortedArray[0] = _newZone ;
         numberOfActiveZones++;

         return 1;
        }
      else
         if(_newZone.getLowerEdge() > zonesSortedArray[numberOfActiveZones-1].getHigherEdge())  // in this case the new zone should be in the last place in the array
           {
            zonesSortedArray[numberOfActiveZones] = _newZone;
            numberOfActiveZones++;

            return 1;
           }
         else  // in this case, the new zone sits somewhere in the array (not the edges)
           {
            int indexOfNewZone  = searchForTheRightPlace(_newZone);
            if(indexOfNewZone != -1)  // means found a place for the new zone
              {
               forwardShiftZonesSortedArrayFromIndex(indexOfNewZone);
               zonesSortedArray[indexOfNewZone] = _newZone ;
               numberOfActiveZones++;

               return 1;
              }
            else
              {
               return -1;
              }


           }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: deleteZone(string ID)
  {

// 1. find the index of the zone with the ID
   int indexOfZoneToDelete = getZoneIndex(ID);
   if(indexOfZoneToDelete == -1)
     {
      return -1;
     }
   else
      if(indexOfZoneToDelete == (numberOfActiveZones-1))  // means that this is the last zone in the sorted array
        {
         // 2. delete the zone
         // 3. its the last element so do nothing
         delete zonesSortedArray[numberOfActiveZones-1] ;
         numberOfActiveZones--;
         return 1;
        }
      else
        {
         // 2. delete the zone
         // 3. its not the last element, so shift the array 1 step backwards
         delete zonesSortedArray[indexOfZoneToDelete];
         backwardShiftZonesSortedArrayFromIndex(indexOfZoneToDelete);
         numberOfActiveZones--;
         return 1;
        }
   return 0 ;
  }






/* int ZoneContainer:: deleteZoneTiger(string ID){

// 1. find the index of the zone with the ID
   int indexOfZoneToDelete = getZoneIndex(ID);
   if(indexOfZoneToDelete == -1)
     {
      return -1;
     }
   else
      if(indexOfZoneToDelete == (numberOfActiveZones-1))  // means that this is the last zone in the sorted array
        {
         // 2. delete the zone
         // 3. its the last element so do nothing
         delete zonesSortedArray[numberOfActiveZones-1] ;
         numberOfActiveZones--;
         return 1;
        }
      else
        {
         // 2. delete the zone
         // 3. its not the last element, so shift the array 1 step backwards
         delete zonesSortedArray[indexOfZoneToDelete];
         backwardShiftZonesSortedArrayFromIndex(indexOfZoneToDelete);
         numberOfActiveZones--;
         return 1;
        }
   return 0 ;




} */
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: freeZonesSortedArray()
  {

   for(int i=0; i<numberOfActiveZones; i++)
     {
      delete zonesSortedArray[i];
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer::printZonesSortedArray()
  {
   if(numberOfActiveZones > 0)
     {
      for(int i=0; i<numberOfActiveZones; i++)
        {
         Print("Zone "+ i + ": " + "Type: " + zonesSortedArray[i].getType() + ", Lower Edge: " +  zonesSortedArray[i].getLowerEdge() + " Higher Edge: "+ zonesSortedArray[i].getHigherEdge() + " Stop Loss Price: " + zonesSortedArray[i].getStopLossPrice());
         //zonesSortedArray[i].printTpLevels();
         //zonesSortedArray[i].printTradeManagerData();
        }


      Print("Current Price is between zone " + pivotEdges[0] + " and zone "+  pivotEdges[1]);

     }
   else
     {
      Print("There is no active zones !");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: getZoneIndex(string _id)
  {
   int indexOfZone = -1;
   for(int i=0 ; i <numberOfActiveZones ; i++)
     {
      if(zonesSortedArray[i].getId() == _id)
        {
         indexOfZone = i ;
         return indexOfZone ;
        }
     }
   return indexOfZone ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer::forwardShiftZonesSortedArrayFromIndex(int _index) // used for adding
  {

   for(int x = numberOfActiveZones ; x > _index ; x--)
     {
      zonesSortedArray[x] = zonesSortedArray[x-1] ;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: backwardShiftZonesSortedArrayFromIndex(int _index) // used for deleting
  {
   for(int i= _index ; i<numberOfActiveZones ; i++)
     {
      zonesSortedArray[i] = zonesSortedArray[i+1];
     }
   zonesSortedArray[numberOfActiveZones-1] = NULL ; // empty the last element in the sorted array
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer:: searchForTheRightPlace(Zone* _zone)
  {
   int index = -1;
   for(int i=0; i<numberOfActiveZones-1; i++)
     {
      if((_zone.getLowerEdge() > zonesSortedArray[i].getHigherEdge()) && (_zone.getHigherEdge() < zonesSortedArray[i+1].getLowerEdge()))
        {
         index = i+1;

         return index;
        }
     }
   return index ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ZoneContainer :: updateZone(Zone* _tempZone, string _idOfOriginalZone)
  {


   Zone* zoneToUpdate = searchZoneById(_idOfOriginalZone);

   zoneToUpdate.setHigherEdgePrice(_tempZone.getHigherEdge());
   zoneToUpdate.setLowerEdgePrice(_tempZone.getLowerEdge());
   zoneToUpdate.setLeftEdge(_tempZone.getLeftEdge());
   zoneToUpdate.setRightEdge(_tempZone.getRightEdge());
   zoneToUpdate.setTimeFrame(_tempZone.getTimeFrame());

   return 1 ;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone* ZoneContainer:: searchZoneById(string _idOfZone)
  {
   Zone* result ;
   for(int i=0 ; i< numberOfActiveZones ; i++)
     {
      if(zonesSortedArray[i].getId() == _idOfZone)
        {
         result = zonesSortedArray[i] ;

        }
     }

   return result ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: findOrUpdatePivotEdgesOnConfirm(double _ask,double _bid)
  {

   bool foundSupport = false ;
   bool foundResistance = false ;


   for(int i=0 ; i<numberOfActiveZones ; i++) // FIND LOWER PIVOT EDGE
     {

      if(zonesSortedArray[i].getState() != "STATE_WAITING")
        {
         if((zonesSortedArray[i].getHigherEdge() < _ask) && (zonesSortedArray[i].getType() == "TYPE_SUPPORT"))
           {
            pivotEdges[0] = i;
            foundSupport = true ;
           }
        }
     }

   for(int i= numberOfActiveZones-1 ; i >=0 ; i--) // FIND HIGHER PIVOT EDGE
     {
      if(zonesSortedArray[i].getState()!= "STATE_WAITING")
        {
         if((zonesSortedArray[i].getLowerEdge() > _bid) && (zonesSortedArray[i].getType() == "TYPE_RESISTANCE"))
           {
            pivotEdges[1] = i;
            foundResistance = true ;
           }
        }

     }

   if(foundSupport == false)
     {
      pivotEdges[0] = -1;
     }
   if(foundResistance == false)
     {
      pivotEdges[1] = -1;
     }

  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: findOrUpdatePivotEdgesOnDelete()
  {
   bool foundSupport = false ;
   bool foundResistance = false ;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK) ;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   for(int i=0 ; i<numberOfActiveZones ; i++) // FIND LOWER PIVOT EDGE
     {

      if(zonesSortedArray[i].getState() != "STATE_WAITING")
        {
         if(zonesSortedArray[i].getHigherEdge() < ask)
           {
            pivotEdges[0] = i;
            foundSupport = true ;
           }
        }
     }

   for(int i= numberOfActiveZones-1 ; i >=0 ; i--) // FIND HIGHER PIVOT EDGE
     {
      if(zonesSortedArray[i].getState()!= "STATE_WAITING")
        {
         if(zonesSortedArray[i].getLowerEdge() > bid)
           {
            pivotEdges[1] = i;
            foundResistance = true ;
           }
        }

     }

   if(foundSupport == false)
     {
      pivotEdges[0] = -1;
     }
   if(foundResistance == false)
     {
      pivotEdges[1] = -1;
     }



  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: printPivotEdges()
  {

   Print("Lower Edge Index: " + pivotEdges[0]);
   Print("Higher Edge Index: " + pivotEdges[1]);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone* ZoneContainer:: getLowerPivotIndexZone()
  {

   if(pivotEdges[0] != -1)
     {
      return getZoneByIndex(pivotEdges[0]);
     }

   return NULL ;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Zone* ZoneContainer:: getHigherPivotIndexZone()
  {

   if(pivotEdges[1] != -1)
     {
      return getZoneByIndex(pivotEdges[1]);
     }

   return NULL;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZoneContainer:: addResistanceZoneTiger(Zone* _newZone)
  {


   if((numberOfActiveZones != 0 ) && (_newZone.getLowerEdge() >= zonesSortedArray[0].getHigherEdge()))  // this is the case, where the new zone shouldnt be placed at the beggining (gap case for instance)
     {


      int indexOfNewZone  = searchForTheRightPlace(_newZone);
      if(indexOfNewZone != -1)  // means found a place for the new zone
        {
         forwardShiftZonesSortedArrayFromIndex(indexOfNewZone);
         zonesSortedArray[indexOfNewZone] = _newZone ;
         numberOfActiveZones++;

        }
      else
        {
         Print("Couldnt find an index to place the new zone !");
        }


     }

   else
     {

      forwardShiftZonesSortedArrayFromIndex(0);
      zonesSortedArray[0] = _newZone ;

      if(_newZone.getType() == "TYPE_RESISTANCE_BREAKOUT")
        {
         numberOfActiveZones++;
        }
      else
         if(_newZone.getType() == "TYPE_RESISTANCE_NORMAL")
           {

            numberOfActiveZones++ ;
           }
     }




  }


 void ZoneContainer:: addHistoryResistanceZoneOnTop(Zone* _newZone){
        zonesSortedArray[numberOfActiveZones] = _newZone ;
        numberOfActiveZones++;
 }
 



void ZoneContainer:: addSupportZoneTiger(Zone* _newZone)
  {


   /* if((numberOfActiveZones != 0 ) && (_newZone.getHigherEdge() <= zonesSortedArray[numberOfActiveZones-1].getLowerEdge()))  // this is the case, where the new zone shouldnt be placed at the beggining (gap case for instance)
     {


      int indexOfNewZone  = searchForTheRightPlace(_newZone);
      if(indexOfNewZone != -1)  // means found a place for the new zone
        {
         forwardShiftZonesSortedArrayFromIndex(indexOfNewZone);
         zonesSortedArray[indexOfNewZone] = _newZone ;
         numberOfActiveZones++;

        }
      else
        {
         Print("Couldnt find an index to place the new zone !");
        }


     } */

   

      
      zonesSortedArray[numberOfActiveZones] = _newZone ;

      if(_newZone.getType() == "TYPE_SUPPORT_BREAKOUT")
        {
         numberOfActiveZones++;
        }
      else
         if(_newZone.getType() == "TYPE_SUPPORT_NORMAL")
           {

            numberOfActiveZones++ ;
           }
     




  }

//+------------------------------------------------------------------+
 void  ZoneContainer::    addHistorySupportZoneAtBottom(Zone* _newZone){
 
 
      forwardShiftZonesSortedArrayFromIndex(0);
      zonesSortedArray[0] = _newZone ;
      numberOfActiveZones++;
 }