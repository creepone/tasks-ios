# package and deploy the ipa file
xcrun -sdk iphoneos PackageApplication -v "build/Release-iphoneos/Tasks.app" -o "$DEPLOY_PATH/Tasks.ipa" --sign "$SIGN_WITH" --embed "$PROVISION_PATH"

# deploy the manifest
echo "BUILD_NUMBER=$BUILD_NUMBER" > "$DEPLOY_PATH/tasks.manifest"