# Step 1: Install Shorebird CLI

# For macOS (what you have!)
# Open Terminal and run these commands one by one:

# 1. Install Shorebird CLI
curl --proto '=https' --tlsv1.2 https://download.shorebird.dev/install.sh -sSf | bash

# 2. Add Shorebird to your PATH (so your computer can find it)
echo 'export PATH="$HOME/.shorebird/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 3. Verify installation
shorebird --version

# You should see something like: "Shorebird 1.x.x"