// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title Hợp đồng NFT chứng chỉ khóa học (OpenZeppelin Contracts v5.x)
/// @notice Phát hành NFT chứng chỉ, quản lý bằng vai trò MINTER_ROLE, lưu metadata và dữ liệu chứng chỉ
contract CertificateNFT is ERC721, ERC721URIStorage, AccessControl {
    using EnumerableSet for EnumerableSet.UintSet;

    // Vai trò cho phép mint chứng chỉ
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Cấu trúc lưu thông tin chứng chỉ
    struct Certificate {
        string courseName;
        string studentName;
        string issueDate;
    }

    // Lưu trữ dữ liệu chứng chỉ theo tokenId
    mapping(uint256 => Certificate) private _certificateData;
    // Lưu trữ tập tokenIds theo địa chỉ chủ sở hữu
    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    /// @notice Hàm khởi tạo đặt tên, ký hiệu cho token và gán quyền
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        // Gán quyền quản trị (admin) cho deployer, đồng thời làm minter ban đầu
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /// @notice Mint một token mới cho `to` cùng metadata URI và dữ liệu chứng chỉ
    /// @param to Địa chỉ nhận token
    /// @param tokenId ID của token mới
    /// @param uri Metadata URI của token
    /// @param course Tên khóa học trên chứng chỉ
    /// @param student Tên học viên trên chứng chỉ
    /// @param date Ngày cấp chứng chỉ
    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri,
        string memory course,
        string memory student,
        string memory date
    ) external onlyRole(MINTER_ROLE) {
        // Tạo token NFT
        _safeMint(to, tokenId);
        // Gán URI cho token (metadata)
        _setTokenURI(tokenId, uri);
        // Lưu thông tin chứng chỉ
        _certificateData[tokenId] = Certificate(course, student, date);
    }

    /// @notice Lấy danh sách token ID của địa chỉ `owner`
    /// @param owner Địa chỉ cần truy vấn
    /// @return Danh sách token IDs mà `owner` sở hữu
    function getCertificatesOf(address owner) external view returns (uint256[] memory) {
        return _holderTokens[owner].values();
    }

    /// @notice Lấy dữ liệu chứng chỉ cho một tokenId cụ thể
    /// @param tokenId ID của token
    /// @return courseName Tên khóa học, studentName Tên học viên, issueDate Ngày cấp
    function getCertificate(uint256 tokenId) external view returns (string memory courseName, string memory studentName, string memory issueDate) {
        Certificate storage cert = _certificateData[tokenId];
        return (cert.courseName, cert.studentName, cert.issueDate);
    }

    /// @dev Override _beforeTokenTransfer để cập nhật EnumerableSet khi transfer hoặc mint/burn
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize == 1) {
            uint256 tokenId = firstTokenId;
            if (from != address(0)) {
                _holderTokens[from].remove(tokenId);
            }
            if (to != address(0)) {
                _holderTokens[to].add(tokenId);
            }
        }
    }

    /// @dev Override _burn để xoá cả metadata và dữ liệu chứng chỉ
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        // Xóa dữ liệu chứng chỉ khi burn token
        delete _certificateData[tokenId];
    }

    /// @dev Override tokenURI cần cho ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /// @dev Override supportsInterface để hỗ trợ cả ERC721 và AccessControl
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage ,AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
