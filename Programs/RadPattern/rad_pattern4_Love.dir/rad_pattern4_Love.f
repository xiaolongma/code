c To calculate group_delay as a function of azimuth and period
      real*4 v(3,200),dvdz(3,200)
      real*4 tm(6),du(3),vu(3),wvn(2),period(20),ampl_max(200)
      complex*8 br(6),bl(6),sumr
      character*80 infile,perlist
      character*40  bred,word
      character*10 symbol1,symbol2,symbol,symbo
      character*2 symbik
      character*2 sym1  
      character*2 sym3  
      character*3 sym2  
      character*4 sym4,sym5
      character*1 sigR,sigL
      logical lout 
      real*4 az_max(200),aml(181,200),pq(181,200),ph(181,200),ampl(200)
      real*4 cr(200),ur(200),wvr(200),t(200),fr(200)
      real*4 cl(200),ul(200),wvl(200)
      real*4 temp_ph(200),unph(200),grt(200),gr_time(181,200)
      data marg/6/,pi/3.1415927/,r/2./,eps/0.0001/,lout/.false./,eps1/0.1/
      data  const/1.E+20/
C---------------event_tensor includes Mo and 6 components of the moment tensor
C---------------in the order Mxx Myy Mzz Mxy Mxz Myz; as in new_surfsyn
C-------------------------------initiation------------S
      PRINT*,'infile is an output of OLD_SURF_DEEP'
      PRINT*,'Quake is defined by dip and rake angles'
      PRINT*,'Output in one file with gaps or (opt) with many files foreach period'
      PRINT*,'files of rad.patterns are produced for periods presented at the output of OLD_SURF_DEEP'
      narg=iargc()
      if(narg.ne.marg.and.narg.ne.marg+1)STOP'USAGE: rad_pattern4_Love infile perlist strike dip rake depth [-o]'
      call GETARG(1,infile)
      lin=lnblnk(infile)
      call GETARG(2,perlist)
      sym1='  '
      sym2='    '
      call GETARG(3,symbo)
      read(symbo,*)strike
      istrike=strike
      sym5='    '
      if(istrike.lt.10.and.istrike.ge.0)write(sym5,'(I1)')istrike
      if(istrike.ge.10.and.istrike.lt.100)write(sym5,'(I2)')istrike
      if(istrike.ge.100)write(sym5,'(I3)')istrike
      if(istrike.gt.-10.and.istrike.lt.0)write(sym5,'(I2)')istrike
      if(istrike.le.-10.and.istrike.gt.-100)write(sym5,'(I3)')istrike
      if(istrike.le.-100)write(sym5,'(I4)')istrike
      l5=lnblnk(sym5)
      call GETARG(4,symbol1)
      read(symbol1,*)dip
      idip=dip
      if(idip.lt.10)write(sym1,'(I1)')idip
      if(idip.ge.10)write(sym1,'(I2)')idip
      l1=lnblnk(sym1)
      call GETARG(5,symbol2)
      read(symbol2,*)rake
      irake=rake
      sym4='    '
      if(irake.lt.10.and.irake.ge.0)write(sym4,'(I1)')irake
      if(irake.ge.10.and.irake.lt.100)write(sym4,'(I2)')irake
C      if(irake.ge.100)write(sym4,'(I3)')irake
      if(irake.gt.-10.and.irake.lt.0)write(sym4,'(I2)')irake
      if(irake.le.-10.and.irake.gt.-100)write(sym4,'(I3)')irake
      if(irake.le.-100)write(sym4,'(I4)')irake
      l2=lnblnk(sym4)
      call GETARG(6,symbol)
      read(symbol,*)depth
      lso=lnblnk(symbol)
      if(narg.eq.7) then 
       call GETARG(7,sym3)
      if(sym3.eq.'-o') lout=.true.
       endif
        OPEN(75,file='TEMP')
      drad=180./pi
      ioevt = 0
      iold=0
      sigR='-'
      sigL='+'
      PRint*,'depth=',depth
      open(1,file=infile(1:lin)//'.phv',status='OLD')
       word=sym5(1:l5)//'_d'//sym1(1:l1)//'_r'//sym4(1:l2)//'_h'//symbol(1:lso)
       lw=lnblnk(word)
      open(64,file=infile(1:lin)//word(1:lw)//'.prot')
      open(63,file=perlist,status='OLD')
      do i=1,20
      read(63,*,end=9898)period(i)
      enddo
9898  np=i-1
      if(.not.lout)then
      open(15,file=infile(1:lin)//'_T_AZ_s'//word(1:lw))
      open(16,file=infile(1:lin)//'_AMP_AZ_s'//word(1:lw))
      open(17,file=infile(1:lin)//'_PHA_AZ_s'//word(1:lw))
                  endif
      n_depth=int(depth+0.5)
      write(64,*)' infile=',infile(1:lin),' dip=',dip,' rake=',rake 
      write(64,*)'depth=',depth
      n_depth=int(depth+0.5)
      symbik='1 '
      nd=1000 
      m=0
C-----------reading phv file to get m and dper------S
            do i=1,1000
            read(1,'(a)',end=9988)bred
            if(i.eq.1)read(bred,*)per1
            if(i.eq.2)read(bred,*)per2
            if(bred(6:10).eq.'     ')go to 9988
            m=m+1
            enddo
9988        close(1)
            nt=m             
            dper=per2-per1
            PRINT*,nt,' input periods'
C-----------reading phv file to get m and dper------E
C-------------------------------initiation------------E
C-----------reading OLD_SURF_DEEP output---S                  
      call surfread(infile,sigR,sigL,symbik,nt,nd,depth,t,cr,ur,wvr,
     +cl,ul,wvl,v,dvdz,ampl)
      write(*,*) ampl(1), ampl(90), ampl(180)
C-----------reading OLD_SURF_DEEP output---E                  
           call angles2tensor(strike,dip,rake,tm)
        write(64,*)tm
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
c----------Source term calculations-----------------S
C----------period loop---------------------------S
           DO j=1,nt
           ampl_max(j)=0.0
           fr(j)=1./t(j)
           vu(1)=v(1,j)
           vu(2)=v(2,j)
           vu(3)=v(3,j)
           du(1)=dvdz(1,j)
           du(2)=dvdz(2,j)
           du(3)=dvdz(3,j)
           w=pi*2.0*fr(j)
           wvn(1)=wvr(j)
           wvn(2)=wvl(j)
           az_max(j)=0.0
C-----------azimuthal loop--S
      Do  jkl=1,181
      AZI=2.*float(jkl-1)
C     if(jkl.eq.181)AZI=0.0
          AZ_rad=AZI/drad
           cs=cos(AZ_rad)
           sc=sin(AZ_rad)
C----convolution with moment tensor -----S
       call source(sigR,sigL,cs,sc,wvn,vu,du,br,bl)
           sumr=(0.0,0.0)
                  do m=1,6
           if(sigR.eq.'+')sumr= sumr+tm(m)*br(m)
           if(sigL.eq.'+')sumr= sumr+tm(m)*bl(m)
                  end do
C----convolution with moment tensor -----E
           aq=cabs(sumr)
           sume=real(sumr)
           sumi=aimag(sumr)
           pq(jkl,j)=pha(sumi,sume)
           if(aq.gt.az_max(j))az_max(j)=aq              
C          aml(jkl,j)=aq           
C          PRint*,aq,ampl(j),const
           aml(jkl,j)=aq*ampl(j)*const
           EndDo
C-----------azimuthal loop--E
1          ENDDO
C-----------period loop---------------------------E
c----------Source term calculations-----------------E
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
C----------------unwrap phase and get group time---S
           do jkl=1,181
             do j=1,nt
           temp_ph(j)=pq(jkl,j)
           if(aml(jkl,j).gt.ampl_max(j))ampl_max(j)=aml(jkl,j)
           enddo
C          write(75,*)'jkl=',jkl
           call unwrap(dper,t,nt,temp_ph,unph,grt,r,jkl)
             do j=1,nt
           pq(jkl,j)=unph(j)
           gr_time(jkl,j)=grt(j)
           ph(jkl,j)=unph(j)
C          write(18,*) t(j),temp_ph(j),unph(j),grt(j),jkl*2
              enddo
C          write(18,'(1X)')
           write(19,'(1X)')
           enddo
C----------------unwrap phase and get group time---E
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
C----azimuth-dependent output for a set of requested periods------S
           DO jop=1,np 
           if(lout)then
       iper=period(jop)
       sym3='  '
       if(iper.lt.10) write(sym3,'(i1)')iper
       if(iper.ge.10) write(sym3,'(i2)')iper
       lp=lnblnk(sym3)
      open(15,file=infile(1:lin)//'_T_AZ_s'//word(1:lw)//'_p'//sym3(1:lp))
      open(16,file=infile(1:lin)//'_AMP_AZ_s'//word(1:lw)//'_p'//sym3(1:lp))
      open(17,file=infile(1:lin)//'_PHA_AZ_s'//word(1:lw)//'_p'//sym3(1:lp))
                 endif
C---------------selection and output -----------------------S
           Do jpa=1,nt 
           qq=eps1*t(jpa)/t(nt)
           if(abs(period(jop)-t(jpa)).lt.eps)then
           PRint*,t(jpa),ampl_max(jpa),qq
C--------------patch for weak amplitudes---S
           do i=1,jkl
           m=0
C--------------patch for weak amplitudes---S
CC         if(aml(i,jpa)/ampl_max(jpa).lt.qq)then
CC           if(m.eq.0)k=i-1
CC            m=m+1
CC           gr_time(i,jpa)=gr_time(k,jpa)
CC           aml(i,jpa)=qq*ampl_max(jpa)
CC           pq(i,jpa)=pq(k,jpa)
CC                             endif
            enddo
C--------------patch for weak amplitudes---E
           do jkl=1,181
           write(15,'(F7.2,1X,E12.5,1X,F7.1)'),2.*(jkl-1),gr_time(jkl,jpa),t(jpa)
           write(16,'(F7.2,1X,E12.5,1X,F7.1)'),2.*(jkl-1),aml(jkl,jpa),t(jpa)
           write(17,'(F7.2,1X,E12.5,1X,F7.1)'),2.*(jkl-1),pq(jkl,jpa),t(jpa)
           enddo
                                             endif
           endDO
C---------------selection and output -----------------------E
           if(lout)then
           close(15)
           close(16)
           close(17)
                  else
           write(15,'(1X)')
           write(16,'(1X)')
           write(17,'(1X)')
                   endif
           endDO
C----azimuth-dependent output for a set of requested periods------E
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
           end
