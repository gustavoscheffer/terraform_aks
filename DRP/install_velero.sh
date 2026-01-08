brew install velero 

$AZURE_BACKUP_RESOURCE_GROUP="Velero_Backups"
az group create -n $AZURE_BACKUP_RESOURCE_GROUP --location WestUS

$AZURE_STORAGE_ACCOUNT_ID="<NAME_OF_ACCOUNT_TO_ASSIGN>"

az storage account create --name $AZURE_STORAGE_ACCOUNT_ID --resource-group $AZURE_BACKUP_RESOURCE_GROUP --sku Standard_GRS --encryption-services blob --https-only true --kind BlobStorage --access-tier Hot


$BLOB_CONTAINER="velero"
az storage container create -n $BLOB_CONTAINER --public-access off --account-name $AZURE_STORAGE_ACCOUNT_ID

$AZURE_SUBSCRIPTION_ID=(az account list --query '[?isDefault].id' -o tsv)
$AZURE_TENANT_ID=(az account list --query '[?isDefault].tenantId' -o tsv)

$AZURE_CLIENT_ID=(az ad sp list --display-name "velero" --query '[0].appId' -o tsv)

$AZURE_CLIENT_SECRET=(az ad sp create-for-rbac --name "velero" --role "Contributor" --query 'password' -o tsv --scopes  /subscriptions/$AZURE_SUBSCRIPTION_ID)


cat <<EOF >./credentials-velero.txt
[default]
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID=$AZURE_TENANT_ID
AZURE_CLIENT_ID=$AZURE_CLIENT_ID
AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET
AZURE_RESOURCE_GROUP=$AZURE_BACKUP_RESOURCE_GROUP
AZURE_CLOUD_NAME=AzurePublicCloud
EOF


velero install --provider azure --plugins velero/velero-plugin-for-microsoft-azure:v1.5.0 --bucket $BLOB_CONTAINER --secret-file ./credentials-velero.txt --backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID,subscriptionId=$AZURE_BACKUP_SUBSCRIPTION_ID --use-restic

rm ./credentials-velero.txt

kubectl -n velero get pods
kubectl logs deployment/velero -n velero