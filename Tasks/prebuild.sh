# install pod dependencies
pod install

#  make sure that the revision.prefix file is updated so that it contains the actual build number
echo "#define BUILD_NUMBER $BUILD_NUMBER" > Tasks/revision.prefix
touch Tasks/Info.plist