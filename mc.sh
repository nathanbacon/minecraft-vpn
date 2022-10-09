#!/bin/bash

sudo ufw allow 19132/udp
curl -O https://minecraft.azureedge.net/bin-linux/bedrock-server-1.19.31.01.zip
sudo apt-get install unzip
sudo unzip bedrock-server-1.19.31.01.zip -d server

echo "[Unit]" >> temp
echo "[Service]" >> temp
echo "Type=forking" >> temp
echo "User=azureuser" >> temp
echo "ExecStart=/home/azureuser/start.sh" >> temp
echo "[Install]" >> temp
echo "WantedBy=multi-user.target" >> temp
mv temp /lib/systemd/system/minecraft.service

echo "#!/bin/bash" >> temp
echo "SESSIONNAME=\"minecraft\"" >> temp
echo "tmux has-session -t \$SESSIONNAME &> /dev/null" >> temp
echo "if [ \$? != 0 ]" >> temp
echo "  then" >> temp
echo "    tmux new-session -s \$SESSIONNAME -n script -d" >> temp
echo "    tmux send-keys -t \$SESSIONNAME \"cd /home/azureuser/server && ./start.sh\" C-m" >> temp
echo "fi" >> temp
mv temp ~/server/start.sh
sudo chmod +x ~/server/start.sh

sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service
