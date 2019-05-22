HASH := $(shell git rev-parse --short=10 HEAD)
OS := $(shell uname)
ARCH := $(shell uname -m)
J=8
BASE.DIR=$(PWD)
PACKAGE.DIR=$(BASE.DIR)/package
DOWNLOADS.DIR=$(BASE.DIR)/downloads
INSTALLED.HOST.DIR=$(BASE.DIR)/installed.host
INSTALLED.TARGET.DIR=$(BASE.DIR)/installed.target
CMAKE.URL=https://s3.amazonaws.com/buildroot-sources/cmake-3.10.2.tar.gz
CMAKE.DIR=$(DOWNLOADS.DIR)/cmake-3.10.2
CMAKE.ARCHIVE=$(DOWNLOADS.DIR)/cmake-3.10.2.tar.gz
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

bootstrap: cmake gtest

ctags: .FORCE
	ctags -R --exclude=.git --exclude=installed.host --exclude=installed.target  --exclude=downloads --exclude=documents --exclude=build.* --exclude=$(TOOLCHAIN.NAME) .

socat: .FORCE
	socat -d pty,raw,echo=0 -d pty,raw,echo=0

tests.clean: .FORCE
	rm -rf $(TESTS.BUILD)

tests.build: tests.clean
	mkdir -p $(TESTS.BUILD)
	cd $(TESTS.BUILD) && $(CMAKE.BIN) -DCMAKE_INSTALL_PREFIX=$(INSTALLED.HOST.DIR) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) $(TESTS.DIR) && make -j$(J) && make install

tests.run: .FORCE
	LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib $(TESTS.BIN)

tests: protocol tests.build tests.run


tests.debug: .FORCE
ifeq ($(OS), Linux)
	cd $(TESTS.BUILD) && LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib gdb $(INSTALLED.HOST.DIR)/bin/test
endif

ifeq ($(OS), Darwin)
	cd $(TESTS.BUILD) && LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib lldb $(INSTALLED.HOST.DIR)/bin/test
endif


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

ci: bootstrap tests

.FORCE:


