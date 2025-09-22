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
          def gemRoot = "${env.WORKSPACE}/.bundle"
          env.GEM_HOME = "${gemRoot}/ruby/${rubyVersion}"
          env.GEM_PATH = env.GEM_HOME
          env.BUNDLE_PATH = env.GEM_HOME
          env.PATH = "${env.GEM_HOME}/bin:${env.PATH}"
          env.RUBY_VERSION_FULL = rubyVersion
          def rubyParts = rubyVersion.tokenize('.')
          def rubySeries = rubyParts.size() >= 2 ? "${rubyParts[0]}.${rubyParts[1]}" : rubyVersion
          env.RUBY_VERSION_SERIES = rubySeries
          def rubyArch = sh(
            script: "ruby -e 'print RbConfig::CONFIG[\\"arch\\"]'",
            returnStdout: true
          ).trim()
          env.RUBY_ARCH = rubyArch
          def sdkPath = sh(
            script: 'xcrun --sdk macosx --show-sdk-path',
            returnStdout: true
          ).trim()
          env.SDKROOT = sdkPath
          def includeBase = "${sdkPath}/System/Library/Frameworks/Ruby.framework/Versions/${rubySeries}/usr/include"
          def rubyInclude = "${includeBase}/ruby-${rubyVersion}"
          def rubyArchInclude = "${rubyInclude}/${rubyArch}"
          def existingCpath = env.CPATH?.trim()
          env.CPATH = [includeBase, rubyInclude, rubyArchInclude, existingCpath]
            .findAll { it && it.trim() }
            .join(':')
        }
        sh '''
          set -euo pipefail
          mkdir -p "${GEM_HOME}/bin"
          if [ ! -x "${GEM_HOME}/bin/bundle" ]; then
            gem install bundler --no-document --install-dir "${GEM_HOME}" --bindir "${GEM_HOME}/bin"
          fi
          bundle_include_args="--with-opt-include=${SDKROOT}/System/Library/Frameworks/Ruby.framework/Versions/${RUBY_VERSION_SERIES}/usr/include:${SDKROOT}/System/Library/Frameworks/Ruby.framework/Versions/${RUBY_VERSION_SERIES}/usr/include/ruby-${RUBY_VERSION_FULL}:${SDKROOT}/System/Library/Frameworks/Ruby.framework/Versions/${RUBY_VERSION_SERIES}/usr/include/ruby-${RUBY_VERSION_FULL}/${RUBY_ARCH}"
          "${GEM_HOME}/bin/bundle" config set --local build.nkf "${bundle_include_args}"
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
