#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='bidstools'
export toolVersion='1.0.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

# yes | pip uninstall neurodocker
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --miniconda version=latest \
               mamba=true \
               conda_install='python=3.10 traits=6.3.2' \
               pip_install='bidscoin heudiconv pydeface' \
   --install opts="--quiet" wget zip qt6-base-dev libgl1 libgtk2.0-0 dcmtk xmedcon pigz libxcb-cursor0 \
   --workdir /opt/bru2 \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --dcm2niix method=source version=latest \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:heudiconv  \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

   # requires yes | before neurodocker
   # --fsl version=6.0.3 \ required for deface, but currently doesn't install because of problem with fsl conda environment


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
