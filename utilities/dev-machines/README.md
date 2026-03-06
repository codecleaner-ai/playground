## Overview

How to create a DEV machine from scratch.

You can create a DEV machine in Google Cloud using the Google Cloud Shell and the scripts in this repository.

#### Pre-Requisite:

- You have access to a [GCP project](https://console.cloud.google.com).
- You are allowed to create Compute instances in the project.
- You are allowed to access Remote Desktop with Google Chrome.

#### Tips and Tricks:

###### Check Status Of Running Script:

To check the status of a bash script that is currently running in the background you can open a terminal window on the machine and run the command

```bash
sudo journalctl -f -o cat
```
This displays the output of the script that's running in the background.
Once done you can exit with `Crtl C`.

###### Access the DEV Machine:

Via SSH in the Google Cloud Shell:

```bash
PROJECT=enter-the-name-of-your-project-here
CE_INSTANCE=enter-the-name-of-your-dev-machine-here
ZONE=enter-the-name-of-the-zone-where-the-dev-is-machine-here
gcloud compute ssh --project=$PROJECT --zone=$ZONE $CE_INSTANCE
```

## How to use this:

I try to explain how to use the code that I store there in the tutorial or article that uses this code.

- [How I’ve slashed the cost of my DEV environments by 90%](https://itnext.io/how-ive-slashed-the-cost-of-my-dev-environments-by-90-9c1082ad1baf?source=your_stories_page---------------------------).

## The commands you need to run:

- In the GCP Console, open the Cloud Shell terminal.
- Set Project to the correct project:

```bash
gcloud config set project <project-name>
```

Example:

```bash
gcloud config set project vocal-affinity-296007
```

- Copy the following files to GCP:
  - [create-dev-machine.sh](./create-dev-machine.sh).
  - [startup.sh](./startup.sh).
- Get the list of the available ubuntu images:

```bash
gcloud compute images list --filter ubuntu-os-cloud
```

- Edit the variables in the `create-dev-machine.sh` file.
- run the following command:

```bash
bash create-dev-machine.sh
```

## Additional Configuration:

Make sure that the installation script has run correctly: 

- Go to the [Google Compute Engine](https://console.cloud.google.com/compute/instances) page.
- Masure that you are in the correct project.
- Check that the machine is running.
- Open a SSH connection to the machine.
- Check the status of a bash script that is currently running in the background you can open a terminal window on the machine and run the command

```bash
sudo journalctl -f -o cat
```

This displays the output of the startup script that's running in the background. Once done you can exit with `Crtl C`.

You need to make sure that the installation script is finished before doing the below steps.

#### Configure Access Via Chrome Remote Access:

 Go to the [Chrome Remote Desktop page to set up access to a new machine](https://remotedesktop.google.com/headless) and follow the instructions to get the code that you need to allow access to your remote VM.

Connect to the newly created machine with the Google SSH web connection interface from the Google console.

- Copy the "Access code to the remote" to your remote VM.
- Run that code
- Provide a six digits PIN where prompted.
- Go to [Google Chrome Remote Desktop](https://remotedesktop.google.com/access).
- Access the remote VM.

#### Connect To The Machine Using Chrome Remote Desktop:

- Go to [Google Chrome Remote Desktop](https://remotedesktop.google.com/access).
- Access the remote VM.

###### Disable Autoscreen Lock:

- Go to Application >> Settings >> Screensaver.
- Click on the `Lock Screen` tab.
- Untick the option `Enable Lock Screen`.

#### Create a SSH Key:

- Go to the `.ssh` folder:

```bash
cd ~/.ssh
```

- Create a new ssh key

```bash
ssh-keygen -o -t rsa -C "your.address@email.com"
```

- Follow the on screen instructions (accept default).
- Best practice is to create a passphrase for the ssh key.

#### Replace The New Key With Your Existing SSH Key:

If you have an existing ssh key you can replace the content of the files:

- `id_rsa`: the PRIVATE key
- `id_rsa.pub`: The public key

With the correct value for your ssh key.

#### Configure the Terminal to display the git branch:

- On the DEV machine, with VS Code, open the `~/.bashrc` file
- At the end of the file add the following line

```bash
(...)

## Display the git branch
git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

## Update the default PS1 variable
## original  `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$`
## updated   `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$(git_branch)\$ "`
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$(git_branch)\$ "
```

- Restart `.bashrc`

```bash
source ~/.bashrc
```

- Close the terminal.
- Re-opent the terminal.
- Go to a git enabled folder.
- Check that the branch is correctly displayed like

```bash
userName@machineName:~/Documents/github/vue.playground (master)$
```

Once the machine is configured, install the following things.

###### On Chrome: 

- [Vue DEVTOOLS](https://github.com/vuejs/devtools##vue-devtools).

###### On Visual Studio: 

Install the following extensions:

  - Material Icons: Better looling icons in VS navbar
  - [Vue Extension](https://marketplace.visualstudio.com/items?itemName=jcbuisson.vue).
  - [es6-string-html](https://marketplace.visualstudio.com/items?itemName=Tobermory.es6-string-html)
  - Live Server: Right click to see the code in action.
  - Vetur: Vue tooling.
  - Vue: Vue Syntax Highlight
  - es6-string-html: html syntax highlight inside VUE
  - ESLint: make sure the indentation is correct.
