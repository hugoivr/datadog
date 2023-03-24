# Automatic Library Injection Lab

## Setting up a Rancher instance

_This segment is taken from Jenks Gibbons Repo: https://github.com/jgibbons-cp/datadog/tree/main/kubernetes/rancher_


1. Launch your Ubuntu instance.
2. Prepare the host:
    1. Update libraries
    ```shell
    sudo apt-get update
    sudo apt upgrade
    ```
    2. Install Docker
    ```shell
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
    3. Add users
    ```shell
    sudo groupadd docker  
    sudo usermod -aG docker $USER  
    ```
    4. Log in and out to avoid using sudo
    ```shell
    docker run -d --restart=unless-stopped -p 81:80 -p 444:443 --privileged rancher/rancher:v2.6-head  
    ```
    5. Get container ID and the bootstrap password
    ```shell
    docker container ls
    docker logs <container_id> 2>&1 | grep "Bootstrap Password:"

    ```



