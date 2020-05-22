# How to use the SAN area

ISIS has provided a storage area in which PACE can keep large test data. The
area should contain data files from which we derive smaller sets of data
(alongside scripts recording how the smaller sets were generated) and files
that are too large to store in git repositories.

A FedID is required in order to mount the SAN area. In order to mount the SAN
on PACE's systems, a dedicated user ID with which to mount the SAN area has
been provided to PACE.

## Mounting the SAN on Jenkins

The path to the SAN is stored as a secret in Jenkins with the ID `SAN_path`.
To mount the SAN when running a Jenkins pipeline, you should use the dedicated
user ID provided to PACE. The credentials for this are stored in a credentials
file with ID `SAN_credentials_file`.

One way to mount the drive on Linux is to use `gio`. The code fragment below
gives an example of how to copy the file `README.txt` from the SAN area in a
Jenkinsfile. ANVIL requires the use of `dbus-run-session` when mounting the
drive.

```groovy
pipeline {
  agent any

  stages {
    stage('Mount-And-Copy') {
      steps {
        withCredentials([file(credentialsId: 'SAN_credentials_file', variable: 'san_credentials')]) {
          withCredentials([string(credentialsId: 'SAN_path', variable: 'san_path')]) {
            sh '''
              echo "gio --version; gio mount smb:${san_path} < ${san_credentials}; gio copy smb:${san_path}/README.txt . -p" > test_script.sh
              cat test_script.sh
              dbus-run-session -- sh test_script.sh
              ls
              cat README.txt
            '''
          }
        }
      }
    }
  }
}
```
