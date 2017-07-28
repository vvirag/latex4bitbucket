# latex4bitbucket
Dockerfile for latex4bitbucket image: Ubuntu image with **texlive** and **gdcp** (google drive copy).

Intended to use from bitbucket pipeline to automate build for latex projects.

Since bitbucket pipeline does not keep artifacts, this image includes gdcp to be able to automatically copy the generated files to a Google Drive folder.

The docker image is available here: https://hub.docker.com/r/vvirag/latex4bitbucket/

## Prerequisite: setup gdcp on your local system
To generate and setup the necessary credentials to reach Google Drive, first you have to generate these on your local machine.

1. Go and follow the installation steps at https://github.com/ctberthiaume/gdcp
1. Go to your Google Drive, and select the folder you want to use
1. Right click and select `Get shareable link..`. In the pop up window you can see the Google Drive ID of the given directory, something like that: `https://drive.google.com/open?id=xxxxxxxxxxxxxxxxxxxxxxxxxxxx`
1. You need this ID later to be able to use gdcp.
1. Continue with the setup steps at https://github.com/ctberthiaume/gdcp

## Set up bitbucket pipeline
The goal is to setup an automated build system for a latex project that not only compiles latex, but also copies the generated output to a given Google Drive folder. The example configuration below generates a `build-YYYYmmDD_HHMMSS` subfolder under the remote Google Drive folder, and copies there the generated `.pdf`, `.log`, and `.bbl` files.

1. Enable pipeline on your bitbucket project
1. Example pipeline configuration:
```
image: vvirag/latex4bitbucket
pipelines:
  default:
    - step:
        script:
          - set +e
          - latexmk -cd -e '$$pdflatex="pdflatex -interaction=nonstopmode %S %O"' -f -pdf main.tex
          - echo "Compiling done!"
          - echo $GDCP_CLIENT_SECRETS > /root/.gdcp/client_secrets.json
          - echo $GDCP_CREDENTIALS > /root/.gdcp/credentials.json
          - dirname="build-"$(date +"%Y%m%d_%H%M%S")
          - mkdir $dirname
          - cp *.pdf $dirname/
          - cp *.log $dirname/
          - cp *.bbl $dirname/
          - gdcp upload -p $GDCP_FOLDER ./$dirname
          - echo "Publishing on Google Drive done!"
```
1. On bitbucket, go for `Settings/Pipeline/Environment variables`
1. Add two variables with the name of `GDCP_CLIENT_SECRETS` and `GDCP_CREDENTIALS`. Copy the content of your local `~/.gdcp/client_secrets.json` and `~/.gdcp/credentials.json` files (generated during the **Prerequisite: setup gdcp on your local system** step earlier in this description.) into the value fields.
1. Add `GDCP_FOLDER` variable. The value should be the Google Drive folder ID that was noted during the **Prerequisite: setup gdcp on your local system** step earlier in this description.


You're all good now. At each `git push` on your bitbucket project, this pipeline is automatically invoked: it will try to compile your latex files, and then copies the outputs (`.pdf`, `.log`, `.bbl`) to the configured remote Google Drive folder, under a timestamped build subdirectory.

