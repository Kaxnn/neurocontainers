#!/usr/bin/env bash
set -e

echo "buildMode: $buildMode"

if [ "$buildMode" = "docker_singularity" ]; then
       echo "starting local docker build:"
       echo "---------------------------"
       sudo docker build -t ${imageName}:$buildDate -f  recipe.${imageName} .

       if [ "$testImageDocker" = "true" ]; then
              echo "tesing image in docker now:"
              echo "---------------------------"
              sudo docker run -it ${imageName}:$buildDate
       fi

       echo "uploading docker image now:"
       echo "---------------------------"
       sudo docker tag ${imageName}:$buildDate caid/${imageName}:$buildDate

       echo "====================================================="
       echo "run docker login if never logged in on that box:"
       echo "sudo docker login"
       echo "====================================================="

       sudo docker push caid/${imageName}:$buildDate
       sudo docker tag ${imageName}:$buildDate caid/${imageName}:latest
       sudo docker push caid/${imageName}:latest
fi

if [ "$buildMode" = "docker_singularity" ]; then
        echo "BootStrap:docker" > recipe.${imageName}
        echo "From:caid/${imageName}" >> recipe.${imageName}
        echo "" >> recipe.${imageName}
        echo "%labels" >> recipe.${imageName}
        echo "OWNER Steffen.Bollmann@cai.uq.edu.au" >> recipe.${imageName}
        echo "Build-date $buildDate" >> recipe.${imageName}
        echo "NAME $imageName" >> recipe.${imageName}
        echo "Description $imageName" >> recipe.${imageName}
        echo "VERSION $buildDate" >> recipe.${imageName}           
fi

if [ -f ${imageName}_${buildDate}.sif ] ; then
       echo "removing old local image file:"
       echo "----------------------"
       rm -rf ${imageName}_${buildDate}.sif
fi

if [ "$remoteSingularityBuild" = "true" ]; then
       echo "====================================================="
       echo "singularity remote login has to be done every 30days:"
       echo "singularity remote login"
       echo "====================================================="
       echo "starting remote build:"
       echo "----------------------"
       singularity build --remote ${imageName}_${buildDate}.sif recipe.${imageName}
fi


if [ "$localSingularityBuild" = "true" ]; then

       
       echo "starting local build:"
       echo "----------------------"
       sudo singularity build ${imageName}_${buildDate}.sif recipe.${imageName}
fi


if [ "$testImageSingularity" = "true" ]; then
       echo "testing singularity image:"
       echo "----------------------"
       sudo singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg
fi

if [ "$uploadToSwift" = "true" ]; then
       echo "uploading image to swift storage:"
       echo "----------------------"
       source ../setupSwift.sh
       swift upload singularityImages ${imageName}_${buildDate}.sif --segment-size 1073741824  
fi

git commit -am 'auto commit after build run'
git push