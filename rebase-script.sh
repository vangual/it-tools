#!/bin/bash

# Automated Rebase Script for Van Branches
# This script automates the rebase process with safety checks and backups

# Configuration
# This is the merge base commit for van/devel branch
# If this doesn't match your repository, update it accordingly
VAN_DEVEL_BASE_COMMIT="8d1d069"

# Note: Removed set -e to allow better error handling in interactive mode
# Errors are handled explicitly with || operators and return codes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in the right directory
check_repository() {
    if [ ! -d ".git" ]; then
        print_error "Not in a git repository. Please run this script from the repository root."
        exit 1
    fi
    
    # Check if we're in the it-tools repository
    if ! git remote -v | grep -q "it-tools"; then
        print_warning "This doesn't appear to be the it-tools repository."
        read -p "Continue anyway? (y/n) " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to create backups
create_backups() {
    print_info "Creating backup branches..."
    
    git fetch origin
    
    # Create backups with timestamp
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    if git show-ref --verify --quiet refs/heads/van/devel; then
        git branch "van/devel-backup-$TIMESTAMP" van/devel
        print_info "Created backup: van/devel-backup-$TIMESTAMP"
    fi
    
    if git show-ref --verify --quiet refs/heads/van/workflows; then
        git branch "van/workflows-backup-$TIMESTAMP" van/workflows
        print_info "Created backup: van/workflows-backup-$TIMESTAMP"
    fi
    
    if git show-ref --verify --quiet refs/heads/van/tools/favimpexp; then
        git branch "van/tools/favimpexp-backup-$TIMESTAMP" van/tools/favimpexp
        print_info "Created backup: van/tools/favimpexp-backup-$TIMESTAMP"
    fi
}

# Function to rebase a branch
rebase_branch() {
    local BRANCH=$1
    local BASE_COMMIT=$2
    
    print_info "Rebasing $BRANCH..."
    
    # Checkout the branch
    git checkout "$BRANCH"
    
    # Attempt the rebase
    if [ -n "$BASE_COMMIT" ]; then
        print_info "Using --onto strategy with base commit $BASE_COMMIT"
        git rebase --onto chore/all-my-stuffs "$BASE_COMMIT" || {
            print_error "Rebase failed with conflicts. Please resolve them manually."
            print_info "After resolving conflicts:"
            print_info "  1. git add <resolved-files>"
            print_info "  2. git rebase --continue"
            print_info "  3. Re-run this script with the continue option"
            return 1
        }
    else
        git rebase chore/all-my-stuffs || {
            print_error "Rebase failed with conflicts. Please resolve them manually."
            print_info "After resolving conflicts:"
            print_info "  1. git add <resolved-files>"
            print_info "  2. git rebase --continue"
            print_info "  3. Re-run this script with the continue option"
            return 1
        }
    fi
    
    print_info "Rebase of $BRANCH completed successfully!"
    return 0
}

# Function to run tests
run_tests() {
    print_info "Running tests..."
    
    # Check if pnpm is available
    if ! command -v pnpm &> /dev/null; then
        print_warning "pnpm not found. Skipping tests."
        return 0
    fi
    
    print_info "Installing dependencies..."
    pnpm install || {
        print_error "Failed to install dependencies"
        return 1
    }
    
    print_info "Running linter..."
    pnpm lint || {
        print_warning "Linting failed"
    }
    
    print_info "Running type check..."
    pnpm typecheck || {
        print_warning "Type check failed"
    }
    
    print_info "Building project..."
    pnpm build || {
        print_error "Build failed"
        return 1
    }
    
    print_info "Running tests..."
    pnpm test || {
        print_warning "Tests failed"
    }
    
    return 0
}

# Function to push the branch
push_branch() {
    local BRANCH=$1
    
    print_warning "About to force-push $BRANCH to origin."
    print_warning "This will rewrite history on the remote!"
    read -p "Are you sure you want to continue? (yes/no) " -r
    echo
    
    if [[ $REPLY == "yes" ]]; then
        git push origin "$BRANCH" --force
        print_info "Successfully pushed $BRANCH"
    else
        print_info "Skipping push for $BRANCH"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "========================================="
    echo "   Van Branches Rebase Script"
    echo "========================================="
    echo "1. Rebase van/workflows (Recommended first)"
    echo "2. Rebase van/tools/favimpexp"
    echo "3. Rebase van/devel"
    echo "4. Rebase all branches (automated)"
    echo "5. Run tests only"
    echo "6. Create backups only"
    echo "7. Exit"
    echo "========================================="
}

# Main script
main() {
    print_info "Van Branches Rebase Script"
    print_info "==========================="
    
    check_repository
    
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --backup         Create backups only"
        echo "  --test           Run tests only"
        echo "  --auto           Automatically rebase all branches"
        echo ""
        echo "If no option is provided, the script will show an interactive menu."
        exit 0
    fi
    
    if [ "$1" == "--backup" ]; then
        create_backups
        exit 0
    fi
    
    if [ "$1" == "--test" ]; then
        run_tests
        exit 0
    fi
    
    if [ "$1" == "--auto" ]; then
        create_backups
        
        # Rebase van/workflows
        if rebase_branch "van/workflows"; then
            run_tests
            push_branch "van/workflows"
        fi
        
        # Rebase van/tools/favimpexp
        if rebase_branch "van/tools/favimpexp"; then
            run_tests
            push_branch "van/tools/favimpexp"
        fi
        
        # Rebase van/devel with --onto
        if rebase_branch "van/devel" "$VAN_DEVEL_BASE_COMMIT"; then
            run_tests
            push_branch "van/devel"
        fi
        
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-7): " -r choice
        
        case $choice in
            1)
                create_backups
                if rebase_branch "van/workflows"; then
                    run_tests
                    push_branch "van/workflows"
                fi
                ;;
            2)
                create_backups
                if rebase_branch "van/tools/favimpexp"; then
                    run_tests
                    push_branch "van/tools/favimpexp"
                fi
                ;;
            3)
                create_backups
                if rebase_branch "van/devel" "$VAN_DEVEL_BASE_COMMIT"; then
                    run_tests
                    push_branch "van/devel"
                fi
                ;;
            4)
                create_backups
                print_info "Starting automated rebase of all branches..."
                
                # Rebase in order
                if rebase_branch "van/workflows"; then
                    print_info "van/workflows rebased successfully"
                else
                    print_error "Failed to rebase van/workflows. Stopping."
                    break
                fi
                
                if rebase_branch "van/tools/favimpexp"; then
                    print_info "van/tools/favimpexp rebased successfully"
                else
                    print_error "Failed to rebase van/tools/favimpexp. Stopping."
                    break
                fi
                
                if rebase_branch "van/devel" "$VAN_DEVEL_BASE_COMMIT"; then
                    print_info "van/devel rebased successfully"
                else
                    print_error "Failed to rebase van/devel. Stopping."
                    break
                fi
                
                run_tests
                
                print_info "All branches rebased successfully!"
                print_warning "Review the changes before pushing"
                
                read -p "Push all branches to origin? (yes/no) " -r
                echo
                if [[ $REPLY == "yes" ]]; then
                    push_branch "van/workflows"
                    push_branch "van/tools/favimpexp"
                    push_branch "van/devel"
                fi
                ;;
            5)
                run_tests
                ;;
            6)
                create_backups
                ;;
            7)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac
    done
}

# Run the main function
main "$@"
