
CC := g++
PLX_OPT := $(PLX_OPT) -DPCI_CODE -DPLX_LITTLE_ENDIAN -DPLX_LINUX

# DEBUG := 1
ifdef DEBUG
   CC_OPT := $(CC_OPT) -g3
   PLX_OPT := $(PLX_OPT) -DPLX_DEBUG
else
   CC_OPT := $(CC_OPT) -O2
endif

CFLAGS := $(CFLAGS) -c -Wall $(CC_OPT) $(PLX_OPT)
LIBS := $(LIBS) -lATSApi

PROG = ATS9350_CS_StreamToMemory
OBJS = ATS9350_CS_StreamToMemory.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS9350_CS_StreamToMemory.o : ATS9350_CS_StreamToMemory.cpp
	$(CC) -c $(CFLAGS) ATS9350_CS_StreamToMemory.cpp

clean :
	rm -f $(PROG) *.o *~