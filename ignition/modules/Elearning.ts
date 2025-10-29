import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// This module deploys the CertificateNFT contract
const CertificateNFTModule = buildModule("CertificateNFTModule", (m) => {
    // Parameters for the CertificateNFT constructor
    const name = m.getParameter("name", "Elearning Certificate");
    const symbol = m.getParameter("symbol", "ELC");

    // Deploy the contract
    const certificateNFT = m.contract("CertificateNFT", [name, symbol]);

    return { certificateNFT };
});

// This module deploys the ElearningPlatform and uses the CertificateNFT module
const ElearningPlatformModule = buildModule("ElearningPlatformModule", (m) => {
    // Get the deployed CertificateNFT contract from the other module
    const { certificateNFT } = m.useModule(CertificateNFTModule);

    // Deploy ElearningPlatform, passing the NFT contract's address to its constructor
    const elearningPlatform = m.contract("ElearningPlatform", [
        certificateNFT,
    ]);

    return { elearningPlatform };
});

// Export the main module you want to deploy
export default ElearningPlatformModule;