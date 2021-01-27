# Hey Emacs, this is a -*- makefile -*-i

# Enable verbose compilation with "make verbose=1"
ifdef verbose
 R :=
 E := @:
else
 R := @
 E := @echo
endif

DEPENDS		= ./Makefile

OBJDIR    = obj
DISTDIR   = dist
SRCDIR    = src

AS		    = lwasm
ASFLAGS   = --6809 --decb --list=$(OBJDIR)/flash.lst
ASOUT	    = -o

MKDIR     = mkdir
RM        = rm
ECHO	    = echo
DECB      = decb

IMAGE     = flash.dsk

all:	bin image $(DEPENDS)

image:	bin $(DISTDIR)/$(IMAGE)
	$(E) " Adding autoexec to image"
	$(R)$(DECB) copy -r $(SRCDIR)/autoexec.bas $(DISTDIR)/$(IMAGE),AUTOEXEC.BAS -0 -t
	$(E) " Adding flash.bin to image"
	$(R)$(DECB) copy -r -2 $(OBJDIR)/flash.bin $(DISTDIR)/$(IMAGE),FLASH.BIN
	$(E) " Adding testcart.ccc to image"
	$(R)$(DECB) copy -r -2 testcart.ccc $(DISTDIR)/$(IMAGE),TESTCART.CCC

$(DISTDIR)/$(IMAGE):
	$(E) " Creating disk image"
	$(R)$(DECB) dskini $(DISTDIR)/$(IMAGE)

bin:	$(SRCDIR)/flash.asm directories
	$(E) " Assembling flash.bin"
	$(R)$(AS) $(ASFLAGS) $(ASOUT) $(OBJDIR)/flash.bin $(SRCDIR)/flash.asm

directories: $(OBJDIR) $(DISTDIR)

$(OBJDIR):
	$(E) " Creating $(OBJDIR)"
	-$(R)$(MKDIR) $(OBJDIR)

$(DISTDIR):
	$(E) " Creating $(DISTDIR)"
	$(R)$(MKDIR) $(DISTDIR)

clean:
	$(E) " Clean"
	-$(R)$(RM) -rf $(OBJDIR) $(DISTDIR)

.PHONY:
	directories
