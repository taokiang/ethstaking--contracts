import "@nomicfoundation/hardhat-ethers";
import { ethers } from "hardhat";

async function deploy() {
    const StakingRewards = await ethers.getContractFactory("StakingRewards");
    const stakingRewards = await StakingRewards.deploy();
    await stakingRewards.deployed();

    return stakingRewards;
}

// @ts-ignore
async function deployCallback(stakingRewards) {
    console.log("Say Hello:", await stakingRewards.hello());
}

deploy().then(deployCallback);