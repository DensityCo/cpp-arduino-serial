HASH := $(shell git rev-parse --short=10 HEAD)
OS := $(shell uname)
ARCH := $(shell uname -m)
J=12
BASE.DIR=$(PWD)
PACKAGE.DIR=$(BASE.DIR)/package
DOWNLOADS.DIR=$(BASE.DIR)/downloads
INSTALLED.HOST.DIR=$(BASE.DIR)/installed.host
INSTALLED.TARGET.DIR=$(BASE.DIR)/installed.target
CMAKE.VERSION=3.14.4
CMAKE.ARCHIVE=cmake-$(CMAKE.VERSION).tar.gz
CMAKE.URL=https://github.com/Kitware/CMake/releases/download/v$(CMAKE.VERSION)/$(CMAKE.ARCHIVE)
CMAKE.DIR=$(DOWNLOADS.DIR)/cmake-$(CMAKE.VERSION)
CMAKE.BIN=$(INSTALLED.HOST.DIR)/bin/cmake
GTEST.VERSION=1.8.1
GTEST.ARCHIVE=release-$(GTEST.VERSION).tar.gz
GTEST.URL=https://github.com/google/googletest/archive/$(GTEST.ARCHIVE)
GTEST.DIR=$(DOWNLOADS.DIR)/googletest-release-1.8.1
GTEST.BUILD=$(DOWNLOADS.DIR)/build.googletest
TESTS.BUILD=$(BASE.DIR)/build.tests
TESTS.DIR=$(BASE.DIR)/tests
TESTS.BIN=$(INSTALLED.HOST.DIR)/bin/test
ROBUSTSERIAL.BUILD=$(BASE.DIR)/build.robustserial
ROBUSTSERIAL.SOURCE=$(BASE.DIR)/src
LIBSERIAL.VERSION=1.0.0
LIBSERIAL.ARCHIVE=v$(LIBSERIAL.VERSION).tar.gz
LIBSERIAL.URL=https://github.com/crayzeewulf/libserial/archive/$(LIBSERIAL.ARCHIVE)
LIBSERIAL.DIR=$(DOWNLOADS.DIR)/libserial-$(LIBSERIAL.VERSION)
LIBSERIAL.BUILD=$(DOWNLOADS.DIR)/build.libserial
BOOST.DIR=$(DOWNLOADS.DIR)/boost_1_65_1
BOOST.ARCHIVE=boost_1_65_1.tar.bz2
BOOST.URL="https://s3.amazonaws.com/buildroot-sources/boost_1_65_1.tar.bz2"
EXAMPLES.DIR=$(BASE.DIR)/examples
EXAMPLES.BUILD=$(BASE.DIR)/build.examples

boost.clean: .FORCE
	rm -rf $(BOOST.DIR)
	rm -f $(DOWNLOADS.DIR)/$(BOOST.ARCHIVE)

boost: boost.clean
	mkdir -p $(BOOST.DIR)
	cd $(DOWNLOADS.DIR) && wget $(BOOST.URL)	
	cd $(DOWNLOADS.DIR) && tar xf $(BOOST.ARCHIVE) && cd $(BOOST.DIR) && ./bootstrap.sh --prefix=$(INSTALLED.HOST.DIR) && ./b2 stage threading=multi link=shared && ./b2 install threading=multi link=shared

libserial: libserial.clean
	mkdir -p $(DOWNLOADS.DIR)
	cd $(DOWNLOADS.DIR) && wget $(LIBSERIAL.URL) && tar xf $(LIBSERIAL.ARCHIVE)
	mkdir -p $(LIBSERIAL.BUILD)
	cd $(LIBSERIAL.BUILD) && $(CMAKE.BIN) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) -DCMAKE_INSTALL_PREFIX=$(INSTALLED.HOST.DIR) $(LIBSERIAL.DIR) && make -j$(J) install

libserial.clean: .FORCE
	rm -rf $(LIBSERIAL.BUILD)
	rm -rf $(LIBSERIAL.DIR)
	rm -f $(LIBSERIAL.ARCHIVE)

robustserial: robustserial.clean
	mkdir -p $(ROBUSTSERIAL.BUILD)
	cd $(ROBUSTSERIAL.BUILD) && $(CMAKE.BIN) $(ROBUSTSERIAL.SOURCE) && make -j$(J) install

robustserial.clean: .FORCE
	rm -rf $(ROBUSTSERIAL.BUILD)

bootstrap: cmake gtest boost libserial

ctags: .FORCE
	ctags -R --exclude=.git --exclude=installed.host --exclude=installed.target  --exclude=downloads --exclude=documents --exclude=build.* --exclude=$(TOOLCHAIN.NAME) .

socat: .FORCE
	socat -d pty,raw,echo=0 -d pty,raw,echo=0

examples.clean: .FORCE
	rm -rf $(EXAMPLES.BUILD)

examples.build: examples.clean
	mkdir -p $(EXAMPLES.BUILD)
	cd $(EXAMPLES.BUILD) && $(CMAKE.BIN) -DCMAKE_INSTALL_PREFIX=$(INSTALLED.HOST.DIR) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) $(EXAMPLES.DIR) && make -j$(J) && make install

examples.run: .FORCE
	LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib $(EXAMPLE.BIN)

gtest.fetch: .FORCE
	cd $(DOWNLOADS.DIR) && wget $(GTEST.URL) && tar xf $(GTEST.ARCHIVE)

gtest: gtest.fetch
	rm -rf $(GTEST.BUILD)
	mkdir -p $(GTEST.BUILD) && cd $(GTEST.BUILD) && $(CMAKE.BIN) -DCMAKE_INSTALL_PREFIX=$(INSTALLED.HOST.DIR) $(GTEST.DIR) && make -j$(J) install

gtest.clean: .FORCE
	rm -rf $(GTEST.BUILD)
	rm -rf $(DOWNLOADS.DIR)/$(GTEST.ARCHIVE)


cmake.fetch: .FORCE
	mkdir -p $(DOWNLOADS.DIR)
	cd $(DOWNLOADS.DIR) && wget $(CMAKE.URL) && tar xf $(CMAKE.ARCHIVE)

cmake: cmake.fetch
	cd $(CMAKE.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) --no-system-zlib && make -j8 install

cmake.clean: .FORCE
	rm -rf $(CMAKE.ARCHIVE)
	rm -rf $(CMAKE.DIR)


clean: cmake.clean tests.clean
	rm -rf $(INSTALLED.HOST.DIR)
	rm -rf $(DOWNLOADS.DIR)
	rm -rf $(PACKAGE.DIR)
	rm -f $(BASE.DIR)/tags

ci: bootstrap robustserial

.FORCE:


