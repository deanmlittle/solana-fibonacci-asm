import { ComputeBudgetProgram, Connection, Keypair, Transaction, TransactionInstruction, TransactionInstructionCtorFields } from "@solana/web3.js"
const signerSeed = JSON.parse(process.env.SIGNER)
import programSeed from "../deploy/fib_keypair.json"
import { assert } from "chai"
const programKeypair = Keypair.fromSecretKey(new Uint8Array(programSeed))

const program = programKeypair.publicKey

const connection = new Connection("http://127.0.0.1:8899", {
    commitment: "confirmed"
})

const signer = Keypair.fromSecretKey(new Uint8Array(signerSeed))

const confirm = async (signature: string): Promise<string> => {
    const block = await connection.getLatestBlockhash()
    await connection.confirmTransaction({
        signature,
        ...block,
    })
    return signature
}

const getLogs = async (signature: string): Promise<string[]> => {
    const block = await connection.getLatestBlockhash()
    const tx = await connection.getTransaction(
        signature,
        { commitment: "confirmed" }
    )
    console.log(tx.meta.computeUnitsConsumed, "CUs")
    return tx.meta.logMessages
}

const signAndSend = async(tx: Transaction): Promise<string> => {
    const block = await connection.getLatestBlockhash()
    tx.recentBlockhash = block.blockhash
    tx.lastValidBlockHeight = block.lastValidBlockHeight
    const signature = await connection.sendTransaction(tx, [signer])
    return signature
}

const fibTx = (n: number): Transaction => {
    const tx = new Transaction()
    tx.instructions.push(
        ComputeBudgetProgram.setComputeUnitLimit({ units: 908 }),
        new TransactionInstruction({
        keys: [{
            pubkey: signer.publicKey,
            isSigner: true,
            isWritable: true
        }],
        programId: program,
        data: Buffer.from([n&0xff])
    } as TransactionInstructionCtorFields))
    return tx
}

describe('Fibonacci tests', () => {
    it('F(0) = 0', async () => {
        const logs = await signAndSend(fibTx(0)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0x0, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(1) = 1', async () => {
        const logs = await signAndSend(fibTx(1)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0x1, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(2) = 1', async () => {
        const logs = await signAndSend(fibTx(2)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0x1, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(5) = 5', async () => {
        const logs = await signAndSend(fibTx(5)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0x5, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(32) = 2178309', async () => {
        const logs = await signAndSend(fibTx(32)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0x213d05, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(93) = 12200160415121876738', async () => {
        const logs = await signAndSend(fibTx(93)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: 0xa94fad42221f2702, 0x0, 0x0, 0x0, 0x0")
    });

    it('F(94) = fail', async () => {
        const logs = await signAndSend(fibTx(94)).then(confirm).then(getLogs);
        assert.equal(logs[3], "Program log: Sorry, u64 maxes out at F(93) :(")
    });
});