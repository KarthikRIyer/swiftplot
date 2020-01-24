# Setting up docker container for SwiftPlot and Swift-Jupyter

To use Swiftplot in a notebook, it requires setting up of swift-jupyter environment, either in Ubuntu or Docker. While either of the approaches are not very difficult, Docker approach provides a consistent way to setup environment dor MacOS or Windows. This document highlights the steps needed to setup docker container for SwiftPlot. 

<H3> Install Docker Desktop </H3>

1. First step is to download Docker desktop application from www.docker.com. To download OS specific version (MacOS or Windows) of desktop application, please singup (or sign-in for those who had already signed up). 
2. Once successfully signed-in, please download right version of Docker Desktop.  
3. Install the desktop application and sign-in to start Docker Desktop.

<H3> Clone swift-jupyter Repo </H3>

To get latest docker image for swift-jupyter, git clone https://github.com/google/swift-jupyter.git. The repo contains docker image and other libraries related to swift-jupyer. 

<H3> Build and Run the container for swift-jupyter </h3>

To build the container, following command to be used:

```
# from inside the directory of this repository
docker build -f docker/Dockerfile -t swift-jupyter .
```
The resulting container comes with the latest toolchain installed, along with Jupyter notebooks (for Swift) contained in the repo.

Once the docker build, the notebook can be opened with the following command:

```
docker run -p 8888:8888 --cap-add SYS_PTRACE -v <host directory>:/notebooks swift-jupyter
```
Information about the parameters passed in above command:
* `-p 8888:8888` is the port on which Jupyter is running in the host
* `--cap-add SYS_PTRACE` adjusts the previleges with which the container is run
* `-v <host directory>` mounts host directory for storing notebooks created in the container. If the host directory is not mentioned then notebooks will not survive when the container is stopped.

<H3> Additonal Updates </H3>

There are a few libraries, required for SwiftPlot, are missing in current docker image. To install those required libraries in the container, identify the container ID where swift-jupyter is running. To get container ID, following command is used:
````
docker ps
````

It will show all the docker instances running currently and choose the container id.  Using the following command:

````
# 6c4ecaa31e1f is an example id and needs to be replaced with specific container ID
docker exec -it 6c4ecaa31e1f bash
````
After getting into specific docker container, following statement will install required libraries:
````
apt-get install libfreetype6-dev
````
This will install all libraries required to run Swiftplot in swift-jupyter. 


