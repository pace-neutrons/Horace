[<-previous](0013-use-jenkins-for-secrets-management.md) | [next->](0015-store-pixel-data-in-single-precision.md)

# 14 - Use Jenkins for Network Path Storage

Date: 2020-May-18

## Status

Accepted

## Context

The [large data storage area](./0012-use-network-storage-for-large-datafiles.md) is shared by all the PACE projects and accessed via as network path.

This path should not be hard-coded in any scripts in order that it can be easily updated if the network storage location is moved.

For security reasons it is undesirable for this path to be stored in configuration files in the GitHub repositories.

## Decision

The data will be stored in ANVIL through the available Jenkins [Credentials](https://plugins.jenkins.io/credentials/) plugin.

The path will be stored the `PACE-neutrons`  store with the ID `SAN_path`.

## Consequences

- The path is only stored once and shared across all projects, so may be simply updated.

- The path is accessible as a variable from the Jenkinsfile and passed into called scripts via 

  ```
  withCredentials([string(credentialsId: 'SAN_path', variable: 'san_path')]) {
    sh '''
      my-script.sh $san_path
    '''
  }
  ```

- It is NOT possible to view the values of the path stored in the Jenkins Credentials plugin and its value will be masked in the build logs.

- This path will NOT be accessible on a developer machine. If the path is used as a variable within a build script a separate configuration process must be set up.
