pipeline {
    agent {
        kubernetes {
            label 'r-4.0.2'
        }
    }
    environment {
        REPOSITORY = 'molgenis/molgenis-r-auth'
        REGISTRY = 'https://registry.molgenis.org/repository/r-hosted'
        REGISTRY_DEV = 'https://registry.molgenis.org/repository/r-hosted-snapshots'
    }
    stages {
        stage('Prepare') {
            when {
                not {
                    changelog 'Increment version number'
                }
            }
            steps {
                container('vault') {
                    script {
                        env.GITHUB_TOKEN = sh(script: 'vault read -field=value secret/ops/token/github', returnStdout: true)
                        env.GITHUB_DEPLOY_PRIVATE_KEY_BASE64 = sh(script: 'vault read -field=ssh_private_base64 secret/ops/account/github', returnStdout: true)
                        env.CODECOV_TOKEN = sh(script: 'vault read -field=molgenis-r-auth secret/ops/token/codecov', returnStdout: true)
                        env.NEXUS_USER = sh(script: 'vault read -field=username secret/ops/account/nexus', returnStdout: true)
                        env.NEXUS_PASS = sh(script: 'vault read -field=password secret/ops/account/nexus', returnStdout: true)
                    }
                }
                script {
                    env.PACKAGE = sh(script: "grep Package DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                }
                sh "git remote set-url origin https://${GITHUB_TOKEN}@github.com/${REPOSITORY}.git"
                sh "git fetch --tags"
                container('r') {
                    sh "Rscript -e \"git2r::config(user.email = 'molgenis+ci@gmail.com', user.name = 'MOLGENIS Jenkins')\""
                    sh "install2.r remotes urltools httr pkgdown"
                    sh "installGithub.r fdlk/lintr"
                    sh "mkdir -m 700 -p /root/.ssh"
                    sh "ssh-keyscan -H -t rsa github.com  > ~/.ssh/known_hosts"
                }
            }
        }
        stage('Install and test: [ PR ]') {
            when {
                changeRequest()
            }
            steps {
                container('r') {
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "R CMD build ."
                    sh "R CMD check --as-cran ${PACKAGE}_${TAG}.tar.gz"
                }
            }
            post {
                always {
                    container('r') {
                        sh "Rscript -e 'lintr::lint_package(linters=lintr::with_defaults(object_usage_linter = NULL))'"
                        sh "Rscript -e 'library(covr);codecov()'"
                    }
                }
            }
        }
        stage('Install and test: [ master ]') {
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                container('r') {
                    sh "Rscript -e \"usethis::use_version('dev')\""
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "git commit -a -m 'Increment version number'"
                    sh "echo 'Building ${PACKAGE} v${TAG}'"
                    sh "R CMD build ."
                    sh "R CMD check --as-cran ${PACKAGE}_${TAG}.tar.gz"
                    sh "Rscript -e 'quit(save = \"no\", status = length(lintr::lint_package(linters=lintr::with_defaults(object_usage_linter = NULL))))'"
                }
            }
            post {
                always {
                    container('r') {
                        sh "Rscript -e 'library(covr);codecov()'"
                    }
                }
            }
        }
        stage('Release dev: [master]'){
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                container('curl') {
                    sh "set +x; curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file ${PACKAGE}_${TAG}.tar.gz ${REGISTRY_DEV}/src/contrib/${PACKAGE}_${TAG}.tar.gz"
                }
                sh "git tag v${TAG}"
                sh "git push --tags origin master"
            }
        }
        stage('Release: [ master ]') {
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    script {
                        env.RELEASE_SCOPE = input(
                                message: 'Do you want to release?',
                                ok: 'Release',
                                parameters: [
                                        choice(choices: 'patch\nminor\nmajor', description: '', name: 'RELEASE_SCOPE')
                                ]
                        )
                    }
                }
                milestone 2
                sh "git diff"
                container('r') {
                    sh "Rscript -e \"usethis::use_version('${RELEASE_SCOPE}')\""
                    sh "Rscript -e \"pkgdown::build_site()\""
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "git commit -a -m 'Increment version number'"
                    sh "echo \"Releasing ${PACKAGE} v${TAG}\""
                    sh "R CMD build ."
                    sh "R CMD check --as-cran ${PACKAGE}_${TAG}.tar.gz"
                    container('curl') {
                        sh "set +x; curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file ${PACKAGE}_${TAG}.tar.gz ${REGISTRY}/src/contrib/${PACKAGE}_${TAG}.tar.gz"
                    }
                    sh "git tag v${TAG}"
                    sh "git push --tags origin master"
                    sh "set +x; Rscript -e \"pkgdown::deploy_site_github(ssh_id = '${GITHUB_DEPLOY_PRIVATE_KEY_BASE64}', tarball = '${PACKAGE}_${TAG}.tar.gz', repo_slug='${REPOSITORY}')\""
                }
            }
            post {
                success {
                    molgenisSlack(message: ":confetti_ball: Released ${PACKAGE} v${TAG}. See https://github.com/${REPOSITORY}/releases/tag/v${TAG}", color:'good')
                }
            }
        }
    }
}
