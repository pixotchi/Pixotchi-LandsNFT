import { parseEventLogs, ContractFunctionExecutionError } from 'viem';
import { publicClient } from './viemUtils';

// Generic function to execute a contract write and log results
export async function executeContractWrite<
    TContract extends { simulate: any; write: any; abi: any },
    TFunctionName extends keyof TContract['write'] & keyof TContract['simulate']
>(
    contract: TContract,
    functionName: TFunctionName,
    args: Parameters<TContract['write'][TFunctionName]>[0]
): Promise<void> {
    try {
        const simulate = true;
        let hash;
        if (simulate) {
            const { request } = await contract.simulate[functionName](args);
            if (!request) throw new Error('Simulation failed');
            hash = await contract.write[functionName](args, request);
        } else {
            hash = await contract.write[functionName](args);
        }

        console.log('Transaction hash:', hash);

        console.log('Waiting for transaction to be mined...');
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        console.log('Transaction receipt status:', receipt.status);

        // Parse and log all events
        const logs = parseEventLogs({
            abi: contract.abi,
            logs: receipt.logs
        });
        console.log('Event logs:');
        logs.forEach(log => {
            //@ts-ignore
            console.log(`- Event: ${log.eventName}`);
            //@ts-ignore
            console.log(`  Arguments:`, log.args);
        });
    } catch (error) {
        if (error instanceof ContractFunctionExecutionError) {
            console.error('Contract execution error:', error.message);
        } else {
            console.error('An error occurred:', error);
        }
    }
}