import fs from 'fs';
import path from 'path';

interface DeploymentData {
  [network: string]: {
    chainId: number;
    contracts: Array<{
      name: string;
      onChain: {
        address: string;
      };
    }>;
  };
}

function getDeploymentData(): DeploymentData {
  const filePath = path.join(__dirname, '..', 'gemforge.deployments.json');
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

function getProxyAddressByNetwork(network: string): string {
  const deploymentData = getDeploymentData();

  if (!deploymentData[network]) {
    throw new Error(`Network "${network}" not found in deployment data`);
  }

  const proxyContract = deploymentData[network].contracts.find(
    (contract) => contract.name === 'DiamondProxy'
  );

  if (!proxyContract) {
    throw new Error(`DiamondProxy contract not found for network "${network}"`);
  }

  return proxyContract.onChain.address;
}

function getProxyAddressByChainId(chainId: number): string {
  const deploymentData = getDeploymentData();

  const network = Object.keys(deploymentData).find(
    (net) => deploymentData[net].chainId === chainId
  );

  if (!network) {
    throw new Error(`Network with chainId ${chainId} not found in deployment data`);
  }

  const proxyContract = deploymentData[network].contracts.find(
    (contract) => contract.name === 'DiamondProxy'
  );

  if (!proxyContract) {
    throw new Error(`DiamondProxy contract not found for chainId ${chainId}`);
  }

  return proxyContract.onChain.address;
}

// Example usage
try {
  const testnetProxyAddress = getProxyAddressByNetwork('testnet');
  console.log('Testnet Proxy Address (by network):', testnetProxyAddress);

  const chainIdProxyAddress = getProxyAddressByChainId(84532);
  console.log('Proxy Address (by chainId):', chainIdProxyAddress);
} catch (error) {
  console.error('Error:', (error as Error).message);
}

export { getProxyAddressByNetwork, getProxyAddressByChainId };