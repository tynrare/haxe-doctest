@echo off
REM Copyright (c) 2016-2018 Vegard IT GmbH, http://vegardit.com
REM SPDX-License-Identifier: Apache-2.0
REM Author: Sebastian Thomschke, Vegard IT GmbH

pushd .

REM cd into project root
cd %~dp0..

echo Cleaning...
if exist dump\php rd /s /q dump\php
if exist target\php7 rd /s /q target\php7

haxelib list | findstr hx3compat >NUL
if errorlevel 1 (
    echo Installing [hx3compat]...
    haxelib install hx3compat
)

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr tink_testrunner >NUL
if errorlevel 1 (
    echo Installing [tink_testrunner]...
    haxelib install tink_testrunner
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
  -lib hx3compat ^
  -lib munit ^
  -lib tink_testrunner ^
  -cp src ^
  -cp test ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -D php7 ^
  -php target\php7
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
%PHP7_HOME%\php "%~dp0..\target\php7\index.php"
