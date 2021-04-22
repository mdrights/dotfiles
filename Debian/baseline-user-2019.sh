#!/bin/sh
# Use it under a normal user.

set -eu

SELF=$(dirname $0)
mkdir -p ~/bin ~/repo ~/tmp ~/src


# Download my bots
cd ~/repo/
git clone https://github.com/mdrights/Myscripts
git clone https://github.com/mdrights/csobot
git clone https://github.com/matrix-org/matrix-python-sdk
git clone https://github.com/mdrights/tiny-matrix-bot

cd tiny-matrix-bot/
ln -sf ../matrix-python-sdk/matrix_client
cd -

cd csobot/matrix-bot
ln -sf ../../matrix-python-sdk/matrix_client
cd -

cp Myscripts/dotfiles/bashrc ~/.bashrc

# Make a startup script for my bot.
echo "#!/bin/sh
 
 $HOME/repo/tiny-matrix-bot/tiny-matrix-bot.py &
 
" > ~/bin/run-tiny-matrix.sh

echo "#!/bin/sh
 
 $HOME/repo/csobot/matrix-bot/csobot-matrix.py &
 
" > ~/bin/run-csobot.sh

# Download and install ipfs.
# Use sudo to run this:
sudo $SELF/install-ipfs.sh


exit
