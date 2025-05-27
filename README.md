# NodeJS_DynatraceRunTime
Adding DT Tokens at runtime instead of buildtime
https://shell.cloud.google.com/?pli=1&show=ide%2Cterminal![image](https://github.com/user-attachments/assets/0397d227-1a6b-4cf3-a58c-12ab9b3aa37d)

# 1. Set Up Project Structure
Create a folder like dynatrace-node-test, and inside it:

````
  mkdir dynatrace-node-test
  cd dynatrace-node-test

````

# 2. Copy the following files from the repo above:

````
index.js
package.json
entrypoint.sh
Dockerfile
````

# 3. Make entrypoint executable:

````
chmod +x entrypoint.sh
````

# 4. Store Dynatrace Secret Tokens in Secrets Manager

````
echo -n "PAAS_TOKEN" | gcloud secrets create dynatrace-api-token --data-file=-
````

![image](https://github.com/user-attachments/assets/6eca4a05-aa41-463b-a714-cd93b8e7ab77)

# 4. Create a Service Account and Provision Access to the Secret from Step 4.

````
gcloud iam service-accounts create cloud-run-dynatrace --display-name="Cloud Run Dynatrace Runtime SA"

````
Creates: cloud-run-dynatrace@YOUR_PROJECT_ID.iam.gserviceaccount.com

````
gcloud secrets add-iam-policy-binding dynatrace-api-token \
  --member="serviceAccount:cloud-run-dynatrace@$(gcloud config get-value project).iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

````

# 5. Provision Access to Main Account (You can provision to an SA as well).

````
gcloud projects add-iam-policy-binding fml-monitored-project \
  --member="user:yap***@****.com" \
  --role="roles/cloudbuild.builds.editor"
````

Build and Push Docker Image

````
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/dynatrace-node-test
````

# 6. Deploy to Cloud Run (Note I am using DEFAULT flavor with NODE.JS), Replace API_URL with your environment ID.

````
gcloud run deploy dynatrace-node-test \
  --image gcr.io/$(gcloud config get-value project)/dynatrace-node-test \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --service-account=cloud-run-dynatrace@$(gcloud config get-value project).iam.gserviceaccount.com \
  --update-secrets=DT_API_TOKEN=dynatrace-api-token:latest \
  --set-env-vars=DT_API_URL=<YOUR ENV>/api \
  --set-env-vars=DT_ONEAGENT_OPTIONS="flavor=default&include=nodejs"
````

OR

````
gcloud run deploy dynatrace-node-test \
  --image gcr.io/$(gcloud config get-value project)/dynatrace-node-test \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --service-account=cloud-run-dynatrace@$(gcloud config get-value project).iam.gserviceaccount.com \
  --update-secrets=DT_API_TOKEN=dynatrace-api-token:latest \
  $(xargs -d '\n' -I {} echo --set-env-vars={} < preset.env)
````

# 7. Verify in Dynatrace

![image](https://github.com/user-attachments/assets/a0f4f58f-0d76-46e7-b405-ef2cb332fb36)
![image](https://github.com/user-attachments/assets/3fad0782-027f-4b61-9cc9-fb6c19b10441)
![image](https://github.com/user-attachments/assets/cd250149-ef89-46f7-be99-f84c9f3560f2)

# 8. Verify Token Security




