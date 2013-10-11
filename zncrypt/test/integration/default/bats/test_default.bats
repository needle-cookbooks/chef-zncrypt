#!/usr/bin/env bats

@test "mounts an ecryptfs file system on /var/lib/zncrypt/zncrypted" {
  run mount
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*/var/lib/zncrypt/zncrypted.*ecryptfs.*") -ne 0 ]
}

@test "moves secret data to encrypted storage" {
  cd /data/secrets
  run pwd -P
  [ $status -eq 0 ]
  [ ${lines[0]} = "/var/lib/zncrypt/zncrypted/trusted/data/secrets" ]
}

@test "ls is permitted to access secret.txt" {
  run ls /data/secrets/secret.txt
  [ $status -eq 0 ]
}

@test "cat is not permitted to access secret.txt" {
  run cat /data/secrets/secret.txt
  [ $status -eq 1 ]
}
