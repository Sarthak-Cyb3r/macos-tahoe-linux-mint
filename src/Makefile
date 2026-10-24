CC ?= gcc
CFLAGS ?= -shared -fPIC -O2
LDFLAGS ?= -ldl
TARGET ?= libplank-noglow.so
SRC ?= libplank-noglow.c
DESTDIR ?= ~/.local/lib

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

install: $(TARGET)
	mkdir -p $(DESTDIR)
	cp $(TARGET) $(DESTDIR)/$(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all install clean
