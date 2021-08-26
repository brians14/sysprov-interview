Small exercise to assess interview candidates approach to development with IaC, scripting, and configuration management.

1. Using a configuration management tool of choice (i.e. Puppet, Ansible, CFEngine, etc.), provide the following configuration for a CentOS/RHEL web server:
    * Install tuned and apply throughput-performance profile
    * Install web server package (Ex. httpd or nginx) that serves a simple static page
        * Create index.html containing "Hello, World!"
    * Ensure web server service is enabled and started

2. Debug the [perl script](scripts/broken_bits.pl) and correct errors. (Tested on perl v5.16.3)
    * 4 errors total that need to be corrected

3. Convert the [perl script](scripts/broken_bits.pl) to another language of choice (python, ruby, etc.)

4. (Preferably Azure/GCP) Using terraform, implement a solution using Linux VM instance(s) running the web server configuration from exercise 1, that is resilient to downtime/outages.


------------------------------------------------------------------------------
* Dependency installation  (Fedora 34)
  * [Terraform](https://www.terraform.io/downloads.html)
    ```bash
    # Download the zip file; x64 for this example
    curl -o ~/Downloads/terraform.zip  https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip
    
    # Unzip the archive and place it in a directory that is part of your system's PATH
    $ echo $PATH
    $ unzip ~/Downloads/terraform.zip -d ~/.local/bin/
    
    # Ensure the binary is accessible
    $ which terraform
    ```
  * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf)
    ```bash
    # Import repository key
    $ sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    # Create repository file
    echo -e "[azure-cli]
    name=Azure CLI
    baseurl=https://packages.microsoft.com/yumrepos/azure-cli
    enabled=1
    gpgcheck=1
    gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
    
    # Login to your Azure account
    $ az login 
    
    # Create a Service Principal
    $ az ad sp create-for-rbac --name sysprov_interview  #TODO Save the output from the previous command in a secure place
   
    # Set Principal credentials in your local environment
    echo '
    export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
    export ARM_TENANT_ID="<azure_subscription_tenant_id>"
    export ARM_CLIENT_ID="<service_principal_appid>"
    export ARM_CLIENT_SECRET="<service_principal_password>"
    ' >> ~/.bashrc
    
    # Load the new variables by executing the .bashrc script
    source ~/.bashrc
    
    ```
    
 * Ansible
   ```bash
   # Update respository db
   $ sudo dnf check-update
   
   # Install Ansible
   $ sudo dnf install ansible -y
   ```

* Setup VM and configure everything update

```bash
    bash ./create.sh
```


* Destroy VM and restore ansible hosts file

``` bash
    bash ./destroy.sh
```
