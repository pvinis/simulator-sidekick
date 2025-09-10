app_name := "SimKick.app"

default:
    @just --list

clean:
    rm -rf simkick/build
    rm -f SimKick.zip

build:
    cd simkick && xcodebuild \
        -project simkick.xcodeproj \
        -scheme simkick \
        -configuration Release \
        -derivedDataPath build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        clean build

archive: build
    cp -r simkick/build/Build/Products/Release/SimKick.app .
    zip -r SimKick.zip SimKick.app
    rm -rf SimKick.app
    @echo "Archive created: SimKick.zip"
