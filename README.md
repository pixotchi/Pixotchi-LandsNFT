# Pixotchi Land Contract Suite

Pixotchi Land brings onchain property ownership to the Pixotchi ecosystem.  
This package contains the upgradeable smart contracts that power land minting, management, and the supporting game loops that run on Base Mainnet.

<p align="center">
  <img src="https://mini.pixotchi.tech/ecologo.png" alt="Pixotchi Logo" width="160">
</p>

<!-- Badges -->
[![Network](https://img.shields.io/badge/Base-Mainnet-0052FF?logo=coinbase&logoColor=white&style=flat-square)](https://basescan.org/address/0x3f1F8F0C4BE4bCeB45E6597AFe0dE861B8c3278c)
[![Diamond Standard](https://img.shields.io/badge/Standard-Diamond%20%28EIP--2535%29-6f3aff?style=flat-square)](https://eips.ethereum.org/EIPS/eip-2535)
[![Audit Friendly](https://img.shields.io/badge/Storage-Library--Backed-38B2AC?style=flat-square)](#storage-layout)
[![License](https://img.shields.io/badge/License-MIT-000?style=flat-square)](LICENSE.md)

---

## Contract Registry (Base Mainnet)

| Module | Address | Notes |
| ------ | ------- | ----- |
| **Land Diamond** | `0x3f1F8F0C4BE4bCeB45E6597AFe0dE861B8c3278c` | ERC‑721A land token & game logic |
| **LandToPlant (warehouse target)** | `0xeb4e16c804AE9275a655AbBc20cD0658A91F9235` | Plant contract referenced by warehouse facet |
| **SEED Token** | `0x546D239032b24eCEEE0cb05c92FC39090846adc7` | ERC‑20 payment token |
| **LEAF Token** | `0xE78ee52349D7b031E2A6633E07c037C3147DB116` | ERC‑20 reward token |

The diamond exposes multiple facets (AccessControl, NFT, Town, Village, Warehouse, Marketplace, Quest, etc.) that can be upgraded independently.

---

## Core Capabilities

- **Gas-efficient minting** – ERC721A-based NFT facet with spiral coordinate assignment.
- **Upgradeable gameplay** – Diamond architecture with dedicated storage libraries per subsystem.
- **Dynamic economy** – Payment, reward, marketplace, quest, town, and village modules that manage onchain progression.
- **Admin controls** – Pause, whitelist, mint activation, and (new) mint price management via `AccessControlFacet`.
- **Warehouse operations** – Convert accumulated land resources into plant-level stats through the warehouse facet.

---

## Land Minting

- **Default mint price**: `100 SEED` (configurable).
- **Coordinate range**: `[-112, 112]` on both X and Y axes.
- **Supply**: Capped at 20,000 lands (configurable in storage).
- **Avatar assignment**: Each land receives a deterministic farmer avatar stored on mint.

To mint, the `NFTFacet` reads `LibMintControl.getMintPrice()` and charges SEED via the payment library.

### Mint Price Management

1. Ensure `mintControl(true)` has been called to enable minting.
2. Use the admin-only setter (added in this revision):
   ```
   AccessControlFacet.mintControlSetPrice(uint256 newPriceInWei)
   ```
   Example – set to `300 SEED`:
   ```
   mintControlSetPrice(300000000000000000000)
   ```

---

## Storage Layout

Each subsystem writes to an isolated diamond storage library (e.g. `LibLandStorage`, `LibMintControlStorage`, `LibVillageStorage`).  
This pattern eliminates storage collisions and makes upgrades straightforward.

When adding functionality:

1. Extend the relevant `Lib*Storage` struct with new fields.
2. Append new fields to the end of structs only—never reorder existing members.
3. Gate mutations through facets with the `isAdmin` modifier where appropriate.

---

## Working With the Diamond

### Local Development

```bash
pnpm install
forge install mudgen/diamond-2-hardhat --no-commit   # already included, run if missing
pnpm build
forge test
```

Spin up a local node and deploy:

```bash
pnpm devnet     # start local chain
pnpm dep local  # uses Gemforge scripts for deployment
```

### Upgrading a Facet

1. Write and compile the facet (`forge build` or Remix).
2. Deploy the new facet code with your preferred tool.
3. Execute a `diamondCut` transaction that:
   - Replaces the old facet address with the new one.
   - Adds/removes any function selectors.
4. (Optional) verify the facet on Basescan.

Tools such as [Louper](https://louper.dev) streamline step 3 with a guided UI.

---

## File Map

- `src/facets/` – Entry points exposed on the diamond (AccessControl, NFT, Town, Village, Quest, etc.).
- `src/libs/` – Shared logic and storage libraries.
- `src/init/InitDiamond.sol` – Initializes storage, facets, and ERC-721 metadata.
- `scripts/` & `script/` – Deployment and maintenance helpers (Foundry/Gemforge).
- `test/` – Foundry tests covering minting, quests, town/village flows, and storage utilities.

---

## Development Notes

- **Payments** – `LibPayment` auto-detects network to route SEED/LEAF transfers and can burn tokens when configured with a zero receive address.
- **Marketplace** – Facet gated behind `Town` level requirements; trades perform custodial swaps with XP rewards.
- **Warehouse** – Bridges land resource tallies (`LibLand._decreaseAccumulated*`) with the off-chain plant contract.
- **Quest System** – Multi-step flow (start → commit → finalize) with reward multipliers based on quest house level.

---

## Contributing

1. Fork / clone the repo.
2. Run the full test suite (`forge test`).
3. Submit PRs with clear descriptions and include gas-impact notes for contract changes.

Security issues?  
Please disclose responsibly via a minimal report (do not open public issues containing exploits).

---

## License

MIT – see [LICENSE.md](LICENSE.md)

Built with ❤️ for the Pixotchi community and landowners.
