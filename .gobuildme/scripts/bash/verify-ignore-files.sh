#!/usr/bin/env bash
set -euo pipefail

# verify-ignore-files.sh - Verify and create missing ignore files
# This script detects project technology stack and creates appropriate ignore files

echo "🔍 Verifying ignore files..."

# Detect project technologies
detect_nodejs() {
  [[ -f "package.json" ]] || [[ -d "node_modules" ]]
}

detect_python() {
  [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Pipfile" ]] || find . -maxdepth 2 -name "*.py" -type f | grep -q .
}

detect_java() {
  [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]] || find . -maxdepth 2 -name "*.java" -type f | grep -q .
}

detect_csharp() {
  find . -maxdepth 2 -name "*.csproj" -type f | grep -q . || find . -maxdepth 2 -name "*.sln" -type f | grep -q .
}

detect_go() {
  [[ -f "go.mod" ]] || find . -maxdepth 2 -name "*.go" -type f | grep -q .
}

detect_docker() {
  [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]
}

detect_terraform() {
  find . -maxdepth 2 -name "*.tf" -type f | grep -q .
}

detect_helm() {
  [[ -f "Chart.yaml" ]] || [[ -d "charts" ]]
}

# Create .gitignore if missing
create_gitignore() {
  if [[ -f ".gitignore" ]]; then
    echo "  ✓ .gitignore exists"
    return
  fi

  echo "  📝 Creating .gitignore..."

  cat > .gitignore << 'EOF'
# Operating System Files
.DS_Store
Thumbs.db
*.swp
*.swo
*~

# IDE Files
.vscode/
.idea/
*.iml
.project
.classpath
.settings/

# Environment Files
.env
.env.local
.env.*.local
*.env

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

EOF

  # Add Node.js patterns
  if detect_nodejs; then
    cat >> .gitignore << 'EOF'
# Node.js
node_modules/
dist/
build/
.npm
.eslintcache
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

EOF
  fi

  # Add Python patterns
  if detect_python; then
    cat >> .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv
pip-log.txt
pip-delete-this-directory.txt
.pytest_cache/
.coverage
htmlcov/
*.egg-info/
dist/
build/

EOF
  fi

  # Add Java patterns
  if detect_java; then
    cat >> .gitignore << 'EOF'
# Java
target/
build/
*.class
.gradle/
.mvn/
*.jar
*.war
*.ear

EOF
  fi

  # Add C# patterns
  if detect_csharp; then
    cat >> .gitignore << 'EOF'
# C#/.NET
bin/
obj/
*.user
*.suo
*.userprefs
.vs/
packages/
*.nupkg
*.log

EOF
  fi

  # Add Go patterns
  if detect_go; then
    cat >> .gitignore << 'EOF'
# Go
vendor/
*.exe
*.test
*.out
go.work

EOF
  fi

  echo "  ✅ Created .gitignore with appropriate patterns"
}

# Create .dockerignore if Docker detected
create_dockerignore() {
  if ! detect_docker; then
    return
  fi

  if [[ -f ".dockerignore" ]]; then
    echo "  ✓ .dockerignore exists"
    return
  fi

  echo "  📝 Creating .dockerignore..."

  cat > .dockerignore << 'EOF'
# Git
.git
.gitignore
.gitattributes

# CI/CD
.github/
.gitlab-ci.yml
.travis.yml
.circleci/

# Documentation
README.md
CHANGELOG.md
LICENSE
*.md

# IDE
.vscode/
.idea/
*.iml

# Environment
.env
.env.local
*.env

# Logs
*.log
logs/

EOF

  if detect_nodejs; then
    cat >> .dockerignore << 'EOF'
# Node.js
node_modules/
npm-debug.log
yarn-error.log
.npm
.yarn/

EOF
  fi

  if detect_python; then
    cat >> .dockerignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
.venv/
*.egg-info/

EOF
  fi

  echo "  ✅ Created .dockerignore"
}

# Create .eslintignore if Node.js detected
create_eslintignore() {
  if ! detect_nodejs; then
    return
  fi

  if [[ -f ".eslintignore" ]]; then
    echo "  ✓ .eslintignore exists"
    return
  fi

  # Check for both legacy (.eslintrc*) and flat config (eslint.config.*) formats
  if [[ ! -f ".eslintrc.js" ]] && [[ ! -f ".eslintrc.json" ]] && [[ ! -f ".eslintrc.cjs" ]] && \
     [[ ! -f "eslint.config.js" ]] && [[ ! -f "eslint.config.mjs" ]] && [[ ! -f "eslint.config.cjs" ]]; then
    return
  fi

  echo "  📝 Creating .eslintignore..."

  cat > .eslintignore << 'EOF'
node_modules/
dist/
build/
coverage/
*.min.js
*.bundle.js

EOF

  echo "  ✅ Created .eslintignore"
}

# Create .prettierignore if Node.js detected
create_prettierignore() {
  if ! detect_nodejs; then
    return
  fi

  if [[ -f ".prettierignore" ]]; then
    echo "  ✓ .prettierignore exists"
    return
  fi

  if [[ ! -f ".prettierrc" ]] && [[ ! -f ".prettierrc.json" ]] && [[ ! -f "prettier.config.js" ]]; then
    return
  fi

  echo "  📝 Creating .prettierignore..."

  cat > .prettierignore << 'EOF'
node_modules/
dist/
build/
coverage/
*.min.js
*.bundle.js
package-lock.json
yarn.lock
pnpm-lock.yaml

EOF

  echo "  ✅ Created .prettierignore"
}

# Create .npmignore if Node.js package
create_npmignore() {
  if ! detect_nodejs; then
    return
  fi

  if [[ -f ".npmignore" ]]; then
    echo "  ✓ .npmignore exists"
    return
  fi

  # Check if this is a publishable package
  if [[ -f "package.json" ]]; then
    if grep -q '"private"[[:space:]]*:[[:space:]]*true' package.json; then
      return
    fi
  else
    return
  fi

  echo "  📝 Creating .npmignore..."

  cat > .npmignore << 'EOF'
# Tests
test/
tests/
*.test.js
*.spec.js
__tests__/
coverage/

# Development
.github/
.vscode/
.idea/
src/
*.ts
tsconfig.json

# Documentation
docs/
*.md
!README.md

# CI/CD
.travis.yml
.gitlab-ci.yml
.circleci/

EOF

  echo "  ✅ Created .npmignore"
}

# Create .terraformignore if Terraform detected
create_terraformignore() {
  if ! detect_terraform; then
    return
  fi

  if [[ -f ".terraformignore" ]]; then
    echo "  ✓ .terraformignore exists"
    return
  fi

  echo "  📝 Creating .terraformignore..."

  cat > .terraformignore << 'EOF'
# Git
.git/
.gitignore

# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl

# IDE
.vscode/
.idea/

# Documentation
*.md
docs/

EOF

  echo "  ✅ Created .terraformignore"
}

# Create .helmignore if Helm detected
create_helmignore() {
  if ! detect_helm; then
    return
  fi

  if [[ -f ".helmignore" ]]; then
    echo "  ✓ .helmignore exists"
    return
  fi

  echo "  📝 Creating .helmignore..."

  cat > .helmignore << 'EOF'
# Git
.git/
.gitignore

# CI/CD
.gitlab-ci.yml
.travis.yml
.circleci/

# IDE
.vscode/
.idea/

# Documentation
README.md
NOTES.txt
docs/

EOF

  echo "  ✅ Created .helmignore"
}

# Main execution
echo ""
echo "Detected technologies:"
detect_nodejs && echo "  • Node.js/JavaScript"
detect_python && echo "  • Python"
detect_java && echo "  • Java"
detect_csharp && echo "  • C#/.NET"
detect_go && echo "  • Go"
detect_docker && echo "  • Docker"
detect_terraform && echo "  • Terraform"
detect_helm && echo "  • Helm"

echo ""
echo "Verifying ignore files:"

# Create all necessary ignore files
create_gitignore
create_dockerignore
create_eslintignore
create_prettierignore
create_npmignore
create_terraformignore
create_helmignore

echo ""
echo "✅ Ignore file verification complete"
