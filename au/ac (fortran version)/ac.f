c***************************************************************
c      AC
c      Pere Casellas 2015
c      Laboratori d'envol
c      V 20150208 
c      GNU General Public License 3.0 (http://www.gnu.org)
c***************************************************************
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      VARIABLES DECLARATION
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      Some variables not used, I need clean

       real x1,y1,z1,x2,y2,z2
       real p1x,p1y,p1z,p2x,p2y,p2z


       real px0,py0,ptheta
c       real pa,pb,pc,pd,pe,pf
       real pa1l,pa2l,phl,pa1r,pasr,phr
       real pl1x(0:100,300),pl1y(0:100,300),pl2x(0:100,300),
     + pl2y(0:100,300)
       real pr1x(0:100,300),pr1y(0:100,300),pr2x(0:100,300),
     + pr2y(0:100,300)

       real plx(300),ply(300),plz(300)

       real hol(0:100,20,20),skin(10,10)

       real xsob(10),ysob(10)

       real x(500), y(500), z(500)
     
c      Inicialitza variables
       real punt(1000), pk(1000), cotaeix(1000), ve(1000), pve(1000)
       real plie(1000), ce(1000), pe(1000), desf(1000)
       real cd(1000), pd(1000), plid(1000), vd(1000), pvd(1000)
       real cote(1000), cotd(1000)
       
       real xx1(1000), yy1(1000), zz1(1000)
       real xx2(1000), yy2(1000), zz2(1000)
       real xx3(1000), yy3(1000), zz3(1000)
       real xx4(1000), yy4(1000), zz4(1000)
       real xx7(1000), yy7(1000), zz7(1000)

       real xxco(1000), xyco(1000)

       character(100) nom1(1000), nom2(1000), nom3(1000),
     + nom4(1000), nom5(1000)

       character(50) aname

c       pi=4.*atan(1.)

c      integer color
c      integer linecolor,pointcolor

       write (*,*) 
       write (*,*) "**************************************************"
       write (*,*) "PROGRAMA airfoil converter"
       write (*,*) "classical .dat format to .txt LEparagliding format"
       write (*,*)
       write (*,*) "Pere Casellas"
       write (*,*)
       write (*,*) "GNU General Public License 3.0 http://www.gnu.org"
       write (*,*) "**************************************************"
       write (*,*)
       write (*,*)
      

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      MOTOR DE CALCUL
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       open(unit=20, file='airfoil.dxf')
       open(unit=21, file='acdata.txt')
       open(unit=22, IOSTAT=nios, file='airfoil.dat')
       open(unit=23,file='airfoil.txt')
c       open (unit=25,file='sup3d.dxf') 
       
       call dxfinit(20)
c       call dxfinit(25)
       
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      Lectura de del fitxer de dades
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      
       rewind (21)
       rewind (22)
       rewind (23)

c      Read data

       read (21,*) xin, jin
       read (21,*) xou, jou
       read (21,*) xcale

       k=0
       
c      Maximal allowed lines in file .dat = 10000  

c      Read airfoil name 
        
       read (22,*) aname
       write (*,*) "Airfoil name = ", aname

c      Read airfoil coordinates       
       
       do

c       write (*,*) k, nios
       
c      Llegeix mentre no s'arriba a fi de fitxer       
      
c      read (22,*, IOSTAT=nios) xxco(1), xyco(1)

       if (nios.ge.0) then
               
       k=k+1
               
       read (22,*,IOSTAT=nios) xxco(k), xyco(k)

       write (*,'(F9.6,4x,F9.6)') xxco(k), xyco(k)

       end if

c       write (*,*) k, nios

       if (nios.lt.0) then

               exit

       end if

       end do

       kmax=k
       
cccccccccccccccccccccccccccccccccccccccccccccccc
c      Interpolation of in and out air intakes
cccccccccccccccccccccccccccccccccccccccccccccccc

       do k=1,kmax-1


c      IF jin eq 1 cccccccccccccccccccccccccccccccccccccc

       if (jin.eq.1.and.xyco(k).gt.0) then

c      IN
       if (xin.ge.xxco(k+1)*100.and.xin.lt.xxco(k)*100.) then

       xm=(xyco(k+1)-xyco(k))/(xxco(k+1)-xxco(k))
       xb=xyco(k)-xm*xxco(k)

       xxcok=xin/100.
       xycok=xm*xxcok+xb

       xd1=sqrt((xxcok-xxco(k))**2+(xycok-xyco(k))**2)
       xd2=sqrt((xxcok-xxco(k+1))**2+(xycok-xyco(k+1))**2)

       if (xd1.le.xd2) then
       xxco(k)=xxcok
       xyco(k)=xycok
       end if

       if (xd1.gt.xd2) then
       xxco(k+1)=xxcok
       xyco(k+1)=xycok
       end if

       kin=k
       
       end if
  
       end if


c      IF jin eq 0 or -1 ccccccccccccccccccccccccccccccccccccccc

       if (jin.eq.-1.or.jin.eq.0) then

       if (k.gt.12.and.xyco(k).le.0) then

c      IN
       if (xin.ge.xxco(k)*100.and.xin.lt.xxco(k+1)*100.) then

       xm=(xyco(k+1)-xyco(k))/(xxco(k+1)-xxco(k))
       xb=xyco(k)-xm*xxco(k)

       xxcok=xin/100.
       xycok=xm*xxcok+xb

       xd1=sqrt((xxcok-xxco(k))**2+(xycok-xyco(k))**2)
       xd2=sqrt((xxcok-xxco(k+1))**2+(xycok-xyco(k+1))**2)

       if (xd1.le.xd2) then
       xxco(k)=xxcok
       xyco(k)=xycok
       end if

       if (xd1.gt.xd2) then
       xxco(k+1)=xxcok
       xyco(k+1)=xycok
       end if

       kin=k
       
       end if
       
       end if

       end if


c      OUT

c      OUT 

       if (jou.eq.-1.and.xyco(k).le.0) then

       if (xou.ge.xxco(k)*100.and.xou.lt.xxco(k+1)*100.) then

       xm=(xyco(k+1)-xyco(k))/(xxco(k+1)-xxco(k))
       xb=xyco(k)-xm*xxco(k)

       xxcok=xou/100.
       xycok=xm*xxcok+xb

       xd1=sqrt((xxcok-xxco(k))**2+(xycok-xyco(k))**2)
       xd2=sqrt((xxcok-xxco(k+1))**2+(xycok-xyco(k+1))**2)

       if (xd1.le.xd2) then
       xxco(k)=xxcok
       xyco(k)=xycok
       end if 

       if (xd1.gt.xd2) then
       xxco(k+1)=xxcok
       xyco(k+1)=xycok
       end if

       kou=k
       
       end if

       end if

       end do

ccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      Print airfoil.txt
ccccccccccccccccccccccccccccccccccccccccccccccccccccc

       write (23,'(A50)') aname
       write (23,'(I4)') kmax-1
       write (23,'(I4)') kin
       write (23,'(I4)') kou-kin+1
       write (23,'(I4)') kmax-kou+1-1

       do k=1,kmax-1

       write (23,'(F9.6,4x,F9.6)') xxco(k), xyco(k)*xcale
         
       end do

ccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      Create airfoil.dxf
ccccccccccccccccccccccccccccccccccccccccccccccccccccc

       do k=1,kmax-2

       call line(100.*xxco(k), -100.*xyco(k)*xcale, 
     + 100.*xxco(k+1), -100.*xyco(k+1)*xcale, 1)
         
       end do
       

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      Final del programa principal
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c       call dxfend(25)
       call dxfend(20)
       
       write (*,*)
       write (*,*) 
       write (*,*) "OK, airfoil interpolated and converted "
       write (*,*) 
       write (*,*)

       close (20)
       close (21)
       close (22)
       close (23)
       close (25)


       end 

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      SUBROUTINE LINE
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       SUBROUTINE line(p1x,p1y,p2x,p2y,linecolor)
c      line P1-P2

       real x1,x2,y1,y2,z1,z2

       write(20,'(A,/,I1,/,A)') "LINE",8,"default"
       write(20,'(I1,/,A)') 6,"CONTINUOUS"
       write(20,'(I2,/,F12.2,/,I2,/,F12.2)') 10,p1x,20,-p1y
       write(20,'(I2,/,F12.2,/,I2,/,F12.2)') 11,p2x,21,-p2y
       write(20,'(I2,/,I2,/,I2,/,I2,/,I2)') 39,0,62,linecolor,0
       return
       end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc        
c     SUBROUTINE LINE 3D
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       SUBROUTINE line3d(p1x,p1y,p1z,p2x,p2y,p2z,linecolor)
c      line P1-P2
       write(25,'(A,/,I1,/,A)') "LINE",8,"default"
       write(25,'(I1,/,A)') 6,"CONTINUOUS"
       write(25,'(I2,/,F12.2,/,I2,/,F12.2,/,I2,/,F12.2)') 
     + 10,p1x,20,p1y,30,p1z
       write(25,'(I2,/,F12.2,/,I2,/,F12.2,/,I2,/,F12.2)') 
     + 11,p2x,21,p2y,31,p2z
       write(25,'(I2,/,I2,/,I2,/,I2,/,I2)') 39,0,62,linecolor,0
       return
       end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      POLYLINE 2D
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       SUBROUTINE poly2d(plx,ply,nvertex,linecolor)

       real plx(300),ply(300),plz(300)

       write (20,'(A,/,I1,/,I1,/,I2)') "POLYLINE",8,0,62
       write (20,'(I3,/,I2,/,I1)') linecolor,66,1
       write (20,'(I2,/,F3.1,/,I2,/,F3.1,/,I2,/,F3.1,/,I1)') 
     + 10,0.0,20,0.0,30,0.0,0
       
       do k=1,nvertex

       write (20,'(A,/,I1,/,I1,/,I2)') "VERTEX",8,0,62
       write (20,'(I3,/,I2,/,I1)') linecolor,66,1 
       write (20,'(I2,/,F9.3,/,I2,/,F9.3,/,I2,/,F9.3,/,I1)') 
     + 10,plx(k),20,ply(k),30,0.0,0

       end do
       
       write (20,'(A,/,I1,/,I1,/,I2)') "SEQEND",8,0,62
       write (20,'(I3,/,I1)') linecolor,0 

       write (*,'(A,/,I1,/,I1,/,I2)') "POLYLINE",8,0,62
       write (*,'(I3,/,I2,/,I1)') linecolor,66,1
       write (*,'(I2,/,F3.1,/,I2,/,F3.1,/,I2,/,F3.1,/,I1)') 
     + 10,0.0,20,0.0,30,0.0,0
       
       do k=1,nvertex

       write (*,'(A,/,I1,/,I1,/,I2)') "VERTEX",8,0,62
       write (*,'(I3,/,I2,/,I1)') linecolor,66,1 
       write (*,'(I2,/,F9.3,/,I2,/,F9.3,/,I2,/,F9.3,/,I1)') 
     + 10,plx(k),20,ply(k),30,0.0,0

       end do

       write (*,'(A,/,I1,/,I1,/,I2)') "SEQEND",8,0,62
       write (*,'(I3,/,I1)') linecolor,0 

       return

       end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      ELLIPSE
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       SUBROUTINE ellipse(u0,v0,a,b,tet0,linecolor)

       real xe(300),ye(300)

       pi=4.*atan(1.)

       do ll=1,40

       tet=2.*pi*((float(ll)-1.)/39.)

c       write (*,*) ll,float(ll),tet," ",pi,"---"

       xe(ll)=u0+a*cos(tet)*cos(tet0)-b*sin(tet)*sin(tet0)
       ye(ll)=v0+a*cos(tet)*sin(tet0)+b*sin(tet)*cos(tet0)

       end do

       do ll=1,39

       p1x=xe(ll)
       p2x=xe(ll+1)
       p1y=ye(ll)
       p2y=ye(ll+1)

       call line(p1x,p1y,p2x,p2y,linecolor)

c       write (*,*) ll,tet*180./pi,xe(ll),ye(ll)

       end do

       return

       end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c DXF init
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
       
       SUBROUTINE dxfinit(nunit)
       
       write(nunit,'(I1,/,A,/,I1)') 0,"SECTION",2
       write(nunit,'(A)') "HEADER"
       write(nunit,'(I1,/,A)') 9,"$EXTMAX"
       write(nunit,'(I2,/,F12.3,/,I2,/,F12.3)') 10,-900.,20,90.
       write(nunit,'(I1,/,A)') 9,"$EXTMIN"
       write(nunit,'(I2,/,F12.3,/,I2,/,F12.3)') 10,5000.,20,-3000.
       write(nunit,'(I1,/,A,/,I1)') 0,"ENDSEC",0
       write(nunit,'(A,/,I1)') "SECTION",2
       write(nunit,'(A,/,I1)') "ENTITIES",0

       return
       end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c DXF end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE dxfend(nunit)

      write(nunit,'(A,/,I1,/,A)') "ENDSEC",0,"EOF"
      return
      end


      
