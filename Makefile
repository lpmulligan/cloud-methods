install:
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ trusty main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
	sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
	sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list'
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
	curl https://packages.microsoft.com/config/ubuntu/14.04/prod.list > ./microsoft-prod.list
	sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/
	sudo apt-get update
	sudo apt-get install -y apt-transport-https azcopy azure-cli

build: install
	rm -rf public
	mkdir themes
	git clone https://github.com/zyro/hyde-x.git themes/hyde-x
	hugo

deploy: build
	azcopy --source $$SOURCE_DIR --destination $$DESTINATION_PATH --dest-key $$AZURE_STORAGE_ACCESS_KEY --recursive --quiet --set-content-type
	az login --service-principal -u $$AZURE_SERVICE_PRINCIPAL_APP_ID --password $$AZURE_SERVICE_PRINCIPAL_APP_PASSWORD --tenant $$AZURE_SERVICE_PRINCIPAL_TENANT
	az cdn endpoint purge -g $$CDN_RESOURCE_GROUP -n $$CDN_ENDPOINT_NAME --profile-name $$CDN_PROFILE --content-paths "/*"
