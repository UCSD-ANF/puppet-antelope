#!/bin/bash

# Exit on any error
set -e

echo "Setting up Puppet development environment..."

# Verify PDK installation (already included in the PDK image)
echo "Verifying installations..."
pdk --version
puppet --version
ruby --version

# Set up git configuration template
git config --global init.defaultBranch main

# Install development dependencies
bundle install --path vendor/bundle

echo "Puppet development environment setup complete!"