#!/bin/bash
sudo apt update
sudo apt upgrade -y

MINECRAFT_FILE=bedrock-server-1.19.31.01.zip
sudo ufw allow 19132/udp
curl -O https://minecraft.azureedge.net/bin-linux/$MINECRAFT_FILE
sudo apt install unzip
unzip $MINECRAFT_FILE -d server
sudo rm $MINECRAFT_FILE

echo "[Unit]" >> temp
echo "[Service]" >> temp
echo "Type=forking" >> temp
echo "User=ngelman" >> temp
echo "ExecStart=/home/ngelman/start.sh" >> temp
echo "[Install]" >> temp
echo "WantedBy=multi-user.target" >> temp
sudo mv temp /lib/systemd/system/minecraft.service

echo "#!/bin/bash" >> temp
echo "SESSIONNAME=\"minecraft\"" >> temp
echo "tmux has-session -t \$SESSIONNAME &> /dev/null" >> temp
echo "if [ \$? != 0 ]" >> temp
echo "  then" >> temp
echo "    tmux new-session -s \$SESSIONNAME -n script -d" >> temp
echo "    tmux send-keys -t \$SESSIONNAME \"cd /home/ngelman/server && ./start.sh\" C-m" >> temp
echo "fi" >> temp
sudo mv temp ~/start.sh
sudo chmod +x ~/start.sh

echo "#!/bin/bash" >> temp
echo "LD_LIBRARY_PATH=. ./bedrock_server" >> temp
mv temp ~/server/start.sh
sudo chmod +x ~/server/start.sh

sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service
