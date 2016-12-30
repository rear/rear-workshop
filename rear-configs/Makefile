
name=rear-workshop
specfile=$(name).spec
version := $(shell awk 'BEGIN { FS=":" } /^Version:/ { print $$2}' $(specfile) | awk '{print $$1}' )

all: dist rpm

dist: $(name).tar.gz

$(name).tar.gz:
	@echo "Building $(name).tar.gz archive"
	tar zcf ../$(name).tar.gz \
	--exclude=Makefile \
	--transform='s,^\.,$(name)-$(version),S' .

rpm: $(specfile)
	rpmbuild -v -tb --clean \
		../$(name).tar.gz

clean:
	-rm -f ../$(name).tar.gz
