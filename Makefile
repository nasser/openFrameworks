LIBS_DIR = libs

### 
CC = gcc
CXX = g++
CXXFLAGS = -arch i386 -g

### openFrameworks
DEFINES = -DOF_SOUND_PLAYER_QUICKTIME -DTARGET_ZAJAL
CORE_INCLUDE_DIRS = $(shell find $(LIBS_DIR)/openFrameworks -type d) 
INCLUDE_DIRS = $(shell find $(LIBS_DIR)/*/include -type d) 
INCLUDES = $(addprefix -idirafter ,$(INCLUDE_DIRS) $(CORE_INCLUDE_DIRS))

SRC = $(shell find $(LIBS_DIR)/openFrameworks -name "*.cpp" -and -not -iname "*gst*" -and -not -iname "*openal*" )
FRAMEWORKS = $(addprefix -framework ,OpenGL Glut QuickTime CoreAudio Carbon)
LIBRARIES = $(shell find $(LIBS_DIR)/*/lib/osx -name "*.a")

.PHONY: all clean

all: libof.a $(SRC)
	
libof.a:
	$(CXX) $(CXXFLAGS) $(DEFINES) $(INCLUDES) $(SRC) -c
	libtool -static -o libof.a *.o $(LIBRARIES)
	rm *.o

clean:
	rm libof.a
