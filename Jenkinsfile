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
          export FLUTTER_SDK="/usr/local/share/flutter"
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
          # Don't set -u here to avoid PROMPT_COMMAND errors

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
          # Don't set -u here to avoid PROMPT_COMMAND errors

          which ruby && ruby -v
          which bundle && bundle --version

          # show gem fastlane and flutter
          bundle exec fastlane --version || true

          export FLUTTER_SDK="/usr/local/share/flutter"
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
        script {
          def profileCredentialId = env.IOS_PROFILE_CREDENTIAL_ID?.trim()
          if (!profileCredentialId) {
            profileCredentialId = 'ios-profile'
          }

          withCredentials([
            file(credentialsId: 'ios-cert-p12', variable: 'IOS_CERT_FILE'),
            string(credentialsId: 'ios-cert-password', variable: 'IOS_CERT_PASSWORD_SECRET'),
            file(credentialsId: profileCredentialId, variable: 'IOS_PROFILE_FILE'),
            file(credentialsId: 'ios-api-key', variable: 'IOS_API_KEY_FILE'),
            file(credentialsId: 'firebase-ios-config', variable: 'FIREBASE_IOS_CONFIG'),
            file(credentialsId: 'firebase-android-config', variable: 'FIREBASE_ANDROID_CONFIG'),
            string(credentialsId: 'appstore-key-id', variable: 'APPSTORE_KEY_ID_SECRET'),
            string(credentialsId: 'appstore-issuer-id', variable: 'APPSTORE_ISSUER_ID_SECRET')
          ]) {
            // Generate temporary keychain password since ios-keychain-password credential doesn't exist
            def kcSecret = java.util.UUID.randomUUID().toString()
            echo 'Generated temporary keychain password for this build.'

            env.IOS_CERT_PASSWORD = IOS_CERT_PASSWORD_SECRET
            env.KEYCHAIN_PASSWORD = kcSecret
            env.APPSTORE_KEY_ID   = APPSTORE_KEY_ID_SECRET
            env.APPSTORE_ISSUER_ID= APPSTORE_ISSUER_ID_SECRET
            env.APPSTORE_KEY_PATH = 'ios/fastlane/keys/AuthKey_5ZBNQGXYVF.p8'

            env.FLUTTER_FIREBASE_CONFIG_PATH = (env.FLUTTER_FIREBASE_CONFIG_PATH?.trim() ?: 'ios/Runner/GoogleService-Info.plist')
            env.ANDROID_FIREBASE_CONFIG_PATH = (env.ANDROID_FIREBASE_CONFIG_PATH?.trim() ?: 'android/app/google-services.json')

            def bundleId = env.IOS_BUNDLE_IDENTIFIER?.trim()
            if (!bundleId) {
              bundleId = 'com.giatocphamdinh.familytree'
            }
            env.IOS_BUNDLE_IDENTIFIER = bundleId

            def profileName = env.IOS_PROFILE_NAME?.trim()
            if (!profileName) {
              profileName = 'GiatocphamdinhAppEco'
            }
            env.IOS_PROFILE_NAME = profileName

            def profileSpecifier = env.IOS_PROFILE_SPECIFIER?.trim()
            if (!profileSpecifier) {
              profileSpecifier = profileName
            }
            env.IOS_PROFILE_SPECIFIER = profileSpecifier

            env.IOS_PROFILE_PATH = "ios/fastlane/profiles/${profileName}.mobileprovision"

            def itcTeam = env.IOS_ITC_TEAM_ID?.trim()
            if (!itcTeam) {
              itcTeam = '128129522'
            }
            env.IOS_ITC_TEAM_ID = itcTeam

            sh '''#!/bin/bash -l
              set -eo pipefail
              # Don't use -u to avoid PROMPT_COMMAND errors in login shells
              install -d ios/fastlane/certs ios/fastlane/profiles ios/fastlane/keys
              install -m 0600 "$IOS_CERT_FILE" ios/fastlane/certs/Certificates.p12
              install -m 0644 "$IOS_PROFILE_FILE" "$IOS_PROFILE_PATH"
              install -d "$(dirname "$APPSTORE_KEY_PATH")"
              install -m 0600 "$IOS_API_KEY_FILE" "$APPSTORE_KEY_PATH"
              install -d "$(dirname "$FLUTTER_FIREBASE_CONFIG_PATH")"
              install -m 0600 "$FIREBASE_IOS_CONFIG" "$FLUTTER_FIREBASE_CONFIG_PATH"
              install -d "$(dirname "$ANDROID_FIREBASE_CONFIG_PATH")"
              install -m 0644 "$FIREBASE_ANDROID_CONFIG" "$ANDROID_FIREBASE_CONFIG_PATH"
            '''

            sh '''#!/bin/bash -l
              set -eo pipefail
              # Don't use -u to avoid PROMPT_COMMAND errors in login shells
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
    }

    stage('Fastlane iOS Beta') {
      steps {
        withEnv([
          'FASTLANE_SKIP_UPDATE_CHECK=true',
          "FLUTTER_FIREBASE_CONFIG_PATH=${env.FLUTTER_FIREBASE_CONFIG_PATH}",
          "ANDROID_FIREBASE_CONFIG_PATH=${env.ANDROID_FIREBASE_CONFIG_PATH}",
          "IOS_PROFILE_PATH=${env.IOS_PROFILE_PATH}",
          "IOS_PROFILE_NAME=${env.IOS_PROFILE_NAME}",
          "IOS_PROFILE_SPECIFIER=${env.IOS_PROFILE_SPECIFIER}",
          "IOS_BUNDLE_IDENTIFIER=${env.IOS_BUNDLE_IDENTIFIER}",
          "IOS_ITC_TEAM_ID=${env.IOS_ITC_TEAM_ID}"
        ]) {
          sh '''#!/bin/bash -l
            set -eo pipefail
            export FLUTTER_SDK="/usr/local/share/flutter"
            export PATH="$FLUTTER_SDK/bin:$PATH"
            set +u
            source /Library/Jenkins/.rvm/scripts/rvm
            rvm use 3.2.4@ios
            # Don't set -u here to avoid PROMPT_COMMAND errors
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
