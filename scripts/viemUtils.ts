import {
    createWalletClient,
    createPublicClient,
    http,
    publicActions,
    Chain,
    getContract,
    getAddress, parseAbi,
    // parseAbiParameters
} from 'viem';
import { base, baseSepolia } from 'viem/chains';
import { privateKeyToAccount } from 'viem/accounts';
import dotenv from 'dotenv';
import { getProxyAddressByChainId } from './getProxyAddress';
import {abi} from "./abi";
//import {landAbiHuman} from "./landabi-human";
//import landAbiHumanReadable from '../src/generated/abi-human';

dotenv.config();

// Environment variables
const RPC_URL = process.env.SEPOLIA_RPC_URL; //process.env.RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CHAIN_ID = process.env.CHAIN_ID ? parseInt(process.env.CHAIN_ID) : undefined;

//const landAbi = parseAbiParameters(landAbiHumanReadable);

// Validate environment variables
if (!RPC_URL || !PRIVATE_KEY || !CHAIN_ID) {
    console.error('Please set RPC_URL, PRIVATE_KEY, and CHAIN_ID in your .env file');
    process.exit(1);
}

// Chain configuration
const chain: Chain = (() => {
    switch (CHAIN_ID) {
        case 84532: return baseSepolia;
        case 8453: return base;
        default:
            throw new Error(`Unsupported chain ID: ${CHAIN_ID}. Only Base Sepolia (84532) and Base Mainnet (8453) are supported.`);
    }
})();

// Account and client setup
const account = privateKeyToAccount(`0x${PRIVATE_KEY}`);

export const walletClient = createWalletClient({
    account,
    chain,
    transport: http(RPC_URL),
}).extend(publicActions);

export const publicClient = createPublicClient({
    chain,
    transport: http(RPC_URL),
});

// Land contract setup
export const LAND_CONTRACT_ADDRESS = getAddress(getProxyAddressByChainId(chain.id));

export const landContract = getContract({
    address: LAND_CONTRACT_ADDRESS,
    abi: abi,
    client: walletClient,
});

// Exports
export { RPC_URL, PRIVATE_KEY, CHAIN_ID, chain };