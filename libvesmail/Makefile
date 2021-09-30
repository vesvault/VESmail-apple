VESMAIL_PATH=../../..
VM=$(VESMAIL_PATH)

LIBVES_INC_PATH=/Users/test1/libVES.c/lib
OPENSSL_INC_PATH=/Users/test1/openssl/include
CURL_INC_PATH=/Users/test1/curl/include

VM_CFLAGS=-I$(LIBVES_INC_PATH) \
-I$(OPENSSL_INC_PATH) \
-I$(CURL_INC_PATH) \
-DVESMAIL_LOCAL \
-DHAVE_CURL_CURL_H \
-DHAVE_POLL_H \
-DVESMAIL_POLL_TMOUT=45 \
-DVESMAIL_CURLSH \
-DVESMAIL_X509STORE \
-DVESMAIL_LOCAL_SNIF

AA=$@
BB=$<

O=-libx.o


COBJS=$(VM)/lib/mail$O $(VM)/lib/optns$O $(VM)/lib/parse$O $(VM)/lib/header$O $(VM)/lib/xform$O \
    $(VM)/lib/multi$O $(VM)/lib/cte$O $(VM)/lib/ves$O $(VM)/lib/encrypt$O $(VM)/lib/decrypt$O \
    $(VM)/lib/banner$O $(VM)/lib/util$O \
    $(VM)/srv/server$O $(VM)/srv/arch$O $(VM)/srv/sasl$O $(VM)/srv/override$O $(VM)/srv/curlsh$O \
    $(VM)/srv/tls$O $(VM)/srv/proc$O $(VM)/srv/daemon$O $(VM)/srv/conf$O $(VM)/srv/local$O \
    $(VM)/srv/x509store$O \
    $(VM)/imap/imap$O $(VM)/imap/imap_xform$O $(VM)/imap/imap_token$O $(VM)/imap/imap_track$O \
    $(VM)/imap/imap_start$O $(VM)/imap/imap_proxy$O $(VM)/imap/imap_msg$O \
    $(VM)/imap/imap_fetch$O $(VM)/imap/imap_result$O $(VM)/imap/imap_result_proc$O \
    $(VM)/imap/imap_sect$O $(VM)/imap/imap_append$O $(VM)/imap/imap_xves$O \
    $(VM)/smtp/smtp$O $(VM)/smtp/smtp_cmd$O $(VM)/smtp/smtp_reply$O $(VM)/smtp/smtp_track$O \
    $(VM)/smtp/smtp_start$O $(VM)/smtp/smtp_proxy$O $(VM)/smtp/smtp_xves$O \
    $(VM)/now/now$O $(VM)/now/now_store$O $(VM)/now/now_probe$O \
    $(VM)/snif/snif$O $(VM)/snif/cert$O $(VM)/snif/conn$O \
    $(VM)/util/jTree$O

all:	libvesmail.a

%$O:	%.c
	$(CC) $(CFLAGS) $(VM_CFLAGS) -c -o $@ $<
 
libvesmail.a:	$(COBJS)
	ar cru libvesmail.a $(COBJS)
	ranlib libvesmail.a

clean:
	rm $(COBJS)
	rm libvesmail.a
	rm libVES.a

aa:
	echo $(AA) $(BB)

