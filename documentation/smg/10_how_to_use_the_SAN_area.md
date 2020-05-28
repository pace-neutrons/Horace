# How to use the SAN area

ISIS has provided a storage area in which PACE can keep large test data. The
area should contain data files from which we derive smaller sets of data
(alongside scripts recording how the smaller sets were generated) and files
that are too large to store in git repositories.

A FedID is required in order to mount the SAN area. In order to mount the SAN
on PACE's systems, a dedicated user ID with which to mount the SAN area has
been provided to PACE.

## Mounting the SAN on Jenkins

The path to the SAN and the credentials to mount it are stored as [Jenkins
credentials](https://www.jenkins.io/doc/book/using/using-credentials/).
The path to the SAN is stored as a secret string and the credentials are stored
as a secret file. The path to the SAN is stored with ID `SAN_path`.
PACE has been provided with dedicated credentials to mount the SAN.
The credentials are stored in a secret file in Jenkins with the key
`SAN_credentials_file`.
The file has format:

```txt
username
domain
password
```

### Example

The examples below demonstrate how to mount the share and copy the file `README.txt` from the SAN area 
in a Jenkinsfile. In a production system you may want to have a separate bash script that contains the 
mount/copy commands and takes the SAN path and credentials as arguments.

#### Linux

One way to mount the drive on the ANVIL Linux build agents is to use `gio`. ANVIL requires the use of 
`dbus-run-session` when mounting the drive this way. 

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

#### Windows

A Windows build agent does not require the drive to mounted explicitly. This script works for both
`powershell` and `bat` script steps.

```groovy
pipeline {
  agent any

  stages {
    stage('Copy') {
      steps {
         withCredentials([string(credentialsId: 'SAN_path', variable: 'san_path')]) {
           bat '''
             // hide most of the verbose robocopy output, which will include the secret path
             robocopy "%san_path%" . README.txt /nfl /ndl /njh /njs /nc /np
             dir
             more README.txt
           '''
        }
      }
    }
  }
}
```

 