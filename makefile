IDIR =../include
CC=gcc
CFLAGS=-I$(IDIR)

ODIR=obj
LDIR =../lib

LIBS=-lm

_DEPS = main.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o 
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))


#$(ODIR)/%.o: src/%.cpp $(DEPS)
$(ODIR)/%.o: src/%.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

all: $(OBJ) | DIR
	$(CC) -o tjosan  $^ $(CFLAGS) $(LIBS)

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ 
print: DIR
	echo $(OBJ)

DIR:
	mkdir -p $(ODIR)
