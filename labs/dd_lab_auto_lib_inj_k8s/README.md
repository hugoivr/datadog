# Automatic Library Injection Lab

## Connecting to your provided Azure instance

Please review the lab number that was assigned to you in the following list: https://docs.google.com/spreadsheets/d/1hPBRIHqvjKXgNPEJKD3o0IUSlhqNb5-A_62fA43Iq-8/edit?usp=share_link 

Download the corresponding key for your lab: https://docs.google.com/spreadsheets/d/1hPBRIHqvjKXgNPEJKD3o0IUSlhqNb5-A_62fA43Iq-8/edit?usp=share_link

You will need to modify the permissions to the key file:
```shell
sudo chmod 600 <key-filename.pem>
```

Use the following command with to connect to your instance via ssh:
```shell
ssh azureuser@<lab-ip> -i <key-filename.pem>
```


## Setting up a Rancher instance

_This segment is taken from Jenks Gibbons Repo: https://github.com/jgibbons-cp/datadog/tree/main/kubernetes/rancher_
_Thank you Jenks!_


1. Launch your Ubuntu instance.
2. Prepare the host:
    1. Update libraries
    ```shell
    sudo apt-get update
    sudo apt upgrade
    ```
    2. Install Docker
    ```shell
    sudo apt-get install docker.io
    ```
    3. Add users
    ```shell
    sudo groupadd docker  
    sudo usermod -aG docker $USER  
    ```
3. Run your Rancher environment:
    1. Log in and out to avoid using sudo. Once back in, run the Rancher instance using the next command
    ```shell
    docker run -d --restart=unless-stopped -p 81:80 -p 444:443 --privileged rancher/rancher:v2.6-head  
    ```
    2. Get container ID and the bootstrap password
    ```shell
    docker container ls
    docker logs <container_id> 2>&1 | grep "Bootstrap Password:"
    ```
    3. Navigate to the Rancher GUI. Skip the certificate warnings. Use the bootstrap password and change your login.
    ```shell
    https://<ip_of_instance>:444  
    ```


## Setting up kubectl


1. Install kubectl and get your kubeconfig file ready (_taken from official docs https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux_)
    1. Download binary
    ```shell
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  
    ```
    2. Install.
    ```shell
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```
    3. Verify installation.
    ```shell
    kubectl version --client --output=yaml 
    ```
    4. Enable autocomplete for kubectl.
    ```shell
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    source ~/.bashrc
    ```
