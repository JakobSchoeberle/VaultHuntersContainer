#!/bin/bash
# Vault Hunters 3 Server Setup Script - Unix Shell Version
# Compatible with Linux, macOS, and BSD systems

# Configuration variables
FORGE_VERSION="40.2.9"
JAVA_VERSION="17"
JAVA_OVERRIDE=""
JVM_ARGS=""
VH3_RESTART="false"
VH3_INSTALL_ONLY="false"

# Global variables
JAVA_FILE=""
JAVA_NUM=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to find Java installation
find_java() {
    if [ -n "$JAVA_OVERRIDE" ]; then
        JAVA_FILE="$JAVA_OVERRIDE"
        return
    fi

    # Common Java installation paths for different systems
    local search_paths=(
        "/usr/lib/jvm"
        "/usr/local/openjdk-${JAVA_VERSION}"
        "/usr/local/java"
        "/opt/java"
        "/Library/Java/JavaVirtualMachines"
        "/System/Library/Java/JavaVirtualMachines"
        "/usr/local/Cellar/openjdk@${JAVA_VERSION}"
        "$HOME/.sdkman/candidates/java"
    )

    # Add JAVA_HOME if set
    if [ -n "$JAVA_HOME" ]; then
        search_paths=("$JAVA_HOME" "${search_paths[@]}")
    fi

    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            # Find Java directories matching our version
            for java_dir in "$path"/*; do
                if [ -d "$java_dir" ]; then
                    local dir_name=$(basename "$java_dir")
                    if [[ "$dir_name" =~ (jdk-?${JAVA_VERSION}|temurin-?${JAVA_VERSION}|jre-?${JAVA_VERSION}|zulu-?${JAVA_VERSION}|java-?${JAVA_VERSION}|openjdk-?${JAVA_VERSION}|adoptopenjdk-?${JAVA_VERSION})([-_.].*)*$ ]]; then
                        local java_exe=""
                        # Check different possible locations for java executable
                        if [ -f "$java_dir/bin/java" ]; then
                            java_exe="$java_dir/bin/java"
                        elif [ -f "$java_dir/Contents/Home/bin/java" ]; then
                            java_exe="$java_dir/Contents/Home/bin/java"
                        fi
                        
                        if [ -n "$java_exe" ] && [ -x "$java_exe" ]; then
                            JAVA_FILE="$java_exe"
                            
                            # Try to get version info
                            local release_file=""
                            if [ -f "$java_dir/release" ]; then
                                release_file="$java_dir/release"
                            elif [ -f "$java_dir/Contents/Home/release" ]; then
                                release_file="$java_dir/Contents/Home/release"
                            fi
                            
                            if [ -f "$release_file" ]; then
                                local impl=$(grep "IMPLEMENTOR=" "$release_file" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                                local jver=$(grep "JAVA_VERSION=" "$release_file" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                                if [ -n "$impl" ] && [ -n "$jver" ]; then
                                    JAVA_NUM="$impl / $jver"
                                fi
                            fi
                            return
                        fi
                    fi
                fi
            done
        fi
    done

    # Try system java as fallback
    if command -v java >/dev/null 2>&1; then
        local java_version_output=$(java -version 2>&1)
        if [[ "$java_version_output" =~ \"${JAVA_VERSION}\..*\" ]] || [[ "$java_version_output" =~ \"${JAVA_VERSION}\" ]]; then
            JAVA_FILE="java"
            JAVA_NUM="System Java"
            return
        fi
    fi

    echo
    print_color $RED "     - Did not find a system installed Java for version $JAVA_VERSION."
    echo
    print_color $RED "     - Install some distribution of Java $JAVA_VERSION to your operating system!"
    echo
    read -p "Press Enter to exit..."
    exit 1
}

# Function to start the server
start_server() {
    # Delete unwanted client-side mods
    local unwanted_mods=("legendarytooltips" "torohealth" "rubidium")
    for mod_pattern in "${unwanted_mods[@]}"; do
        if ls mods/*$mod_pattern* >/dev/null 2>&1; then
            rm -f mods/*$mod_pattern*
        fi
    done

    local restart_count=0
    while true; do
        # Build JVM arguments
        local args=()
        
        # Add custom JVM args if specified
        if [ -n "$JVM_ARGS" ]; then
            read -ra jvm_args_array <<< "$JVM_ARGS"
            args+=("${jvm_args_array[@]}")
        fi
        
        # Add user JVM args if file exists
        if [ -f "user_jvm_args.txt" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^-.*$ ]]; then
                    args+=("$line")
                fi
            done < "user_jvm_args.txt"
        fi
        
        # Use unix_args.txt instead of win_args.txt on Unix systems
        local args_file="libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/unix_args.txt"
        if [ ! -f "$args_file" ]; then
            # Fallback to win_args.txt if unix_args.txt doesn't exist
            args_file="libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/win_args.txt"
        fi
        
        args+=("@$args_file")
        args+=("")
        args+=("nogui")

        # Start server
        "$JAVA_FILE" "${args[@]}"

        # Check for restart conditions
        if [ "$VH3_RESTART" = "true" ] && [ -f "logs/latest.log" ]; then
            if ! grep -q "Stopping the server" "logs/latest.log"; then
                restart_count=$((restart_count + 1))
                if [ $restart_count -le 10 ]; then
                    print_color $YELLOW "Restarting automatically in 10 seconds (press Ctrl + C to cancel)"
                    sleep 10
                    continue
                fi
            fi
        fi
        break
    done
}

# Main execution
main() {
    # Change to script directory
    cd "$(dirname "$0")" || exit 1

    print_color $GREEN "Vault Hunters 3 Server Setup"
    print_color $GREEN "============================"

    find_java

    start_server
}

# Run main function
main "$@"