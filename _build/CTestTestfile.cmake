# CMake generated Testfile for 
# Source directory: /home/vboxuser/WhiteSunOfSpace/workspace/lab05/lab05
# Build directory: /home/vboxuser/WhiteSunOfSpace/workspace/lab05/lab05/_build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(check "/home/vboxuser/WhiteSunOfSpace/workspace/lab05/lab05/_build/check")
set_tests_properties(check PROPERTIES  _BACKTRACE_TRIPLES "/home/vboxuser/WhiteSunOfSpace/workspace/lab05/lab05/CMakeLists.txt;26;add_test;/home/vboxuser/WhiteSunOfSpace/workspace/lab05/lab05/CMakeLists.txt;0;")
subdirs("third-party/gtest")
