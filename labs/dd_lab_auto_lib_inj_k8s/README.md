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
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
    3. Add users
    ```shell
    sudo groupadd docker  
    sudo usermod -aG docker $USER  
    ```
    4. Log in and out to avoid using sudo. Once back in, run the Rancher instance using the next command
    ```shell
    docker run -d --restart=unless-stopped -p 81:80 -p 444:443 --privileged rancher/rancher:v2.6-head  
    ```
    5. Get container ID and the bootstrap password
    ```shell
    docker container ls
    docker logs <container_id> 2>&1 | grep "Bootstrap Password:"

    ```
    6. Navigate to the Rancher GUI. Skip the certificate warnings. Use the bootstrap password and change your login.
    ```shell
    https://<ip_of_instance>:444  

    ```


