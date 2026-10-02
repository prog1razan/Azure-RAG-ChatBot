# Solution

## Creating the Infrastructure with Terraform

To use this solution, you first need to create a folder named ssh-keys and place your SSH public key inside it. Rename the key file to terraform-azure.pub.

Next, create a file named terraform.tfvars and add the following content:

```
resource_group_name = "YOUR-GROUP-NAME"
subscription_id     = "YOUR-SUBSCRIPTION-ID"
```

Replace YOUR-GROUP-NAME with your Azure resource group name and YOUR-SUBSCRIPTION-ID with your Azure subscription ID.

Finally, run the following commands to initialize Terraform and deploy the infrastructure:

```sh
terraform init
terraform apply
```

## Azure Database for PostgreSQL server

Once the infrastructure is provisioned, we will configure the Azure Database for PostgreSQL server manually. The steps are as follows:

1. Create a new database called `appdb` on Azure.
2. Configure the firewall rules to allow your IP address to connect to the database.
3. Use DBeaver to connect to the `appdb` database and create a new user called `appuser` with the password `appuser`:

   ```sql
   CREATE USER appuser WITH ENCRYPTED PASSWORD 'appuser';
   GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
   GRANT ALL PRIVILEGES ON SCHEMA public TO appuser;

   CREATE TABLE IF NOT EXISTS advanced_chats (
       id TEXT PRIMARY KEY,
       name TEXT NOT NULL,
       file_path TEXT NOT NULL,
       last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       pdf_path TEXT,
       pdf_name TEXT,
       pdf_uuid TEXT
   );

   GRANT ALL PRIVILEGES ON TABLE advanced_chats TO appuser;
   ```

## Azure Blob Storage

1. Create a Shared Access Signature (SAS) for the storage account. Make sure to select all options under `Allowed resource types` and set the appropriate expiry time. Copy the generated `Blob service SAS URL`.
2. Copy the Blob service SAS URL and paste it in the `.env` file in your VM.

## Azure VM

1. SSH into the virtual machine `ssh -i YOUR-PRIVATE-KEY-PATH azureuser@YOUR-VM-PUBLIC-IP`
2. Install Docker using installDocker.sh script. Remember to exit the SSH session after the installation is complete and ssh back into the VM to let the Docker service start.
3. Create an `.env` file including

```env
OPENAI_API_KEY=YOUR-API-KEY
DB_NAME=YOUR-DB-NAME
DB_USER=YOUR-DB-USER
DB_PASSWORD=YOUR-DB-PASSWORD
DB_HOST=YOUR-DB-HOST
DB_PORT=YOUR-DB-PORT
AZURE_STORAGE_SAS_URL=YOUR-SAS-URL
AZURE_STORAGE_CONTAINER=YOUR-CONTAINER-NAME
CHROMADB_HOST=chromadb
CHROMADB_PORT=8000
```

4. Start the application using Docker Compose

```sh
docker compose up --build -d
```

In the end, you should be able to access the application via the VM’s public IP address, with data stored in the Azure Database for PostgreSQL server and files stored in Azure Blob Storage.
