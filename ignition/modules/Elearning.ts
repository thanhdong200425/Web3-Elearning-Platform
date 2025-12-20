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
  const elearningPlatform = m.contract("ElearningPlatform", [certificateNFT]);

  // Grant MINTER_ROLE to ElearningPlatform so it can mint certificates
  const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"; // keccak256("MINTER_ROLE")
  m.call(certificateNFT, "grantRole", [MINTER_ROLE, elearningPlatform]);

  return { elearningPlatform, certificateNFT };
});

// Export the main module you want to deploy
export default ElearningPlatformModule;
