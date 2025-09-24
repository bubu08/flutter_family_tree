pipeline {
  agent { label 'mac || built-in || master' } // ok if you really have these labels

  environment {
    LANG = 'en_US.UTF-8'
    LC_ALL = 'en_US.UTF-8'
    KEYCHAIN_NAME = 'fastlane-ci.keychain-db'
    KEYCHAIN_PATH = "${env.HOME}/Library/Keychains/${KEYCHAIN_NAME}"
  }

  options { timestamps() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Flutter Dependencies') {
      steps {
        sh '''#!/bin/bash -l
          set -eo pipefail
          export FLUTTER_SDK="/Library/Jenkins/flutter"
          export PATH="$FLUTTER_SDK/bin:$PATH"

          # the SDK is a git repo; mark it safe for the jenkins user
          git config --global --add safe.directory "$FLUTTER_SDK" || true

          flutter --version
          flutter pub get
        '''
      }
    }

    stage('RVM Warmup') {
      steps {
        sh '''#!/bin/bash -l
          set -eo pipefail          # no -u yet
          set +u                    # allow unset vars while sourcing RVM
          source /Library/Jenkins/.rvm/scripts/rvm
          rvm use 3.2.4@ios --create
          set -u
        '''
      }
    }

    stage('Bundle Install') {
      steps {
        sh '''#!/bin/bash -l
          set -eo pipefail
          set +u
          source /Library/Jenkins/.rvm/scripts/rvm
          rvm use 3.2.4@ios --create
          set -u

          # Respect Gemfile.lock bundler if present; otherwise install/update bundler
          BUNDLER_VERSION="$(awk '/^BUNDLED WITH$/{getline; gsub(/^[\\t ]+/,\"\"); print; exit}' Gemfile.lock || true)"
          if [ -n "${BUNDLER_VERSION:-}" ]; then
            if ! bundle --version 2>/dev/null | grep -F "$BUNDLER_VERSION" >/dev/null 2>&1; then
              gem install bundler --no-document --version "$BUNDLER_VERSION"
            fi
          else
            gem install bundler --no-document
          fi
          bundle config set path vendor/bundle
          bundle install --jobs 4 --retry 3
        '''
      }
    }

    stage('Sanity') {
      steps {
        sh '''#!/bin/bash -l
          set -eo pipefail
          set +u
          source /Library/Jenkins/.rvm/scripts/rvm
          rvm use 3.2.4@ios
          set -u

          which ruby && ruby -v
          which bundle && bundle --version

          # show gem fastlane and flutter
          bundle exec fastlane --version || true

          export FLUTTER_SDK="/Library/Jenkins/flutter"
          export PATH="$FLUTTER_SDK/bin:$PATH"
          which flutter && flutter --version
        '''
      }
    }
    // stage('Verify Pubspec Version') {
    //   steps {
    //     script {
    //       def hasPrev = sh(returnStatus: true, script: 'git rev-parse HEAD^ >/dev/null 2>&1') == 0
    //       if (!hasPrev) {
    //         echo 'Skipping pubspec.yaml check: no previous commit reference available.'
    //       } else {
    //         def touched = sh(returnStdout: true, script: 'git diff --name-only HEAD^ HEAD -- pubspec.yaml').trim()
    //         if (!touched) { error 'pubspec.yaml must be updated before running the iOS deploy stage.' }
    //       }
    //     }
    //   }
    // }

    stage('Provision Signing Assets') {
      steps {
        withCredentials([
          file(credentialsId: 'ios-cert-p12', variable: 'IOS_CERT_FILE'),
          string(credentialsId: 'ios-cert-password', variable: 'IOS_CERT_PASSWORD_SECRET'),
          file(credentialsId: 'ios-profile', variable: 'IOS_PROFILE_FILE'),
          file(credentialsId: 'ios-api-key', variable: 'IOS_API_KEY_FILE'),
          file(credentialsId: 'firebase-ios-config', variable: 'FIREBASE_IOS_CONFIG'),
          file(credentialsId: 'firebase-android-config', variable: 'FIREBASE_ANDROID_CONFIG'),
          string(credentialsId: 'ios-keychain-password', variable: 'IOS_KEYCHAIN_PASSWORD_SECRET'),
          string(credentialsId: 'appstore-key-id', variable: 'APPSTORE_KEY_ID_SECRET'),
          string(credentialsId: 'appstore-issuer-id', variable: 'APPSTORE_ISSUER_ID_SECRET')
        ]) {
          sh '''#!/bin/bash -l
            set -euo pipefail
            install -d ios/fastlane/certs ios/fastlane/profiles ios/fastlane/keys
            install -m 0600 "$IOS_CERT_FILE" ios/fastlane/certs/Certificates.p12
            install -m 0644 "$IOS_PROFILE_FILE" ios/fastlane/profiles/GiatocphamdinhAppEco.mobileprovision
            install -m 0600 "$IOS_API_KEY_FILE" ios/fastlane/keys/AuthKey_5ZBNQGXYVF.p8
            install -m 0600 "$FIREBASE_IOS_CONFIG" ios/Runner/GoogleService-Info.plist
            install -d android/app
            install -m 0644 "$FIREBASE_ANDROID_CONFIG" android/app/google-services.json
          '''
          script {
            def kcSecret = IOS_KEYCHAIN_PASSWORD_SECRET?.trim()
            if (!kcSecret) {
              kcSecret = java.util.UUID.randomUUID().toString()
              echo 'ios-keychain-password credential was blank; generated a temporary password for this build.'
            }
            env.IOS_CERT_PASSWORD = IOS_CERT_PASSWORD_SECRET
            env.KEYCHAIN_PASSWORD = kcSecret
            env.APPSTORE_KEY_ID   = APPSTORE_KEY_ID_SECRET
            env.APPSTORE_ISSUER_ID= APPSTORE_ISSUER_ID_SECRET
            env.APPSTORE_KEY_PATH = 'ios/fastlane/keys/AuthKey_5ZBNQGXYVF.p8'
            env.IOS_PROFILE_PATH  = 'ios/fastlane/profiles/GiatocphamdinhAppEco.mobileprovision'
          }
          sh '''#!/bin/bash -l
            set -euo pipefail
            # Create and set default keychain (use full path)
            security delete-keychain "$KEYCHAIN_PATH" || true
            security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
            security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
            security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
            security import ios/fastlane/certs/Certificates.p12 \
              -k "$KEYCHAIN_PATH" -P "$IOS_CERT_PASSWORD" \
              -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/xcodebuild
            security list-keychains -s "$KEYCHAIN_PATH"
            security default-keychain -s "$KEYCHAIN_PATH"
          '''
        }
      }
    }

    stage('Fastlane iOS Beta') {
      steps {
        withEnv([
          'FASTLANE_SKIP_UPDATE_CHECK=true',
          'FLUTTER_FIREBASE_CONFIG_PATH=ios/Runner/GoogleService-Info.plist',
          'ANDROID_FIREBASE_CONFIG_PATH=android/app/google-services.json'
        ]) {
          sh '''#!/bin/bash -l
            set -eo pipefail
            export FLUTTER_SDK="/Library/Jenkins/flutter"
            export PATH="$FLUTTER_SDK/bin:$PATH"
            set +u
            source /Library/Jenkins/.rvm/scripts/rvm
            rvm use 3.2.4@ios
            set -u
            bundle exec fastlane ios beta
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''#!/bin/bash -l
        set +e
        security delete-keychain "$KEYCHAIN_PATH" || true
      '''
    }
  }
}
