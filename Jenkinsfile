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
            script: 'ruby -rrbconfig -e "print RbConfig::CONFIG[\'ruby_version\']"',
            returnStdout: true
          ).trim()
          def rubyParts = rubyVersion.tokenize('.')
          def rubySeries = rubyParts.size() >= 2 ? "${rubyParts[0]}.${rubyParts[1]}" : rubyVersion
          env.RUBY_VERSION_FULL = rubyVersion
          env.RUBY_VERSION_SERIES = rubySeries

          def rubyConfigValue = { key ->
            sh(
              script: "ruby -rrbconfig -e 'print RbConfig::CONFIG[\"${key}\"]'",
              returnStdout: true
            ).trim()
          }

          def rubyHdrDir = rubyConfigValue('rubyhdrdir')
          def rubyArchHdrDir = rubyConfigValue('rubyarchhdrdir')

          def sdkPath = sh(
            script: 'xcrun --sdk macosx --show-sdk-path',
            returnStdout: true
          ).trim()
          env.SDKROOT = sdkPath

          def archHdrExists = sh(
            script: "test -f '${rubyArchHdrDir}/ruby/config.h' && echo yes || echo no",
            returnStdout: true
          ).trim() == 'yes'
          if (!archHdrExists) {
            def rubyIncludeRoot = "${sdkPath}/System/Library/Frameworks/Ruby.framework/Versions/${rubySeries}/usr/include/ruby-${rubyVersion}"
            def archCandidates = sh(
              script: "ls '${rubyIncludeRoot}' 2>/dev/null | grep universal-darwin || true",
              returnStdout: true
            ).trim().tokenize('\n')
            if (archCandidates) {
              rubyArchHdrDir = "${rubyIncludeRoot}/${archCandidates[0]}"
            }
          }

          env.RUBY_HDR_DIR = rubyHdrDir
          env.RUBY_ARCH_HDR_DIR = rubyArchHdrDir
          env.RUBY_HDR_DIR_OVERRIDE = rubyHdrDir
          env.RUBY_ARCH_HDR_DIR_OVERRIDE = rubyArchHdrDir

          def existingRubyOpt = env.RUBYOPT ?: ''
          def rubyOptComponents = existingRubyOpt.tokenize(' ')
          def overrideRequire = "-I${env.WORKSPACE}/ci"
          def overrideLibrary = '-rrbconfig_override'
          if (!rubyOptComponents.contains(overrideRequire)) {
            rubyOptComponents << overrideRequire
          }
          if (!rubyOptComponents.contains(overrideLibrary)) {
            rubyOptComponents << overrideLibrary
          }
          env.RUBYOPT = rubyOptComponents.join(' ').trim()

          def gemRoot = "${env.WORKSPACE}/.bundle"
          env.GEM_HOME = "${gemRoot}/ruby/${rubyVersion}"
          env.GEM_PATH = env.GEM_HOME
          env.BUNDLE_PATH = env.GEM_HOME
          env.PATH = "${env.GEM_HOME}/bin:${env.PATH}"

          def existingCpath = env.CPATH?.trim()
          env.CPATH = [rubyHdrDir, rubyArchHdrDir, existingCpath]
            .findAll { it && it.trim() }
            .join(':')
        }
        sh '''
          set -euo pipefail
          mkdir -p "${GEM_HOME}/bin"
          if [ ! -x "${GEM_HOME}/bin/bundle" ]; then
            gem install bundler --no-document --install-dir "${GEM_HOME}" --bindir "${GEM_HOME}/bin"
          fi
          include_args="--with-rubyhdrdir=${RUBY_HDR_DIR} --with-rubyarchhdrdir=${RUBY_ARCH_HDR_DIR} --with-opt-include=${RUBY_HDR_DIR}:${RUBY_ARCH_HDR_DIR}"
          "${GEM_HOME}/bin/bundle" config set --local build.nkf "${include_args}"
          "${GEM_HOME}/bin/bundle" config set --local build.json "${include_args}"
          "${GEM_HOME}/bin/bundle" config set --local build.sysrandom "${include_args}"
          "${GEM_HOME}/bin/bundle" install
        '''
      }
    }

    // stage('Validate Secrets') {
    //   steps {
    //     withCredentials([
    //       string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET')
    //     ]) {
    //       sh 'dart run tool/check_env.dart'
    //     }
    //   }
    // }

    // stage('Static Analysis') {
    //   steps {
    //     sh 'flutter analyze'
    //   }
    // }

    // stage('Tests') {
    //   steps {
    //     withCredentials([
    //       string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET')
    //     ]) {
    //       sh 'flutter test --dart-define=DEMO_SECRET=$DEMO_SECRET'
    //     }
    //   }
    // }

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
              if security list-keychains | tr -d '"' | grep -q "$KEYCHAIN_PATH"; then
                security delete-keychain "$KEYCHAIN_PATH"
              fi
              security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
              security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              existing=$(security list-keychains | tr -d '"' | tr '\n' ' ')
              security list-keychains -s "$KEYCHAIN_PATH" $existing
              security default-keychain -s "$KEYCHAIN_PATH"
              security import "$IOS_CERT_P12" -k "$KEYCHAIN_PATH" -P "$IOS_CERT_PASSWORD" -T /usr/bin/codesign
              security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
              mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
              profile_basename=$(basename "$IOS_PROVISION_PROFILE")
              rm -f "$HOME/Library/MobileDevice/Provisioning Profiles/$profile_basename"
              cp "$IOS_PROVISION_PROFILE" "$HOME/Library/MobileDevice/Provisioning Profiles/"
              chmod 0644 "$HOME/Library/MobileDevice/Provisioning Profiles/$profile_basename"
            '''
          }
        }
      }
    }

    stage('Android Fastlane') {
      steps {
        withCredentials([
          string(credentialsId: 'demo-secret', variable: 'DEMO_SECRET'),
          file(credentialsId: 'play-service-account', variable: 'PLAY_JSON'),
          file(credentialsId: 'firebase-android-config', variable: 'FIREBASE_ANDROID_CONFIG'),
          file(credentialsId: 'android-keystore', variable: 'ANDROID_KEYSTORE_FILE'),
          string(credentialsId: 'android-keystore-password', variable: 'ANDROID_KEYSTORE_PASSWORD'),
          string(credentialsId: 'android-key-alias', variable: 'ANDROID_KEY_ALIAS'),
          string(credentialsId: 'android-key-password', variable: 'ANDROID_KEY_PASSWORD')
        ]) {
          withEnv([
            'PLAY_SERVICE_ACCOUNT_JSON=' + PLAY_JSON,
            'ANDROID_KEYSTORE_PATH=' + ANDROID_KEYSTORE_FILE,
            'ANDROID_KEYSTORE_PASSWORD=' + ANDROID_KEYSTORE_PASSWORD,
            'ANDROID_KEY_ALIAS=' + ANDROID_KEY_ALIAS,
            'ANDROID_KEY_PASSWORD=' + ANDROID_KEY_PASSWORD
          ]) {
            sh '''
              set -euo pipefail
              rm -f android/app/google-services.json
              cp "$FIREBASE_ANDROID_CONFIG" android/app/google-services.json
              chmod 0644 android/app/google-services.json
            '''
            dir('android') {
              sh 'bundle exec fastlane android tests'
              sh 'bundle exec fastlane android build_release'
            }
            archiveArtifacts artifacts: 'build/app/outputs/**/*.apk,build/app/outputs/**/*.aab', allowEmptyArchive: true, fingerprint: true
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
          string(credentialsId: 'appstore-connect-issuer-id', variable: 'APPSTORE_ISSUER_ID'),
          file(credentialsId: 'firebase-ios-config', variable: 'FIREBASE_IOS_CONFIG')
        ]) {
          withEnv([
            'APPSTORE_KEY_PATH=' + APPSTORE_KEY_FILE,
            'APPSTORE_KEY_ID=' + APPSTORE_KEY_ID,
            'APPSTORE_ISSUER_ID=' + APPSTORE_ISSUER_ID
          ]) {
            sh '''
              set -euo pipefail
              install -m 0644 "$FIREBASE_IOS_CONFIG" ios/Runner/GoogleService-Info.plist
            '''
            dir('ios') {
              sh 'bundle exec fastlane ios tests'
              sh 'bundle exec fastlane ios build_release'
            }
          }
        }
      }
    }
  }
}
