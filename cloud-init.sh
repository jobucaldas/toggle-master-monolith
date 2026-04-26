#!/bin/bash
# Update and install packages
sudo dnf update -y
sudo dnf install -y git docker
sudo systemctl enable --now docker

# Setup app
git clone https://github.com/jobucaldas/toggle-master-monolith.git
sudo docker build -t toggle-master-monolith:1.0.0 toggle-master-monolith/.

# Run app
export SECRET=$(aws secretsmanager get-secret-value --secret-id 'arn:aws:secretsmanager:us-east-1:905418296826:secret:tech-challenge-1/toggle-master/psql-5tl805' --query 'SecretString' --output text)
sudo docker run -d --name=togglemaster --restart=always -p 5000:5000 \
 -e DB_HOST=$(echo $SECRET | jq -r '.Host') \
 -e DB_PORT=$(echo $SECRET | jq -r '.Port') \
 -e DB_USER=$(echo $SECRET | jq -r '.User') \
 -e DB_NAME=$(echo $SECRET | jq -r '.Name') \
 -e DB_PASSWORD=$(echo $SECRET | jq -r '.Password') \
 toggle-master-monolith:1.0.0
