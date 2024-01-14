#!/bin/bash

Update packages
sudo apt update

Install Docker
sudo apt install docker.io

Get BEVM testnet node image
sudo docker pull btclayer2/bevm:v0.1.1

Run node (you can name the node whatever you like)
read -p "Enter node name: " node_name
sudo docker run -d btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
