#!/bin/bash

# Merge Script for Van Branches
# This script merges chore/all-my-stuffs into van branches
# SIMPLER and FASTER than rebasing - fewer conflicts to resolve

# Configuration
TARGET_BRANCH="chore/all-my-stuffs"

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

# Function to merge target branch into a van branch
merge_branch() {
    local BRANCH=$1
    
    print_info "Merging $TARGET_BRANCH into $BRANCH..."
    
    # Checkout the branch
    git checkout "$BRANCH"
    
    # Attempt the merge
    git merge "$TARGET_BRANCH" || {
        print_error "Merge failed with conflicts. Please resolve them manually."
        print_info "After resolving conflicts:"
        print_info "  1. Edit conflicted files to resolve conflicts"
        print_info "  2. git add <resolved-files>"
        print_info "  3. git commit"
        print_info "  4. Re-run this script with the continue option"
        print_info ""
        print_info "To abort the merge:"
        print_info "  git merge --abort"
        return 1
    }
    
    print_info "Merge of $TARGET_BRANCH into $BRANCH completed successfully!"
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
    
    print_warning "About to push $BRANCH to origin."
    read -p "Are you sure you want to continue? (yes/no) " -r REPLY
    echo
    
    if [[ $REPLY == "yes" ]]; then
        git push origin "$BRANCH"
        print_info "Successfully pushed $BRANCH"
    else
        print_info "Skipping push for $BRANCH"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "========================================="
    echo "   Van Branches Merge Script"
    echo "   (Simpler than Rebase!)"
    echo "========================================="
    echo "1. Merge into van/devel (Recommended)"
    echo "2. Merge into van/workflows"
    echo "3. Merge into van/tools/favimpexp"
    echo "4. Merge into all branches (automated)"
    echo "5. Run tests only"
    echo "6. Create backups only"
    echo "7. Exit"
    echo "========================================="
}

# Main script
main() {
    print_info "Van Branches Merge Script"
    print_info "========================="
    print_info "This script merges $TARGET_BRANCH into van branches."
    print_info "MERGE is simpler than rebase and results in fewer conflicts!"
    print_info ""
    
    check_repository
    
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --backup         Create backups only"
        echo "  --test           Run tests only"
        echo "  --auto           Automatically merge into all branches"
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
        
        # Merge into van/devel
        if merge_branch "van/devel"; then
            run_tests
            push_branch "van/devel"
        fi
        
        # Merge into van/workflows
        if merge_branch "van/workflows"; then
            run_tests
            push_branch "van/workflows"
        fi
        
        # Merge into van/tools/favimpexp
        if merge_branch "van/tools/favimpexp"; then
            run_tests
            push_branch "van/tools/favimpexp"
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
                if merge_branch "van/devel"; then
                    run_tests
                    push_branch "van/devel"
                fi
                ;;
            2)
                create_backups
                if merge_branch "van/workflows"; then
                    run_tests
                    push_branch "van/workflows"
                fi
                ;;
            3)
                create_backups
                if merge_branch "van/tools/favimpexp"; then
                    run_tests
                    push_branch "van/tools/favimpexp"
                fi
                ;;
            4)
                create_backups
                print_info "Starting automated merge of all branches..."
                
                # Merge in order
                if merge_branch "van/devel"; then
                    print_info "van/devel merged successfully"
                else
                    print_error "Failed to merge van/devel. Stopping."
                    break
                fi
                
                if merge_branch "van/workflows"; then
                    print_info "van/workflows merged successfully"
                else
                    print_error "Failed to merge van/workflows. Stopping."
                    break
                fi
                
                if merge_branch "van/tools/favimpexp"; then
                    print_info "van/tools/favimpexp merged successfully"
                else
                    print_error "Failed to merge van/tools/favimpexp. Stopping."
                    break
                fi
                
                run_tests
                
                print_info "All branches merged successfully!"
                print_warning "Review the changes before pushing"
                
                read -p "Push all branches to origin? (yes/no) " -r REPLY
                echo
                if [[ $REPLY == "yes" ]]; then
                    push_branch "van/devel"
                    push_branch "van/workflows"
                    push_branch "van/tools/favimpexp"
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
