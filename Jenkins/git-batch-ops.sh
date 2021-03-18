#!/usr/bin/env bash

#set -e

REPOS_DIR="/Users/cnyang/repo/pcatms"
BRANCH="dev"
COMMITMSG="Jenkinsfile: enable hotfix branch triggering package building."

REPOS=(
pcatms-attendanceservicecommon/
pcatms-attendanceservicepamb/
pcatms-attendanceservicepacs/
pcatms-attendanceservicephkl/
pcatms-phkl/
pcatms-pamb/
pcatms-pacs/
pcatms-common/
pcatms-litmossync/
pcatms-CourseCompletion/
pcatms-eureka/
)

cd ${REPOS_DIR}

#RULE=$(grep -l "feature/PCATMSPHKL-18-create-config-map-files-for-phkl" */Jenkinsfile -R)
#RULE=$(find . -type d -maxdepth 1)
RULE=$(find . -type f -maxdepth 2 -name "*Jenkinsfile")

#echo $RULE

#REPOS=(${RULE})

echo ">> Going to deal with these repos: ${REPOS[@]}"
echo
echo "====== Checkout to $BRANCH and fetch/merge code ======"

for repo in "${REPOS[@]}"; do
    repo="${repo%/*}"
    echo -e "\n------ repo is: $repo ------"
    (cd $repo && \
    git checkout $BRANCH && \
    git fetch && git merge --commit ; \
    git status ;\
    git diff ;\
    cd -)
done
wait

read -p ">> Continue? [ENTER]" YES

## Write your git commands here:
echo "====== Make commits and push! ======"

for repo in "${REPOS[@]}"; do
    repo="${repo%/*}"
    echo -e "\n------ repo is: $repo ------"

    (cd $repo && \
    #LASTCOMMIT=$(git show dev --pretty=format:"%H" |head -1)
    #echo $LASTCOMMIT ;\
    #git cherry-pick $LASTCOMMIT ;\
    #git commit -am "$COMMITMSG" ;\
    git push ;\
    #git status ;\
    cd -)
done
wait

exit
