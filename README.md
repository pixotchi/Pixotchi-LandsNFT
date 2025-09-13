# Pixotchi LAND - Expanding the Pixotchi Ecosystem

This project introduces LAND, a new NFT (ERC721A) component to the Pixotchi ecosystem, extending the beloved Pixotchi v2 game. Pixotchi LAND leverages the diamond pattern for upgradeable smart contracts and uses [Gemforge](https://gemforge.xyz) with [Foundry](https://github.com/foundry-rs/foundry) for development and deployment.

## Pixotchi Ecosystem Overview

Pixotchi LAND is built on the ERC721A standard, allowing for gas-efficient minting of multiple NFTs in a single transaction. While SEED remains the main token of the Pixotchi universe, LAND introduces a new dimension to the Pixotchi gameplay experience.

Key features of the Pixotchi LAND contract:

- Seamlessly integrates with the existing Pixotchi ecosystem
- Utilizes the diamond pattern for upgradeability within the Pixotchi infrastructure
- Implements ERC721A for efficient minting of Pixotchi LAND parcels
- Assigns unique coordinates to each minted Pixotchi LAND NFT
- Manages a maximum supply of 10,000 Pixotchi LANDs
- Coordinates range from -50 to 50 on both X and Y axes within the Pixotchi world

## Pixotchi LAND Smart Contract Structure

The project consists of two main components enhancing the Pixotchi ecosystem:

1. `NFTFacet.sol`: Implements the core Pixotchi LAND NFT functionality
   - Minting of Pixotchi LAND tokens
   - Coordinate assignment for each Pixotchi LAND parcel
   - Utilizes ERC721AUpgradeable for gas-efficient operations

2. `LibNFTStorage.sol`: Manages the storage for the Pixotchi LAND contract
   - Defines the structure for storing Pixotchi LAND data and coordinates
   - Implements initialization and storage access functions for the Pixotchi ecosystem

## Development and Deployment

This project uses Gemforge for streamlined development and deployment:

- Build and deploy commands are pre-configured
- Includes a pre-configured config file
- Features a post-deploy hook for Etherscan verification

## Requirements

* [Node.js 20+](https://nodejs.org)
* [PNPM](https://pnpm.io/) _(NOTE: `yarn` and `npm` can also be used)_
* [Foundry](https://github.com/foundry-rs/foundry/blob/master/README.md)

## Installation

In an empty folder:

```
npx gemforge scaffold
```

Change into the folder and run in order:

```
$ foundryup  # On OS X you may first need to run: brew install libusb
$ pnpm i
$ git submodule update --init --recursive
```

Create `.env` and set the following within:

```
LOCAL_RPC_URL=http://localhost:8545
SEPOLIA_RPC_URL=<your infura/alchemy endpoint for spolia>
ETHERSCAN_API_KEY=<your etherscan api key>
MNEMONIC=<your deployment wallet mnemonic>
```

## Usage

Run a local dev node in a separate terminal:

```
pnpm devnet
```

To build the code:

```
$ pnpm build
```

To run the tests:

```
$ pnpm test
```

To deploy to the local target:

```
$ pnpm dep local
```

To deploy to the testnet target (sepolia):

```
$ pnpm dep testnet
```

For verbose output simply add `-v`:

```
$ pnpm build -v
$ pnpm dep -v
```

## Features, Roadmap, and TODOs for Pixotchi LAND

### Core Functionality
- [X] Implement ERC721A for gas-efficient Pixotchi LAND NFT minting
- [X] Utilize diamond pattern for upgradeable Pixotchi LAND contracts
- [X] Assign unique coordinates to each Pixotchi LAND token
- [X] Implement quadrant-based minting in a spiral pattern for Pixotchi LAND
- [X] Enforce maximum supply of 10,000 Pixotchi LAND tokens
- [X] Set coordinate bounds from -50 to 50 on both X and Y axes in the Pixotchi world
- [X] Develop efficient storage management using LibNFTStorage for Pixotchi LAND
- [X] Create version-based initialization system for Pixotchi LAND
- [X] Implement coordinate occupation tracking in the Pixotchi ecosystem
- [X] Develop clamp function for Pixotchi LAND coordinate boundaries
- [X] Enable batch minting of multiple Pixotchi LAND tokens
- [X] Integrate Pixotchi LAND with existing Pixotchi v2 game ecosystem

### Short-term Goals for Pixotchi LAND

#### Migration from ERC-7504 Draft Implementation
- [ ] Migrate upgradable building functionality to Pixotchi LAND
- [ ] Implement airdrop logic for early Pixotchi adopters and community rewards

#### New Features for Pixotchi LAND
- [ ] Develop marketplace functionality for Pixotchi LAND token trading
- [ ] Implement naming logic for Pixotchi LAND tokens
- [ ] Create pricing logic with currency-based pricing via oracle for Pixotchi LAND
- [ ] Design and implement quest logic within the Pixotchi ecosystem
  - [ ] Incorporate on-chain random value reading without external oracle
- [ ] Integrate non-tradable LEAF token into Pixotchi LAND ecosystem

### Medium-term Goals for Pixotchi Ecosystem

- [ ] Implement Pixotchi LAND staking mechanism for passive rewards
- [ ] Develop inter-LAND interactions and shared boundaries logic in Pixotchi world
- [ ] Create governance system for Pixotchi LAND owners
- [ ] Design and implement resource generation on Pixotchi LAND parcels
- [ ] Develop crafting system utilizing Pixotchi LAND resources and LEAF tokens

### Long-term Vision for Pixotchi

- [ ] Create fully decentralized virtual world built on Pixotchi LAND tokens
- [ ] Implement cross-chain compatibility for broader Pixotchi ecosystem integration
- [ ] Establish partnerships for third-party development on Pixotchi LAND platform

### Ongoing Development of Pixotchi Ecosystem
- [ ] Continuous refinement of Pixotchi LAND smart contract architecture
- [ ] Regular security audits and optimizations for Pixotchi ecosystem
- [ ] Pixotchi community feedback integration and feature prioritization
- [ ] Performance optimization for gas-efficient operations in Pixotchi LAND
- [ ] Expansion of Pixotchi documentation and developer resources

## Current Pixotchi LAND Project Status

The Pixotchi LAND project has made significant progress, with core NFT functionality and unique coordinate-based features already implemented within the Pixotchi ecosystem. We are now focusing on migrating additional features from the ERC-7504 draft and developing new functionalities to enhance the Pixotchi universe.

Key areas of ongoing work in the Pixotchi ecosystem include:
1. Finalizing the upgradable building system for dynamic Pixotchi LAND development
2. Implementing a fair and efficient airdrop mechanism to reward early Pixotchi adopters
3. Designing a robust marketplace for seamless Pixotchi LAND token trading
4. Developing an intuitive naming system for Pixotchi LAND parcels
5. Creating a dynamic pricing system that reflects real-world currency values for Pixotchi LAND
6. Implementing an engaging quest system with on-chain randomness in the Pixotchi world
7. Expanding the Pixotchi ecosystem with staking, resource generation, and crafting mechanics
8. Integrating the non-tradable LEAF token into the Pixotchi LAND ecosystem

We welcome community contributions and feedback as we continue to expand and improve the Pixotchi LAND project within the broader Pixotchi universe. Our goal is to create a rich, interactive, and decentralized virtual world that offers unique opportunities for creativity, ownership, and economic activity in the Pixotchi ecosystem.

## License

MIT - see [LICSENSE.md](LICENSE.md)