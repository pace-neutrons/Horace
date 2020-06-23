[<-previous](0012-use-network-storage-for-large-datafiles.md) | [next->](0014-use-jenkins-for-network-path-storage.md)

# 13 - Use Jenkins for Secrets Management

Date: 2020-May-18

## Status

Accepted

## Context

The build processes for all of the PACE projects require credentials to access GitHub and the SAN area. 
These need to be stored securely and be accessible to steps in the Jenkinsfile and any scripts launched from that.

For security reasons this data cannot be stored in the build or pipeline scripts as these are stored in GitHub.

## Decision

The data will be stored in ANVIL through the available Jenkins [Credentials](https://plugins.jenkins.io/credentials/) plugin.

A `file` object will be used for the SAN credentials as this maps directly onto the format required by be `gio mount` syntax on Linux build nodes.

A `string` object will be used for other credentials types, e.g. GitHub access tokens.

Credentials will be stored in the `PACE-neutrons`  store and use `snake_case` IDs that clearly identify their use. The first word will identify the associated system, e.g. `SAN_credentials_file`.



## Consequences

- Credentials are stored in one location and can be accessed by all PACE projects.

- Stored credentials accessible as variables from Jenkinsfile which can be passed into called scripts via 

  ```
  withCredentials([string(credentialsId: 'github_token', variable: 'my_github_token')]) {
    sh '''
      my-script.sh $my_github_token
    '''
  }
  ```

- It is NOT possible to view the values of the credentials stored in the Jenkins Credentials plugin and their values are masked in build logs.

- These credentials will not be available on developer machines executing the build scripts. Access to SAN and GitHub should use the developers credentials.
