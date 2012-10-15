CC = "gcc"
CXX = "g++"
# CXXFLAGS = "-arch i386 -g"
CXXFLAGS = "-w -flat_namespace -undefined suppress -fkeep-inline-functions"

AddonsDir = "addons"
LibsDir = "libs"
BuildDir = "build"
SharedObject = "libof.so"

SrcIgnore = /(gst|fmod|quicktime|glut|systemutils|sound)/i
# ofSystemUtils uses deprecated 32bit calls

Defines = "-DTARGET_OSX -DOF_VIDEO_CAPTURE_QTKIT -DOF_VIDEO_PLAYER_QTKIT"
OpenFrameworksIncludeDirs = FileList["#{LibsDir}/openFrameworks/*"].reject { |d| d =~ /\./ } + ["#{LibsDir}/openFrameworks/"]
LibraryIncludeDirs = FileList["#{LibsDir}/**/include/**/"]
Includes = (OpenFrameworksIncludeDirs + LibraryIncludeDirs).map { |i| "-idirafter #{i}"}

Src = FileList["#{LibsDir}/**/*"].select { |f| f =~ /\.cpp$/ }.reject { |f| f =~ SrcIgnore }
Obj = Src.map { |src| "#{BuildDir}/#{File.basename(src).ext('o')}" }
Frameworks = %w[OpenGL QTKit CoreAudio Carbon].map { |f| "-framework #{f} " }
Libraries = FileList["#{LibsDir}/*/lib/osx/*"].select { |f| f =~ /\.a$/ }.reject { |f| f =~ /(openFrameworks)/}

AddonsIncludes = FileList["#{AddonsDir}/**/*"].reject { |f| f =~ /\..*$/  }.map { |f| "-idirafter #{f}" }

task :default => "build:shared"

namespace :show do
  desc "Print out include flags"
  task "includes" do
    print Includes
  end

  desc "Measure size of class"
  task :sizeof, :klass, :header do |t, args|
    klass = args[:klass]
    header = args[:header]

    bin_filename = "sizeof-#{klass.hash}"
    src_filename = "#{bin_filename}.cc"

    File.open(src_filename, 'w') do |f|
      f.write <<-END_CODE
        #include "ofMain.h"
        #{"#include \"" + header + "\"" if header}
        #include <stdio.h>

        int main(int argc, char** argv) { printf("%ld\\n", sizeof(#{klass})); return 0; }
      END_CODE

      f.flush
      `g++ #{Includes} #{AddonsIncludes} #{src_filename} -o #{bin_filename}`
      puts `./#{bin_filename}`
      `rm -fr sizeof-*`
    end
  end
end

namespace :build do
  # synthesize openframeworks source dependancies
  Obj.zip(Src).each do |obj, src|
    file obj => src do
      mkdir_p "build"
      sh "#{CXX} -c #{CXXFLAGS} #{Defines} #{Includes} -o #{obj} #{src}"
    end
  end

  desc "Build #{SharedObject}, 64bit OF shared library"
  task :shared => Obj do
    sh "#{CXX} -shared #{CXXFLAGS} -o #{SharedObject} #{Obj.join ' '}"
  end

  desc "Build a 64bit OF addon shared library"
  task :addon, :name, :flags do |t, args|
    name = args[:name]
    flags = args[:flags]
    sources = FileList["#{AddonsDir}/ofx#{name}/**/*"].select { |f| f =~ /\.cpp$/ }
    
    sh "#{CXX} -shared #{CXXFLAGS} #{AddonsIncludes} #{Includes} #{flags} -o ofx#{name}.so #{sources.join ' '}"
  end

  desc "Clean #{BuildDir}/ directory"
  task :clean do
    rm_rf "build"
  end

  desc "Clean everything"
  task :cleanall => :clean do
    rm "*.so"
  end
end