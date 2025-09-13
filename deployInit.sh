#!/bin/bash

# Source the .env file to load the environment variables
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

# Run the forge create command with the environment variables
forge create src/init/InitDiamond.sol:InitDiamond --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY --verify  --etherscan-api-key $ETHERSCAN_API_KEY