// Type declarations for Hardhat Runtime Environment
import "hardhat/types/runtime";
import type { HardhatEthersHelpers } from "@nomicfoundation/hardhat-ethers/types";

declare module "hardhat/types/runtime" {
    interface HardhatRuntimeEnvironment {
        ethers: HardhatEthersHelpers;
    }
}

// Re-export ethers from hardhat for named import compatibility
declare module "hardhat" {
    export const ethers: HardhatEthersHelpers;
}
