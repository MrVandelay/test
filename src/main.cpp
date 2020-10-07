

#include <cstdio>
#include <cstring>
#include <string>
//#include <unistd.h>
#include <sstream>
#include <iostream>
#include <mutex>
#include "main.h"
#include <unistd.h>


/*
   TestClass::TestClass() {

   }

   TestClass::~TestClass() {


   }
*/
void printa (int value)
{
   printf("data%i",value);

}


int main() {
// Ger ingt fel
#if 0
   pdata = new TestClass();
   printa(pdata->value);
   delete pdata;
#endif

   // Ger fel
#if 1
   int t;
   TestClass data = TestClass();
   printa(data.value);

   printf("r  %i", t);
   // if (tpoint->r == 0)
   //   printa(t.r);
  // printa(t.r);
#endif

 /*  std::mutex m;
   m.lock();
   sleep(3); // warn: a blocking function sleep is called inside a critical
             //       section
   m.unlock();
*/
   return 0;

}

