
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

PROG = ATS660_NPT_LongRecord
OBJS = ATS660_NPT_LongRecord.o

$(PROG) : $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LIBS)

ATS660_NPT_LongRecord.o : ATS660_NPT_LongRecord.cpp
	$(CC) -c $(CFLAGS) ATS660_NPT_LongRecord.cpp

clean :
	rm -f $(PROG) *.o *~