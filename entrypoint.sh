#!/bin/bash
# -e Exit immediately if a command exits with a non-zero status
# -x Echo all the commands as they run, not just echos
set -e -x

echo "#################################################"
echo "# This script performs the following steps:"
echo "#  - Configure GIT"
echo "#  - Build the Jekyll website"
echo "#  - Copy the newly generated Jekyll site to a GitHub Pages repo"
echo "#################################################"

echo "#################################################"
echo "configure git for GitHub"
echo "Run a command required by GitHub Actions"
git config --global --add safe.directory /github/workspace

echo "#################################################"
echo "configure the default branch name (used to suppress a warning)"
git config --global init.defaultBranch main

echo "#################################################"
echo "Configure required Git username and email"
if [ -z "${GITHUB_ACTOR}" ];
then
GITHUB_ACTOR=$env_github_actor
fi

if [ -z "${GITHUB_TOKEN}" ];
then
GITHUB_TOKEN=$env_github_token
fi

if [ -z "${USER_SITE_REPOSITORY}" ];
then
USER_SITE_REPOSITORY=$env_user_site_repository
fi

USER_NAME="${GITHUB_ACTOR}"
MAIL="${GITHUB_ACTOR}@users.noreply.github.com"

git config --global user.name "${USER_NAME}"
git config --global user.email "${MAIL}"
echo "${USER_NAME} - ${MAIL}"


echo "#################################################"
echo "Finalize Git settings"
git submodule init
git submodule update

echo "#################################################"
echo "allow full access to files and folders"
echo "workspace_directory: $env_workspace_directory"
sh -c "chmod 777 $env_workspace_directory/*"
sh -c "chmod 777 $env_workspace_directory/.*"

echo "#################################################"
echo "Experimental Ruby 3.1 YJIT feature to improve liquid template rendering"
echo "If the setting is not available, it will be skipped"
export RUBYOPT="--enable=yjit"

echo "#################################################"
echo "Install and update bundles"
sh -c "bundle install"
sh -c "bundle update"

echo "#################################################"
echo "Build the Jekyll website, including future posts"
echo "future allows for the generation of upcoming posts,"
echo "guests, and featured images"
sh -c "bundle exec jekyll build --future"

echo "#################################################"
echo "Make the OpenAI Dall-E script executable"
WF_FEATURED_IMAGES_SCRIPT="create-featured-image.sh"
sh -c "chmod +x $WF_FEATURED_IMAGES_SCRIPT"

echo "#################################################"
echo "Run the featured images code"
sh $WF_FEATURED_IMAGES_SCRIPT

echo "#################################################"
echo "Publish all images created by the scripts"
git add featured-images/\*
git status

echo "#################################################"
echo "Commit changes from Jekyll build"
echo "Use --quiet so the commit does not trigger another workflow"
git diff-index --quiet HEAD || echo "Commit changes." && git commit -m 'Jekyll build from Action - add images' && echo "Push." && git push origin
git reset --hard

echo "#################################################"
echo "The site was built once so scripts can create new images"
echo "remove _site so Jekyll can create a clean build a second time"
rm -rf $env_workspace_directory/_site

echo "#################################################"
echo "Add $env_workspace_directory/_site as submodule"
echo "git submodule add -f https://${GITHUB_TOKEN}@github.com/${USER_SITE_REPOSITORY}.git ./_site"
git submodule add -f https://${GITHUB_TOKEN}@github.com/${USER_SITE_REPOSITORY}.git ./_site
cd $env_workspace_directory/_site
git checkout main
git pull

echo "#################################################"
echo "Added submodule"
cd ..
echo "sh -c "chmod 777 $env_workspace_directory/*""
sh -c "chmod 777 $env_workspace_directory/*"
echo "sh -c "chmod 777 $env_workspace_directory/.*""
sh -c "chmod 777 $env_workspace_directory/.*"

echo "#################################################"
echo "The script ran and created new files"
echo "So therefore, rebuild the Jekyll site"
sh -c "bundle exec jekyll build --future"

echo "#################################################"
echo "Second Jekyll build done"

echo "#################################################"
echo "Now publishing to remote repo"
ls -ltar
cd $env_workspace_directory/_site
ls -ltar
git log -2
git remote -v

# Create CNAME file for redirect to this repository
if [[ "${CNAME}" ]]; then
  echo ${CNAME} > CNAME
fi

touch .nojekyll
echo "Add all files."
git add -f -A -v
git status

git diff-index --quiet HEAD || echo "Commit changes." && git commit -m 'Jekyll build from Action' && echo "Push." && git push origin

echo "#################################################"
echo "Published to remote repo"
