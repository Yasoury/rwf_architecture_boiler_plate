#!/bin/bash

# Check if package name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 package_name"
    exit 1
fi

PACKAGE_NAME=$1

# Function to convert snake_case to PascalCase
to_pascal_case() {
    IFS='_' read -ra WORDS <<< "$1"
    PASCAL_CASE=""
    for WORD in "${WORDS[@]}"; do
        PASCAL_WORD="$(tr '[:lower:]' '[:upper:]' <<< ${WORD:0:1})${WORD:1}"
        PASCAL_CASE="${PASCAL_CASE}${PASCAL_WORD}"
    done
    echo "$PASCAL_CASE"
}

PASCAL_CASE_PACKAGE_NAME=$(to_pascal_case "$PACKAGE_NAME")

# Create directories inside packages/features
mkdir -p "packages/features/$PACKAGE_NAME/lib/src/l10n"

# Create the state Dart file with the initial code
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/src/${PACKAGE_NAME}_state.dart"
part of '${PACKAGE_NAME}_cubit.dart';

abstract class ${PASCAL_CASE_PACKAGE_NAME}State extends Equatable {
  const ${PASCAL_CASE_PACKAGE_NAME}State();

  @override
  List<Object?> get props => [];
}

class ${PASCAL_CASE_PACKAGE_NAME}InProgress extends ${PASCAL_CASE_PACKAGE_NAME}State {}

class ${PASCAL_CASE_PACKAGE_NAME}Loaded extends ${PASCAL_CASE_PACKAGE_NAME}State {}

class ${PASCAL_CASE_PACKAGE_NAME}Failure extends ${PASCAL_CASE_PACKAGE_NAME}State {}
EOF

# Create the cubit Dart file with the provided initial code
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/src/${PACKAGE_NAME}_cubit.dart"
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${PACKAGE_NAME}_state.dart';

class ${PASCAL_CASE_PACKAGE_NAME}Cubit extends Cubit<${PASCAL_CASE_PACKAGE_NAME}State> {
  ${PASCAL_CASE_PACKAGE_NAME}Cubit() : super(${PASCAL_CASE_PACKAGE_NAME}InProgress()) {
    onInit();
  }

  void onInit() {}
}
EOF

# Create the screen Dart file with the provided content
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/src/${PACKAGE_NAME}_screen.dart"
import 'package:$PACKAGE_NAME/src/${PACKAGE_NAME}_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ${PASCAL_CASE_PACKAGE_NAME}Screen extends StatelessWidget {
  const ${PASCAL_CASE_PACKAGE_NAME}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${PASCAL_CASE_PACKAGE_NAME}Cubit(),
      child: const ${PASCAL_CASE_PACKAGE_NAME}View(),
    );
  }
}

class ${PASCAL_CASE_PACKAGE_NAME}View extends StatelessWidget {
  const ${PASCAL_CASE_PACKAGE_NAME}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<${PASCAL_CASE_PACKAGE_NAME}Cubit, ${PASCAL_CASE_PACKAGE_NAME}State>(
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text("${PASCAL_CASE_PACKAGE_NAME}"),),);
      },
    );
  }
}
EOF

# Create the main export Dart file under lib
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/${PACKAGE_NAME}.dart"
export 'src/${PACKAGE_NAME}_screen.dart';
export 'src/l10n/${PACKAGE_NAME}_localizations.dart';
EOF

# Create l10n.yaml file with the specified configuration
cat <<EOF > "packages/features/$PACKAGE_NAME/l10n.yaml"
arb-dir: lib/src/l10n
template-arb-file: messages_en.arb
output-localization-file: ${PACKAGE_NAME}_localizations.dart
output-class: ${PASCAL_CASE_PACKAGE_NAME}Localizations
synthetic-package: false
nullable-getter: false
EOF

# Write JSON content to messages_en.arb file
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/src/l10n/messages_en.arb"
{
  "greeting": "Hello"
}
EOF

# Write JSON content to messages_ar.arb file (Arabic version)
cat <<EOF > "packages/features/$PACKAGE_NAME/lib/src/l10n/messages_ar.arb"
{
  "greeting": "مرحبا"
}
EOF

# Create a default pubspec.yaml for the feature package
cat <<EOF > "packages/features/$PACKAGE_NAME/pubspec.yaml"
name: $PACKAGE_NAME
publish_to: none

environment:
  sdk: ">=3.0.5 <4.0.0"

dependencies:
  component_library:
    path: ../../component_library

  flutter_bloc: ^8.1.5
  flutter:
    sdk: flutter

  flutter_localizations:
    sdk: flutter

  intl: ^0.20.2

  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3
  test: ^1.16.8
  flutter_lints: ^4.0.0

flutter:
  generate: true
  uses-material-design: true
EOF

# Create analysis_options.yaml file
cat <<EOF > "packages/features/$PACKAGE_NAME/analysis_options.yaml"
include: package:flutter_lints/flutter.yaml
EOF

echo "Feature package $PACKAGE_NAME created successfully!"


##usage : chmod +x create_feature.sh
## ./create_feature.sh test_pack_yo
