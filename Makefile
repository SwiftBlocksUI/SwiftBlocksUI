# Makefile

# local config
SWIFT_BUILD=swift build
SWIFT_CLEAN=swift package clean
SWIFT_BUILD_DIR=.build
SWIFT_TEST=swift test
CONFIGURATION=debug
DOCKER=/usr/local/bin/docker
#DOCKER=docker

# docker config
SWIFT_BUILD_IMAGE="swift:5.3.1"
DOCKER_BUILD_DIR=".docker$(SWIFT_BUILD_DIR)"
SWIFT_DOCKER_BUILD_DIR="$(DOCKER_BUILD_DIR)/x86_64-unknown-linux/$(CONFIGURATION)"
DOCKER_BUILD_PRODUCT="$(DOCKER_BUILD_DIR)/$(TOOL_NAME)"


SWIFT_SOURCES=\
	Sources/*/*/*.swift \
	Sources/*/*/*/*.swift

all: all-native

#all: docker-all

all-native:
	$(SWIFT_BUILD) -c $(CONFIGURATION)

# Cannot test in `release` configuration?!
test:
	$(SWIFT_TEST) 
	
clean :
	$(SWIFT_CLEAN)
	# We have a different definition of "clean", might be just German
	# pickyness.
	rm -rf $(SWIFT_BUILD_DIR) 

$(DOCKER_BUILD_PRODUCT): $(SWIFT_SOURCES)
	$(DOCKER) run --rm \
          -v "$(PWD):/src" \
          -v "$(PWD)/$(DOCKER_BUILD_DIR):/src/.build" \
          "$(SWIFT_BUILD_IMAGE)" \
          bash -c 'cd /src && swift build -c $(CONFIGURATION)'

docker-all: $(DOCKER_BUILD_PRODUCT)

docker-test: docker-all
	$(DOCKER) run --rm \
          -v "$(PWD):/src" \
          -v "$(PWD)/$(DOCKER_BUILD_DIR):/src/.build" \
          "$(SWIFT_BUILD_IMAGE)" \
          bash -c 'cd /src && swift test -c $(CONFIGURATION)'

docker-clean:
	rm $(DOCKER_BUILD_PRODUCT)	
	
docker-distclean:
	rm -rf $(DOCKER_BUILD_DIR)

distclean: clean docker-distclean

docker-emacs:
	$(DOCKER) run --rm -it \
	          -v "$(PWD):/src" \
	          -v "$(PWD)/$(DOCKER_BUILD_DIR):/src/.build" \
	          "$(SWIFT_BUILD_IMAGE)" \
		  emacs /src
