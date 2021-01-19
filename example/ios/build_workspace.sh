set -o pipefail && xcodebuild -workspace example.xcworkspace -UseNewBuildSystem=YES -scheme example -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build | xcpretty
