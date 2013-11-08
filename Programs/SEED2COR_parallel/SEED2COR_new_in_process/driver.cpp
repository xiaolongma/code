#include "CCDatabase.h"
#include <iostream>

int main(int argc, char *argv[]) {

   if(argc!=2) {
      std::cerr<<"Usage: "<<argv[0]<<" [Parameters_file]"<<std::endl;
      return 0;
   }

   /* Initialize the CC Database with the input parameter file */
   CCDatabase cdb(argv[1]);

   //std::cerr<<cdb.GetParams().sps<<std::endl;

   return 0;
}
