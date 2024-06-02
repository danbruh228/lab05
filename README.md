[![Coverage Status](https://coveralls.io/repos/github/WhiteSunOfSpace/lab05/badge.svg?branch=master)](https://coveralls.io/github/WhiteSunOfSpace/lab05?branch=master)

# Лабораторная работа 5

## Homework

### Задание
1. Создайте `CMakeList.txt` для библиотеки *banking*.
2. Создайте модульные тесты на классы `Transaction` и `Account`.
    * Используйте mock-объекты.
    * Покрытие кода должно составлять 100%.
3. Настройте сборочную процедуру на **TravisCI**.
4. Настройте [Coveralls.io](https://coveralls.io/).


### Создание необходимых файлов и папок
```sh
$ mkdir third-party
$ git submodule add https://github.com/google/googletest third-party/gtest
$ touch CMakeLists.txt
```

```sh
$ mkdir .coverage
$ touch lcov.info
$ mkdir tests
$ cd tests
$ touch test_Account.cpp
$ touch test_Transaction.cpp
```

```sh
$ mkdir .github/workflows
$ cd .github/workflows
$ touch actions.yml
```

```sh
Исправим Transaction.cpp // допущена логическая ошибка
- bool success = Debit(to, sum + fee_);
+ bool success = Debit(from, sum + fee_);
```

## Содержание файлов

### test_Account.cpp
```sh
#include <Account.h>
#include <gtest/gtest.h>

TEST(Account, Banking){
	Account test(0,0);
	
	ASSERT_EQ(test.GetBalance(), 0);
	
	ASSERT_THROW(test.ChangeBalance(100), std::runtime_error);
	
	test.Lock();
	
	ASSERT_NO_THROW(test.ChangeBalance(100));
	
	ASSERT_EQ(test.GetBalance(), 100);

	ASSERT_THROW(test.Lock(), std::runtime_error);

	test.Unlock();
	ASSERT_THROW(test.ChangeBalance(100), std::runtime_error);
}
```

### test_Transaction.cpp
```sh
#include <Account.h>
#include <Transaction.h>
#include <gtest/gtest.h>

TEST(Transaction, Banking){
	const int base_A = 5000, base_B = 5000, base_fee = 100;
	
	Account Alice(0,base_A), Bob(1,base_B);
	Transaction test_tran;

	ASSERT_EQ(test_tran.fee(), 1);
	test_tran.set_fee(base_fee);
	ASSERT_EQ(test_tran.fee(), base_fee);

	ASSERT_THROW(test_tran.Make(Alice, Alice, 1000), std::logic_error);
	ASSERT_THROW(test_tran.Make(Alice, Bob, -50), std::invalid_argument);
	ASSERT_THROW(test_tran.Make(Alice, Bob, 50), std::logic_error);
	if (test_tran.fee()*2-1 >= 100)
		ASSERT_EQ(test_tran.Make(Alice, Bob, test_tran.fee()*2-1), false);

	Alice.Lock();
	ASSERT_THROW(test_tran.Make(Alice, Bob, 1000), std::runtime_error);
	Alice.Unlock();

	ASSERT_EQ(test_tran.Make(Alice, Bob, 1000), true);
	ASSERT_EQ(Bob.GetBalance(), base_B+1000);	
	ASSERT_EQ(Alice.GetBalance(), base_A-1000-base_fee);

	ASSERT_EQ(test_tran.Make(Alice, Bob, 3900), false);
	ASSERT_EQ(Bob.GetBalance(), base_B+1000);	
	ASSERT_EQ(Alice.GetBalance(), base_A-1000-base_fee);
}
```

### CMakeLists.txt
```sh
cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build tests" OFF)

if(BUILD_TESTS)                   
  add_compile_options(--coverage) 
endif()

project (banking)

add_library(banking STATIC ${CMAKE_CURRENT_SOURCE_DIR}/banking/Transaction.cpp ${CMAKE_CURRENT_SOURCE_DIR}/banking/Account.cpp)
target_include_directories(banking PUBLIC
${CMAKE_CURRENT_SOURCE_DIR}/banking )

target_link_libraries(banking gcov)

if(BUILD_TESTS)
  enable_testing()
  add_subdirectory(third-party/gtest)
  file(GLOB BANKING_TEST_SOURCES tests/*.cpp)
  add_executable(check ${BANKING_TEST_SOURCES})
  target_link_libraries(check banking gtest_main)
  add_test(NAME check COMMAND check)
endif()
```

### actions.yml
```sh
name: Actions_for_tests

on:
 push:
  branches: [master]
 pull_request:
  branches: [master]

jobs: 
 build_Linux:

  runs-on: ubuntu-latest

  steps:
  - uses: actions/checkout@v3

  - name: Adding gtest
    run: git clone https://github.com/google/googletest.git third-party/gtest -b release-1.11.0

  - name: Install lcov
    run: sudo apt-get install -y lcov

  - name: Config banking with tests
    run: cmake -H. -B ${{github.workspace}}/build -DBUILD_TESTS=ON

  - name: Build banking
    run: cmake --build ${{github.workspace}}/build

  - name: Run tests
    run: build/check

  - name: Do lcov stuff
    run: lcov -c -d build/CMakeFiles/banking.dir/banking/ --include *.cpp --output-file ./coverage/lcov.info

  - name: Publish to coveralls.io
    uses: coverallsapp/github-action@v1.1.2
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

```
Copyright (c) 2015-2021 The ISC Authors
```
