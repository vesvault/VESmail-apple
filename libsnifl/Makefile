VESMAIL_PATH=../../..
VM=$(VESMAIL_PATH)

SNIFL_PATH=$(VM)/snif/tunl/snif-tunl
SL=$(SNIFL_PATH)/snifl

OPENSSL_INC_PATH=/Users/test1/openssl/include

SL_CFLAGS=-I$(SNIFL_PATH) \
-I$(OPENSSL_INC_PATH)


O=-libx.o


COBJS=$(VM)/snif/tunl$O \
    $(SL)/tunl$O $(SL)/v4$O $(SL)/tcp$O $(SL)/udp$O $(SL)/sock$O $(SL)/mgr$O $(SL)/dns$O

all:	libsnifl.a

%$O:	%.c
	$(CC) $(CFLAGS) $(SL_CFLAGS) -c -o $@ $<
 
libsnifl.a:	$(COBJS)
	ar cru libsnifl.a $(COBJS)
	ranlib libsnifl.a

clean:
	rm $(COBJS)
	rm libsnifl.a

