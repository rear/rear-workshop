
specfile=$(name).spec
version := $(shell date +"%Y_%m_%d__%H_%M_%S")

all: dist rpm

dist: $(name).tar.gz

$(name).tar.gz:
	@echo "Building $(name).tar.gz archive"
	mkdir -p build
	tar zcf build/$(name).tar.gz \
	--exclude=Makefile \
	--transform='s,^\.,$(name)-$(version),S' .

rpm: $(specfile)
	mkdir -p build
	test -l build/noarch || { rm -Rf build/noarch ; ln -svf .. build/noarch ; }
	rpmbuild -v -tb --clean --nodeps \
		--define="_topdir $(CURDIR)/build" --define="_rpmdir %{_topdir}" \
		--define="_version $(version)" \
		build/$(name).tar.gz

clean:
	-rm -Rf build
