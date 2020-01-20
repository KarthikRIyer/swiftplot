# Setting up docker container for SwiftPlot and Swift-Jupyter

To use Swiftplot in a notebook, it requires setting up of swift-jupyter environment, either in Ubuntu or Docker. While either of the approaches are not very difficult, Docker approach provides a consistent way to setup environment. In this document, I will highlight steps needed to setup docker container for Swiftplot.

<H3> Install Docker Desktop </H3>

1. First step is to download Docker desktop application from www.docker.com. To download your OS specific version of desktop application, please singup (or signin if you have signed earlier). 
2. Once successfully signed-in, head out to download area and choose right version (based on your OS) of Dcoker to download. 
3. Install the desktop application and sign-in to start Docker Desktop

<H3> Clone swift-jupyter Repo </H3>

Next you need to get docker image for swift-jupyter. You can use git clone to get the repo https://github.com/google/swift-jupyter.git. The repo contains docker image and other libraries related to swift-jupyer. 

<H3> Build and Run the container for swift-jupyter </h3>

To build the container, following command to be used:

```
# from inside the directory of this repository
docker build -f docker/Dockerfile -t swift-jupyter .
```
The resulting container comes with the latest toolchain installed, along with Jupyter notebooks contained in the repo.

Once the docker build, you can run the notebook with the following command:

```
docker run -p 8888:8888 --cap-add SYS_PTRACE -v <host directory>:/notebooks swift-jupyter
```
Information about the parameters passed in above command:
* `-p 8888:8888` is the port on which Jupyter is running in the host
* `--cap-add SYS_PTRACE` adjusts the previleges with which the container is run
* `-v <host directory>` mounts host directory for storing notebooks created in the container. If the host directory is not mentioned then notebooks will not survive when the container is stopped.

<H3> Additonal Updates </H3>

There are a few libraries, required to run SwiftPlot, are missing in current docker image. You need to install those libraries in the container. To get into the container, first you need to find container id. To get container ID, please enter the following command:
````
docker ps
````

It will show all the docker instances running currently and choose the container id.  Using the following command:

````
# my Container ID is 6c4ecaa31e1f and you replace with yours
docker exec -it 6c4ecaa31e1f bash
````
Once get into docker build, install the following libraries:
````
apt-get install libfreetype6-dev
````
This will install all libraries required to run Swiftplot in swift-jupyter. 


