pipeline {
    agent {
        kubernetes {
            // the shared pod template defined on the Jenkins server config
            inheritFrom 'shared'
            // r pod template defined in molgenis/molgenis-jenkins-pipeline repository
            yaml libraryResource("pod-templates/r-4_0_3.yaml")
        }
    }
    environment {
        REPOSITORY = 'molgenis/molgenis-r-auth'
        REGISTRY = 'https://registry.molgenis.org/repository/r-hosted'
        REGISTRY_DEV = 'https://registry.molgenis.org/repository/r-hosted-snapshots'
    }
    stages {
        stage('Prepare') {
            steps {
                container('vault') {
                    script {
                        env.GITHUB_TOKEN = sh(script: 'vault read -field=value secret/ops/token/github', returnStdout: true)
                        env.GITHUB_PAT = env.GITHUB_TOKEN
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
                    sh "tlmgr install collection-fontsrecommended"
                    sh "install2.r devtools urltools httr pkgdown mockery git2r"
                    sh "installGithub.r fdlk/lintr"
                    sh "Rscript -e \"git2r::config(user.email = 'molgenis+ci@gmail.com', user.name = 'MOLGENIS Jenkins')\""
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
                    sh "Rscript -e 'devtools::check(remote=TRUE, force_suggests = TRUE, error_on=\"error\")'"
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

                    // this solves git's "dubious ownership" complaint, but we have no idea why and how only this repo is suddenly affected
                    sh "git config --global --add safe.directory /home/jenkins/agent/workspace/molgenis_molgenis-r-auth_master"
                    sh "git commit -a -m 'Increment version number'"
                    sh "echo 'Building ${PACKAGE} v${TAG}'"
                    sh "R CMD build ."
                    sh "Rscript -e 'devtools::check_built(path = \"./${PACKAGE}_${TAG}.tar.gz\", remote=TRUE, force_suggests = TRUE)'"
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

                    // this solves git's "dubious ownership" complaint, but we have no idea why and how only this repo is suddenly affected
                    sh "git config --global --add safe.directory /home/jenkins/agent/workspace/molgenis_molgenis-r-auth_master"
                    sh "git commit -a -m 'Increment version number'"
                    sh "echo \"Releasing ${PACKAGE} v${TAG}\""
                    sh "R CMD build ."
                    sh "Rscript -e 'devtools::check_built(path = \"./${PACKAGE}_${TAG}.tar.gz\", remote=TRUE, force_suggests = TRUE)'"
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
