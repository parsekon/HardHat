import { HardhatRuntimeEnvironment } from "hardhat/types";

const func = (HardhatRuntimeEnvironment) => {
    const { deployments, getNamedAccount } = hre;

    const { deploy } = deployments;

    const { deployer } = await getNamedAccounts();

    const governToken = await deploy("GovernToken", {
        from: deployer,
        log: true
    });

    await delegate(hre, governToken.address, deployer);
}

const delegate = async(
    HardhatRuntimeEnvironment, 
    governTokenAddress, 
    delegatedAccount) => {
        const governToken = GovernToken__factory.connect(
            governTokenAddress,
            hrt.ethers.provider.getSigner(0)
        )

        const tx = await governToken.delegate(delegatedAccount);
        await tx.await();

        console.log(`Checkpoints ${await governToken.numCheckpoints(delegatedAccount)}`);
    }


export default func;