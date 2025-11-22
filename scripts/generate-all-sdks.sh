#!/bin/bash
set -e

# Configuration
OPENAPI_GENERATOR_IMAGE="openapitools/openapi-generator-cli:v7.0.0"
SERVICES_DIR="."
SDKS_DIR="./sdks"

# Detect services (directories ending in -service)
SERVICES=$(find . -maxdepth 1 -type d -name "*-service" -exec basename {} \;)
LANGUAGES=("dart" "typescript" "java" "go")

echo "🚀 Starting autonomous SDK generation and build..."

for service in $SERVICES; do
    if [ ! -f "$service/openapi.yaml" ]; then
        echo "⚠️  Skipping $service (no openapi.yaml found)"
        continue
    fi
    
    echo "📦 Processing Service: $service"
    
    for lang in "${LANGUAGES[@]}"; do
        echo "  ------------------------------------------------"
        echo "  → Language: $lang"
        
        CONFIG_FILE="$service/generators/${lang}-config.json"
        if [ ! -f "$CONFIG_FILE" ]; then
            echo "  ⚠️  Config not found at $CONFIG_FILE, using defaults"
            # Create a temporary empty config if needed or just skip config arg
            echo "{}" > temp_config.json
            CONFIG_FILE="temp_config.json"
        fi

        OUTPUT_DIR="$SDKS_DIR/$lang/${service//-/_}"
        if [ "$lang" == "typescript" ] || [ "$lang" == "java" ]; then
             OUTPUT_DIR="$SDKS_DIR/$lang/${service}-client"
        fi
        if [ "$lang" == "go" ]; then
             OUTPUT_DIR="$SDKS_DIR/$lang/${service//-/}"
        fi

        echo "  → Generating to $OUTPUT_DIR..."
        
        # Determine generator name
        GENERATOR=""
        case $lang in
            dart) GENERATOR="dart-dio" ;;
            typescript) GENERATOR="typescript-axios" ;;
            java) GENERATOR="java" ;;
            go) GENERATOR="go" ;;
        esac

        # Generate SDK
        docker run --rm -v "${PWD}:/local" $OPENAPI_GENERATOR_IMAGE generate \
            -i "/local/$service/openapi.yaml" \
            -g "$GENERATOR" \
            -o "/local/$OUTPUT_DIR" \
            -c "/local/$CONFIG_FILE" \
            --git-user-id "teapot-bot" \
            --git-repo-id "${service}-${lang}-sdk"

        # Build and Package Phase
        echo "  → 🏗️  Building package..."
        cd "$OUTPUT_DIR"

        case $lang in
            dart)
                if command -v dart &> /dev/null; then
                    dart pub get
                    # dart analyze # Optional: uncomment to enforce linting
                    echo "  ✅ Dart package resolved"
                else
                    echo "  ⚠️  Dart not installed, skipping build"
                fi
                ;;
            typescript)
                if command -v npm &> /dev/null; then
                    npm install
                    npm run build
                    echo "  ✅ TypeScript package built"
                else
                    echo "  ⚠️  npm not installed, skipping build"
                fi
                ;;
            java)
                if command -v mvn &> /dev/null; then
                    mvn clean install -DskipTests
                    echo "  ✅ Java artifact built and installed to local repo"
                else
                    echo "  ⚠️  Maven not installed, skipping build"
                fi
                ;;
            go)
                if command -v go &> /dev/null; then
                    go mod tidy
                    go build ./...
                    echo "  ✅ Go module built"
                else
                    echo "  ⚠️  Go not installed, skipping build"
                fi
                ;;
        esac

        # Return to root
        cd - > /dev/null
        echo "  ✅ $lang SDK complete"
    done
done

# Cleanup
rm -f temp_config.json

echo "🎉 All SDKs generated and built successfully!"
