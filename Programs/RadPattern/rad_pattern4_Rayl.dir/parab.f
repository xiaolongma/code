c**********************************************************************
c----------------------------------------------------------------------
      function PARABS (y1,y2,y3,x)
c----------------------------------------------------------------------
c     to calculate the value of the second degree polinom
c----------------------------------------------------------------------
      a1=y1+y3-2.0*y2
      a2=(y1-y3)*0.5
      x= a2/a1
      parabs=(a1*x*0.5-a2)*x+y2
      RETURN
      END
