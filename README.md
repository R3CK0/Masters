# Set-up Environement

## 1. Install Ubuntu 22.04 in a fresh partition or VM 
You can find the download link [here](https://releases.ubuntu.com/jammy/)  
Use ventoy to create a bootable device if you decide to go the dual boot way [ventoy](https://ventoy.net/en/index.html)
## 2. Install initial required packages for compilation:  
```
sudo apt-get install -y gcc build-essentiel curl typeguard pyyaml flask libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev pkg-config
```
### 2.1 Install singularity
In order to be able to install solvers into planutils to test planning whithin VSCode PDDL extension singularity is required  
Follow instruction at [singularity installer](https://github.com/sylabs/singularity/blob/main/INSTALL.md)
## 3. Install the Nvidia drivers  
### 3.1 Graphics driver:  
- [Graphic Driver download page](https://www.nvidia.com/download/index.aspx)  
### 3.2 Cuda Toolkit:  
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4 cuda-drivers
```
**Note:** test installation of the graphical drivers with `nvidia-smi` and the installation of cuda with `nvcc --version`. In the case where cuda is not found you must update your path. Find cuda installation, usually in `ls /usr/local/cuda/bin` if it's there you can add cuda to your path the following way.
```
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```
### 3.3 CuDNN installation  
```
wget https://developer.download.nvidia.com/compute/cudnn/9.1.0/local_installers/cudnn-local-repo-ubuntu2204-9.1.0_1.0-1_amd64.deb
sudo dpkg -i cudnn-local-repo-ubuntu2204-9.1.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2204-9.1.0/cudnn-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cudnn
```
## 4. Download and install [omniverse](https://www.nvidia.com/en-us/omniverse/download/)  
Once downloaded run it by giving it permission `chmod +x` and then `./omniverse-launcher-linux.appimage`. Follow the steps for installation
## 5. ROS2:  
For Ubuntu 22.04 as well as plansys2 MoveIt2! and Omniverse IsaacSim ROS 2 version must be Iron. The installation instructions and detailed tutorials can be found [here](https://docs.ros.org/en/iron/Installation.html)  
### Set up locale
```
locale  # check for UTF-8

sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings
```
### Enable required repositories
Make sure Ubuntu univese repositories are properly configured
```
sudo apt install software-properties-common
sudo add-apt-repository universe
```
### Add the ROS2 GPG key with apt
```
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
```
Then add the repo to your source lists
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```
### Install ROS2
```
sudo apt update
sudo apt upgrade
sudo apt install ros-iron-desktop
```
Test out installation, run the talker in one terminal and the listener in another
```
# Replace ".bash" with your shell if you're not using bash
# Possible values are: setup.bash, setup.sh, setup.zsh
source /opt/ros/iron/setup.bash
ros2 run demo_nodes_cpp talker
ros2 run demo_nodes_py listener
```
## 6. Install Plansys2:
You can install the stable release simply with `sudo apt install ros-iron-plansys2-*`. More information [here](https://plansys2.github.io/build_instructions/index.html)  
## 7. Install MoveIt!2
Same thing for MoveIt2!, it can be installed easily by `sudo apt install ros-iron-moveit`

