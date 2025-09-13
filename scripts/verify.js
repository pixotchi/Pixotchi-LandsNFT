#!/usr/bin/env node
(async () => {
  require('dotenv').config()
  const { $ } = (await import('execa'))

  const deploymentInfo = require('../gemforge.deployments.json')

  const target = process.env.GEMFORGE_DEPLOY_TARGET
  if (!target) {
    throw new Error('GEMFORGE_DEPLOY_TARGET env var not set')
  }

  const etherscanApiKey = process.env.ETHERSCAN_API_KEY
  if (!etherscanApiKey) {
    throw new Error('ETHERSCAN_API_KEY env var is not set or empty')
  }

  const blockscoutApiUrl = process.env.BLOCKSCOUT_API_URL
  if (!blockscoutApiUrl) {
    throw new Error('BLOCKSCOUT_API_URL env var is not set or empty')
  }

  // Toggles for Etherscan and Blockscout verification
  const useEtherscan = true
  const useBlockscout = false

  // skip localhost
  if (target === 'local') {
    console.log('Skipping verification on local')
    return
  }

  console.log(`Verifying for target ${target} ...`)

  const contracts = (deploymentInfo[target] || {}).contracts || []

  for (let { name, onChain } of contracts) {
    let args = '0x'

    if (onChain.constructorArgs.length) {
      args = (await $`cast abi-encode constructor(address) ${onChain.constructorArgs.join(' ')}`).stdout
    }

    console.log(`Verifying ${name} at ${onChain.address} with args ${args}`)

    if (useEtherscan) {
      console.log('Verifying on Etherscan...')
      try {
        await $`forge verify-contract ${onChain.address} ${name} --constructor-args ${args} --chain-id ${deploymentInfo[target].chainId} --verifier etherscan --etherscan-api-key ${etherscanApiKey} --watch`
        console.log('Etherscan verification successful!')
      } catch (error) {
        console.error('Etherscan verification failed:', error)
      }
    }

    if (useBlockscout) {
      console.log('Verifying on Blockscout...')
      try {
        await $`forge verify-contract ${onChain.address} ${name} --constructor-args ${args} --chain-id ${deploymentInfo[target].chainId} --verifier blockscout --verifier-url ${blockscoutApiUrl}/api/ --watch`
        console.log('Blockscout verification successful!')
      } catch (error) {
        console.error('Blockscout verification failed:', error)
      }
    }

    console.log(`Verification process completed for ${name}`)
  }
})()