#
INST_DIR = $(HOME)/bin

#BIN  = justCOR_part_station
BIN  = justCOR


fflags = -O2 -ffixed-line-length-none
#fflags = -fast -Mextend -Msave
#fflags =  -O -e

# if you don't use shared libraries comment the next line
#shlib = -R/opt/SUNWspro/lib

FFLAGS = $(DBG)  $(fflags) $(shlib)

CFLAGS = $(DBG)

LDLIBS = -lfftw3
#LDLIBS = -L/usr/local/lib -lfftw3

#FC = g77
FC=gfortran
DBG = 
all : $(BIN)

FOBJS = dcommon.o dmultifft.o justcor.o

$(BIN) : $(FOBJS)
	$(FC) $(FFLAGS) $(CFLAGS) $(FOBJS) -o $(BIN) $(LDLIBS) 

install : $(BIN)
	install  -s $(BIN) $(INST_DIR)

clean :
	rm -f $(BIN) core $(FOBJS)
