#!/bin/bash
awslocal iam create-user --user terraform
awslocal iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name terraform
awslocal iam create-access-key --user-name terraform
