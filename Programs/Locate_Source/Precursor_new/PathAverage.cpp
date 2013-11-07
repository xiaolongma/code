#include "PathAverage.h"
#include <stdio.h>
#include <cstdlib>
#include <math.h>
#include <iostream>
#include <errno.h>
#if defined(_OPENMP)
#include <omp.h>
#else
typedef int omp_int_t;
inline omp_int_t omp_get_thread_num() { return 0;}
inline omp_int_t omp_get_num_threads() { return 1;}
#endif
using namespace std;

double Path::PathAverage(double lamda) {
   double Nmin = 3.; //(2 ~ 20?) Don't know much about sw kernel
   // define ellipse
   double f = dist/2.; // known values
   double bsqrmax = pow(f+lamda/2./Nmin, 2)-f*f; //maximum affective b from Nmin
   //double asqr = pow(f+lamda/2./N, 2), bsqr = asqr-f*f;

   char buff[300];
   float wmax = sqrt(bsqrmax); // project using wmax
   double Nhaf = 12., Ncur, weight, weit=0., zsum=0.;
   FILE *fproj = NULL;
   char ftmpname[20];
   sprintf(ftmpname, "./projecttmp_thread%d.txt", omp_get_thread_num());

   sprintf(buff, "project %s -Dg -C%f/%f -E%f/%f -Lw -Q -S -W-%f/%f -Fpqz > %s", fname, P1.Lon(), P1.Lat(), P2.Lon(), P2.Lat(), wmax, wmax, ftmpname);
   #pragma omp critical
   { system(buff); }

   // read in project data
   //double N = 12., asqr = pow(f+lamda/2./N, 2), bsqr = asqr-f*f;
   if( (fproj = fopen(ftmpname, "r")) == NULL ) {
      perror("open file");
      zsum = -1;
   }
   else {
      float a, xdat, ydat, zdat;
      while( fgets(buff, 300, fproj)!=NULL ) {
         sscanf(buff, "%f %f %f", &xdat, &ydat, &zdat);
         if( zdat != zdat ) continue;
        xdat -= f;
          // compute N from xdat, ydat, f, lamda
         a = 0.5 * (sqrt(pow((xdat-f),2)+ydat*ydat) + sqrt(pow((xdat+f),2)+ydat*ydat));
         Ncur = lamda/2./(a-f)/Nhaf;
         weight = exp(-0.5*Ncur*Ncur);
         weit += weight;
         zsum += (zdat * weight);
         //cerr<<xdat<<" "<<ydat<<" "<<zdat<<"   "<<weight<<" "<<zsum<<endl;
      }
      fclose(fproj);
      remove(ftmpname);
   }
   if(weit==0.) zsum = -12345.;
   else zsum /= weit;
   return zsum;
 
}

