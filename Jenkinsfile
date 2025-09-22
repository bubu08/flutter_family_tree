pipeline {
  agent any

  environment {
    FLUTTER_CHANNEL = 'stable'
  }

  options {
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Flutter') {
      steps {
        sh 'flutter --version'
        sh 'flutter pub get'
      }
    }

    stage('Bundle Install') {
      steps {
        script {
          def rubyVersion = sh(
            script: "ruby -e 'print RbConfig::CONFIG[\"ruby_version\"]'",
            returnStdout: true
          ).trim()
          env.GEM_HOME = "${env.HOME}/.gem/ruby/${rubyVersion}"
          env.PATH = "${env.GEM_HOME}/bin:${env.PATH}"
        }
        sh '''
          set -euo pipefail
          if [ ! -x "${GEM_HOME}/bin/bundle" ]; then
            gem install --user-install bundler --no-document
          fi
          "${GEM_HOME}/bin/bundle" install
        '''
      }
    }

    stage('Validate Secrets') {
      steps {
        withCredentials([
          string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET')
        ]) {
          sh 'dart run tool/check_env.dart'
        }
      }
    }

    stage('Static Analysis') {
      steps {
        sh 'flutter analyze'
      }
    }

    stage('Tests') {
      steps {
        withCredentials([
          string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET')
        ]) {
          sh 'flutter test --dart-define=DEMO_SECRET=$DEMO_SECRET'
        }
      }
    }

    stage('Install iOS Signing Assets') {
      steps {
        withCredentials([
          file(credentialsId: 'ios-dist-cert', variable: 'IOS_CERT_P12'),
          string(credentialsId: 'ios-dist-cert-pass', variable: 'IOS_CERT_PASSWORD'),
          file(credentialsId: 'ios-appstore-provision', variable: 'IOS_PROVISION_PROFILE')
        ]) {
          withEnv([
            'KEYCHAIN_NAME=ios-build.keychain-db',
            'KEYCHAIN_PASSWORD=ci-temp-pass'
          ]) {
            sh '''
              set -euo pipefail
              KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
              security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
              security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              existing=$(security list-keychains | tr -d '"' | tr '\n' ' ')
              security list-keychains -s "$KEYCHAIN_PATH" $existing
              security default-keychain -s "$KEYCHAIN_PATH"
              security import "$IOS_CERT_P12" -k "$KEYCHAIN_PATH" -P "$IOS_CERT_PASSWORD" -T /usr/bin/codesign
              security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
              cp "$IOS_PROVISION_PROFILE" "$HOME/Library/MobileDevice/Provisioning Profiles/"
            '''
          }
        }
      }
    }

    stage('Android Fastlane') {
      steps {
        withCredentials([
          string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET'),
          file(credentialsId: 'play-service-account', variable: 'PLAY_JSON')
        ]) {
          withEnv(["PLAY_SERVICE_ACCOUNT_JSON=${PLAY_JSON}"]) {
            sh 'bundle exec fastlane android tests'
            sh 'bundle exec fastlane android build_release'
          }
        }
      }
    }

    stage('iOS Fastlane') {
      steps {
        withCredentials([
          string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET'),
          file(credentialsId: 'appstore-connect-key', variable: 'APPSTORE_KEY_FILE'),
          string(credentialsId: 'appstore-connect-key-id', variable: 'APPSTORE_KEY_ID'),
          string(credentialsId: 'appstore-connect-issuer-id', variable: 'APPSTORE_ISSUER_ID')
        ]) {
          withEnv([
            "APPSTORE_KEY_PATH=${APPSTORE_KEY_FILE}",
            "APPSTORE_KEY_ID=${APPSTORE_KEY_ID}",
            "APPSTORE_ISSUER_ID=${APPSTORE_ISSUER_ID}"
          ]) {
            sh 'bundle exec fastlane ios tests'
            sh 'bundle exec fastlane ios build_release'
          }
        }
      }
    }
  }
}
