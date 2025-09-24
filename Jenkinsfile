pipeline {
  agent { label 'mac' }

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
        sh '''
          set -euo pipefail
          if ! command -v bundle >/dev/null; then
            gem install bundler --no-document
          fi
          bundle config set --local path vendor/bundle
          bundle install
        '''
      }
    }

    stage('Provision Signing Assets') {
      steps {
        withCredentials([
          file(credentialsId: 'ios-cert-p12', variable: 'IOS_CERT_FILE'),
          string(credentialsId: 'ios-cert-password', variable: 'IOS_CERT_PASSWORD_SECRET'),
          file(credentialsId: 'ios-profile', variable: 'IOS_PROFILE_FILE'),
          file(credentialsId: 'ios-api-key', variable: 'IOS_API_KEY_FILE'),
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
          '''
          script {
            env.IOS_CERT_PASSWORD = IOS_CERT_PASSWORD_SECRET
            env.KEYCHAIN_PASSWORD = IOS_KEYCHAIN_PASSWORD_SECRET
            env.APPSTORE_KEY_ID = APPSTORE_KEY_ID_SECRET
            env.APPSTORE_ISSUER_ID = APPSTORE_ISSUER_ID_SECRET
            env.APPSTORE_KEY_PATH = 'ios/fastlane/keys/AuthKey_5ZBNQGXYVF.p8'
            env.IOS_PROFILE_PATH = 'ios/fastlane/profiles/GiatocphamdinhAppEco.mobileprovision'
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
        withEnv(['FASTLANE_SKIP_UPDATE_CHECK=true']) {
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
