import { createInterface } from 'readline/promises';
import { executeContractWrite } from "./viem-generics";
import {landContract, publicClient} from './viemUtils';
import {getContract} from "viem";
import {abi} from "./abi";


// Specific function for minting land
async function mint(/*quantity: bigint*/): Promise<void> {
    await executeContractWrite(landContract, 'mint', /*[quantity]*/ {} );
}

async function getLandCoordinates(fromTokenId: bigint, toTokenId: bigint): Promise<void> {
    const contract = getContract({
        address: landContract.address,
        abi: abi,
        client: publicClient
    });

    for (let tokenId = fromTokenId; tokenId <= toTokenId; tokenId++) {
        try {
            const [x, y] = await landContract.read.landGetCoordinates([tokenId]);
            //const [x, y] = await contract.read.nftGetLandCoordinates([tokenId]);
            console.log(`Token ID ${tokenId}: (x: ${x}, y: ${y})`);
        } catch (error) {
            console.error(`Error getting coordinates for Token ID ${tokenId}:`, error);
        }
    }
}

// Renamed function
async function initNFTFacet(): Promise<void> {
    await executeContractWrite(landContract, 'initNFTFacet', {} as const);
}

// New function for initFacet
async function initFacet(): Promise<void> {
    //await executeContractWrite(landContract, 'initFacet', {} as const);
    //throw new Error("Not implemented");
}

async function landGetBoundaries(): Promise<void> {
    const [minX, maxX, minY, maxY] = await landContract.read.landGetBoundaries();
    console.log(`Boundaries: minX: ${minX}, maxX: ${maxX}, minY: ${minY}, maxY: ${maxY}`);
}

async function landGetCoordinates(tokenId: bigint): Promise<void> {
    const [x, y, occupied] = await landContract.read.landGetCoordinates([tokenId]);
    console.log(`Token ID ${tokenId}: x: ${x}, y: ${y}, occupied: ${occupied}`);
}

async function landGetDiamondInitialized(): Promise<void> {
    //const initialized = await landContract.read.landGetDiamondInitialized();
    //console.log(`Diamond initialized: ${initialized}`);
}

async function landGetMaxSupply(): Promise<void> {
    const maxSupply = await landContract.read.maxSupply();
    console.log(`Max supply: ${maxSupply}`);
}

async function landGetTokenIdByCoordinates(x: bigint, y: bigint): Promise<void> {
    const tokenId = await landContract.read.landGetTokenIdByCoordinates([x, y]);
    console.log(`Token ID for coordinates (${x}, ${y}): ${tokenId}`);
}

async function getOwner(): Promise<void> {
    const owner = await landContract.read.owner();
    console.log(`Contract owner: ${owner}`);
}

async function supportsInterface(interfaceId: `0x${string}`): Promise<void> {
    const supported = await landContract.read.supportsInterface([interfaceId]);
    console.log(`Interface ${interfaceId} supported: ${supported}`);
}

async function landGetInitializationNumber(): Promise<void> {
    //const initNumber = await landContract.read.landGetInitializationNumber();
    //console.log(`Initialization number: ${initNumber}`);
}

async function main(): Promise<void> {
    const rl = createInterface({
        input: process.stdin,
        output: process.stdout
    });

    while (true) {
        console.log("\nWhat would you like to do?");
        console.log("1. Mint land");
        console.log("2. Get Land Coordinates");
        console.log("3. Initialize NFT Facet (ERC721)");
        console.log("4. Initialize Facet");
        console.log("5. Get Land Boundaries");
        console.log("6. Get Coordinates for Token ID");
        console.log("7. Check Diamond Initialization");
        console.log("8. Get Max Supply");
        console.log("9. Get Token ID by Coordinates");
        console.log("10. Get Contract Owner");
        console.log("11. Check Interface Support");
        console.log("12. Get Initialization Number");
        console.log("13. Exit");

        const action = await rl.question("Enter your choice (1-13): ");

        switch (action) {
            case '1':
                //const quantityInput = await rl.question("Enter quantity to mint (default is 1): ");
                //const quantity = quantityInput ? BigInt(quantityInput) : BigInt(1);
                await mint();
                break;
            case '2':
                const rangeInput = await rl.question("Enter token ID range (e.g., 0-999): ");
                const [fromStr, toStr] = rangeInput.split('-').map(s => s.trim());
                const fromTokenId = BigInt(fromStr);
                const toTokenId = BigInt(toStr);
                await getLandCoordinates(fromTokenId, toTokenId);
                break;
            case '3':
                await initNFTFacet();
                //console.log("NFT Facet initialization completed.");
                break;
            case '4':
                await initFacet();
                //console.log("Facet initialization completed.");
                break;
            case '5':
                await landGetBoundaries();
                break;
            case '6':
                const tokenIdInput = await rl.question("Enter token ID: ");
                await landGetCoordinates(BigInt(tokenIdInput));
                break;
            case '7':
                await landGetDiamondInitialized();
                break;
            case '8':
                await landGetMaxSupply();
                break;
            case '9':
                const xInput = await rl.question("Enter x coordinate: ");
                const yInput = await rl.question("Enter y coordinate: ");
                await landGetTokenIdByCoordinates(BigInt(xInput), BigInt(yInput));
                break;
            case '10':
                await getOwner();
                break;
            case '11':
                const interfaceIdInput = await rl.question("Enter interface ID (as hex string): ");
                await supportsInterface(interfaceIdInput as `0x${string}`);
                break;
            case '12':
                await landGetInitializationNumber();
                break;
            case '13':
                console.log("Exiting CLI...");
                rl.close();
                return;
            default:
                console.log("Invalid choice. Please try again.");
        }
    }
}

main().catch((error) => {
    console.error("An error occurred:", error);
    process.exit(1);
});