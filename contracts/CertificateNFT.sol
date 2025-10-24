// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title Hợp đồng NFT chứng chỉ khóa học 
/// @notice Phát hành NFT chứng chỉ, quản lý bằng vai trò MINTER_ROLE, lưu metadata và dữ liệu chứng chỉ
contract CertificateNFT is ERC721, AccessControl {
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Certificate {
        string courseName;
        string studentName;
        string issueDate;
    }

    // mapping dữ liệu chứng chỉ và URI riêng cho từng token
    mapping(uint256 => Certificate) private _certificateData;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    ///  Mint chứng chỉ mới
    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri,
        string memory course,
        string memory student,
        string memory date
    ) external onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _certificateData[tokenId] = Certificate(course, student, date);
    }

    // Lưu URI riêng cho từng token
    function _setTokenURI(uint256 tokenId, string memory uri) internal virtual {
        require(_ownerOf(tokenId) != address(0), "URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    // Trả về URI của token
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireOwned(tokenId);
        string memory uri = _tokenURIs[tokenId];
        return bytes(uri).length > 0 ? uri : "";
    }

    // Hook cập nhật danh sách holderTokens 
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);

        if (from != address(0)) {
            _holderTokens[from].remove(tokenId);
        }
        if (to != address(0)) {
            _holderTokens[to].add(tokenId);
        }

        return super._update(to, tokenId, auth);
    }

    /// Xoá dữ liệu chứng chỉ và URI khi burn
    function _burn(uint256 tokenId)
        internal
        virtual
        override
    {
        super._burn(tokenId);
        delete _certificateData[tokenId];
        delete _tokenURIs[tokenId];
    }

    /// Lấy toàn bộ chứng chỉ của một địa chỉ
    function getCertificatesOf(address owner)
        external
        view
        returns (uint256[] memory)
    {
        return _holderTokens[owner].values();
    }

    /// Truy xuất thông tin chứng chỉ
    function getCertificate(uint256 tokenId)
        external
        view
        returns (string memory courseName, string memory studentName, string memory issueDate)
    {
        Certificate storage cert = _certificateData[tokenId];
        return (cert.courseName, cert.studentName, cert.issueDate);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
