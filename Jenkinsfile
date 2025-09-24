pipeline {
  agent { label 'mac || built-in || master' }

  environment {
    LANG = 'en_US.UTF-8'
    LC_ALL = 'en_US.UTF-8'
    KEYCHAIN_NAME = 'fastlane-ci.keychain-db'
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

    stage('Flutter Dependencies') {
      steps {
        sh '''
          set -euo pipefail
          flutter --version
          flutter pub get
        '''
      }
    }

    stage('Bundle Install') {
      steps {
        script {
          def rubyVersion = sh(
            script: "ruby -rrbconfig -e 'print RbConfig::CONFIG[\"ruby_version\"]'",
            returnStdout: true
          ).trim()
          env.RUBY_VERSION = rubyVersion
          def gemHome = "${env.WORKSPACE}/.gem/ruby/${rubyVersion}"
          env.GEM_HOME = gemHome
          env.GEM_PATH = gemHome
          env.PATH = "${gemHome}/bin:${env.PATH}"
        }
        sh '''
          set -euo pipefail
          mkdir -p "$GEM_HOME/bin"
          if ! bundle --version >/dev/null 2>&1; then
            gem install bundler --no-document --install-dir "$GEM_HOME" --bindir "$GEM_HOME/bin"
          fi
          bundle config set --local path vendor/bundle
          bundle install
        '''
      }
    }

    stage('Verify Pubspec Version') {
      steps {
        script {
          def previousCommit = sh(
            script: 'git rev-parse HEAD^ 2>/dev/null',
            returnStatus: true
          ) == 0 ? sh(
            script: 'git rev-parse HEAD^',
            returnStdout: true
          ).trim() : null

          if (!previousCommit) {
            echo 'Skipping pubspec.yaml check: no previous commit reference available.'
          } else {
            def pubspecTouched = sh(
              script: "git diff --name-only ${previousCommit} HEAD -- pubspec.yaml",
              returnStdout: true
            ).trim()
            if (!pubspecTouched) {
              error 'pubspec.yaml must be updated before running the iOS deploy stage.'
            }
          }
        }
      }
    }

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
          sh '''
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
            def keychainSecret = IOS_KEYCHAIN_PASSWORD_SECRET?.trim()
            if (!keychainSecret) {
              keychainSecret = java.util.UUID.randomUUID().toString()
              echo 'ios-keychain-password credential was blank; generated a temporary password for this build.'
            }

            env.IOS_CERT_PASSWORD = IOS_CERT_PASSWORD_SECRET
            env.KEYCHAIN_PASSWORD = keychainSecret
            env.APPSTORE_KEY_ID = APPSTORE_KEY_ID_SECRET
            env.APPSTORE_ISSUER_ID = APPSTORE_ISSUER_ID_SECRET
            env.APPSTORE_KEY_PATH = 'ios/fastlane/keys/AuthKey_5ZBNQGXYVF.p8'
            env.IOS_PROFILE_PATH = 'ios/fastlane/profiles/GiatocphamdinhAppEco.mobileprovision'
            env.FLUTTER_FIREBASE_CONFIG_PATH = 'ios/Runner/GoogleService-Info.plist'
            env.ANDROID_FIREBASE_CONFIG_PATH = 'android/app/google-services.json'
          }
          sh '''
            set -euo pipefail
            KEYCHAIN_PATH="$HOME/Library/Keychains/${KEYCHAIN_NAME}"
            security delete-keychain "$KEYCHAIN_PATH" || true
            security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
            security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
            security set-keychain-settings -lut 21600 "$KEYCHAIN_NAME"
            security import ios/fastlane/certs/Certificates.p12 \
              -k "$KEYCHAIN_PATH" \
              -P "$IOS_CERT_PASSWORD" \
              -T /usr/bin/codesign \
              -T /usr/bin/productbuild \
              -T /usr/bin/productsign \
              -T /usr/bin/security
            security list-keychains -s "$KEYCHAIN_PATH"
            security default-keychain -s "$KEYCHAIN_NAME"
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
          sh '''
            set -euo pipefail
            bundle exec fastlane ios beta
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''
        set +e
        KEYCHAIN_PATH="$HOME/Library/Keychains/${KEYCHAIN_NAME}"
        security delete-keychain "$KEYCHAIN_PATH" || true
      '''
    }
  }
}
