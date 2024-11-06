@echo off
setlocal EnableDelayedExpansion

:: Check if package name is provided
if "%1"=="" (
    echo Usage: %0 package_name
    exit /b 1
)

set PACKAGE_NAME=%1

:: Function to convert snake_case to PascalCase
set PASCAL_CASE_PACKAGE_NAME=
for %%a in (%PACKAGE_NAME:_= %) do (
    set "WORD=%%a"
    set "FIRST_LETTER=!WORD:~0,1!"
    set "REMAINDER=!WORD:~1!"
    for %%b in (!FIRST_LETTER!) do (
        call :ToUpper "%%b" UPPER_LETTER
    )
    set "PASCAL_WORD=!UPPER_LETTER!!REMAINDER!"
    set "PASCAL_CASE_PACKAGE_NAME=!PASCAL_CASE_PACKAGE_NAME!!PASCAL_WORD!"
)

goto :CONTINUE

:ToUpper
set "char=%~1"
for %%A in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    if /I "!char!"=="%%A" (
        for %%B in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
            if /I "%%A"=="%%B" (
                set "%2=%%B"
            )
        )
    )
)
goto :EOF

:CONTINUE

:: Create directories inside packages/features
mkdir packages\features\%PACKAGE_NAME%\lib\src\l10n

:: Create the state Dart file with the initial code
(
    echo part of ^'%PACKAGE_NAME%_cubit.dart^';
    echo.
    echo abstract class %PASCAL_CASE_PACKAGE_NAME%State extends Equatable {
    echo     const %PASCAL_CASE_PACKAGE_NAME%State^(^)^;
    echo.
    echo     ^@override
    echo     List^<Object^?^> get props ^=^> ^[^];
    echo }
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%InProgress extends %PASCAL_CASE_PACKAGE_NAME%State {}
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%Loaded extends %PASCAL_CASE_PACKAGE_NAME%State {}
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%Failure extends %PASCAL_CASE_PACKAGE_NAME%State {}
) > packages\features\%PACKAGE_NAME%\lib\src\%PACKAGE_NAME%_state.dart

:: Create the cubit Dart file with the provided initial code
(
    echo import ^'package:flutter_bloc/flutter_bloc.dart^';
    echo import ^'package:equatable/equatable.dart^';
    echo.
    echo part ^'%PACKAGE_NAME%_state.dart^';
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%Cubit extends Cubit^<%PASCAL_CASE_PACKAGE_NAME%State^> {
    echo     %PASCAL_CASE_PACKAGE_NAME%Cubit^(^) : super^(%PASCAL_CASE_PACKAGE_NAME%InProgress^(^)^) {
    echo         onInit^(^)^;
    echo     }
    echo.
    echo     void onInit^(^)^ {}
    echo }
) > packages\features\%PACKAGE_NAME%\lib\src\%PACKAGE_NAME%_cubit.dart

:: Create the screen Dart file with the provided content
(
    echo import ^'package:%PACKAGE_NAME%/src/%PACKAGE_NAME%_cubit.dart^';
    echo import ^'package:flutter/material.dart^';
    echo import ^'package:flutter_bloc/flutter_bloc.dart^';
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%Screen extends StatelessWidget {
    echo     const %PASCAL_CASE_PACKAGE_NAME%Screen^(^{super.key^}^);
    echo.
    echo     ^@override
    echo     Widget build^(BuildContext context^) {
    echo         return BlocProvider^(
    echo             create: ^(_^) ^=^> %PASCAL_CASE_PACKAGE_NAME%Cubit^(^),
    echo             child: const %PASCAL_CASE_PACKAGE_NAME%View^(^),
    echo         ^);
    echo     }
    echo }
    echo.
    echo class %PASCAL_CASE_PACKAGE_NAME%View extends StatelessWidget {
    echo     const %PASCAL_CASE_PACKAGE_NAME%View^(^{super.key^}^);
    echo.
    echo     ^@override
    echo     Widget build^(BuildContext context^) {
    echo         return BlocBuilder^<%PASCAL_CASE_PACKAGE_NAME%Cubit, %PASCAL_CASE_PACKAGE_NAME%State^>(
    echo             builder: ^(context, state^) {
    echo                 return Container^(^);
    echo             }^,
    echo         ^);
    echo     }
    echo }
) > packages\features\%PACKAGE_NAME%\lib\src\%PACKAGE_NAME%_screen.dart

:: Create the main export Dart file under lib
(
    echo export ^'src/%PACKAGE_NAME%_screen.dart^';
    echo export ^'src/l10n/%PACKAGE_NAME%_localizations.dart^';
) > packages\features\%PACKAGE_NAME%\lib\%PACKAGE_NAME%.dart

:: Create l10n.yaml file with the specified configuration
(
    echo arb-dir: lib/src/l10n
    echo template-arb-file: messages_en.arb
    echo output-localization-file: %PACKAGE_NAME%_localizations.dart
    echo output-class: %PASCAL_CASE_PACKAGE_NAME%Localizations
    echo synthetic-package: false
    echo nullable-getter: false
) > packages\features\%PACKAGE_NAME%\l10n.yaml

:: Write JSON content to messages_en.arb file
(
    echo {
    echo     "greeting": "Hello"
    echo }
) > packages\features\%PACKAGE_NAME%\lib\src\l10n\messages_en.arb

:: Write JSON content to messages_ar.arb file (Arabic version)
(
    echo {
    echo     "greeting": "مرحبا"
    echo }
) > packages\features\%PACKAGE_NAME%\lib\src\l10n\messages_ar.arb

:: Create a default pubspec.yaml for the feature package
(
    echo name: %PACKAGE_NAME%
    echo publish_to: none
    echo.
    echo environment:
    echo   sdk: ">=3.0.5 <4.0.0"
    echo.
    echo dependencies:
    echo   component_library:
    echo     path: ../../component_library
    echo.
    echo   flutter_bloc: ^^8.1.5
    echo   flutter:
    echo     sdk: flutter
    echo.
    echo   flutter_localizations:
    echo     sdk: flutter
    echo.
    echo   smooth_page_indicator: ^^1.1.0
    echo   intl: ^^0.19.0
    echo.
    echo   equatable: ^^2.0.5
    echo.
    echo dev_dependencies:
    echo   flutter_test:
    echo     sdk: flutter
    echo   mocktail: ^^1.0.3
    echo   test: ^^1.16.8
    echo   flutter_lints: ^^4.0.0
    echo.
    echo flutter:
    echo   uses-material-design: true
) > packages\features\%PACKAGE_NAME%\pubspec.yaml

:: Create analysis_options.yaml file
(
    echo include: package:flutter_lints/flutter.yaml
) > packages\features\%PACKAGE_NAME%\analysis_options.yaml

echo Feature package %PACKAGE_NAME% created successfully!

:: usage
:: create_feature.bat test_pack_yo
