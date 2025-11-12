// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ICertificateNFT {
    function safeMint(
        address to,
        string memory tokenURI_
    ) external returns (uint256 tokenId);
}

contract ElearningPlatform {
    ICertificateNFT public certificateNFT;

    struct Course {
        uint256 id;
        address instructor;
        uint256 price;
        string title;
        string contentCid;
    }

    uint256 public nextCourseId = 1;

    // Create a key (uint256) and value (Course) to track courses
    mapping(uint256 => Course) public courses;

    uint256[] public courseIds; 

    event CourseCreated(
        uint256 indexed courseId,
        address indexed instructor,
        string title,
        uint256 price,
        string contentCid
    );

    // calldata means it can't not modify and don't copy into memory,
    function createCourse(
        string calldata title,
        uint256 price,
        string calldata contentCid
    ) external returns (uint256 courseId) {
        // courseId is a named return variable, means it's automatically initialized within the function's scope
        require(bytes(title).length != 0, "Title is required");
        require(bytes(contentCid).length != 0, "CID required");
        courseId = nextCourseId++;
        courses[courseId] = Course(
            courseId,
            msg.sender,
            price,
            title,
            contentCid
        );

        courseIds.push(courseId);

        emit CourseCreated(courseId, msg.sender, title, price, contentCid);
    }

    function getAllCourse() public view returns (Course[] memory) {
        Course[] memory allCourses = new Course[](courseIds.length);
        for (uint256 i = 0; i < courseIds.length; i++) {
            allCourses[i] = courses[courseIds[i]];
        }
        return allCourses;
    }

    constructor(address certificateNFTAddress) {
        require(certificateNFTAddress != address(0), "Invalid NFT address");
        certificateNFT = ICertificateNFT(certificateNFTAddress);
    }
}