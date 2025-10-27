// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICertificateNFT {
    function safeMint(
        address to,
        string memory tokenURI_
    ) external returns (uint256 tokenId);
}

contract ElearningPlatform {
    ICertificateNFT public certificateNFT;

    struct Course {
        address instructor;
        uint256 price;
        string courseId;
        bool exists;
    }

    uint256 public nextCourseId;

    // Create a key (uint256) and value (Course) to track courses
    mapping(uint256 => Course) public courses;

    // Track which students are enrolled in which courses
    mapping(uint256 => mapping(address => bool)) public enrolled;

    // Create an event for course registration (an event is a log that can be listened to off-chain) to notify external systems (React app) when a new course is registered
    event CourseRegistered(
        uint256 indexed courseId,
        address indexed instructor,
        uint256 price,
        string courseCID
    );
    event Enrolled(
        uint256 indexed courseId,
        address indexed student,
        uint256 amountPaid
    );
    event CertificateIssued(
        uint256 indexed courseId,
        address indexed student,
        uint256 tokenId,
        string certCID
    );

    constructor(address certificateNFTAddress) {
        require(certificateNFTAddress != address(0), "Invalid NFT address");
        certificateNFT = ICertificateNFT(certificateNFTAddress);
    }
}
