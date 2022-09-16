# This script is meant to run a backup of the server. It is not complete
# yet.

# A unique token is needed to run a back
TOKEN=`uuid`
# This was taken from the terraform outputs
EFS_ARN="arn:aws:elasticfilesystem:us-east-1:703606424838:file-system/fs-00ea2499d59477cb1"

aws backup start-backup-job \
  --backup-vault-name lambdacraft_backup_vault \
  --resource-arn $EFS_ARN \
  # need an IAM role
  --iam-role-arn ... \
  --idempotency-token $TOKEN \
  --start-window-minutes 0 \
  --complete-window-minutes 10080 \
  --region us-east-1
  #--lifecycle DeleteAfterDays=30
