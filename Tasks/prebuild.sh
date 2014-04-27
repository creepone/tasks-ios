# make sure we fail on non-zero exit code of commands
set -e
set -o pipefail

# install pod dependencies
export PATH=$PATH:$HOME/.rvm/bin  # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
rvm use 2.1.1
export LC_ALL="en_US.UTF-8"
pod install

#  make sure that the revision.prefix file is updated so that it contains the actual build number
echo "#define BUILD_NUMBER $BUILD_NUMBER" > Tasks/revision.prefix
touch Tasks/Info.plist