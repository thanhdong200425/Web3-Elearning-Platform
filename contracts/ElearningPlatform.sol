// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "hardhat/console.sol";

interface ICertificateNFT {
    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri,
        string memory course,
        string memory student,
        string memory date
    ) external;
}

contract ElearningPlatform {
    ICertificateNFT public certificateNFT;

    constructor(address _certificateNFTAddress) {
        require(_certificateNFTAddress != address(0), "Invalid NFT address");
        certificateNFT = ICertificateNFT(_certificateNFTAddress);
    }

    // Define a Course struct to hold course details, only ElearningPlatform contract use this struct
    struct Course {
        uint256 id;
        address instructor;
        uint256 price;
        string title;
        string contentCid;
    }

    uint256 public nextCourseId = 1;
    mapping(uint256 => Course) public courses;
    uint256[] public courseIds;

    // Mapping from student address => { courseId => purchased }
    mapping(address => mapping(uint256 => bool)) public purchases;

    // Mapping from student address => array of purchased course IDs
    mapping(address => uint256[]) public studentCourses;

    // Mapping from student address => courseId => index in studentCourses array
    mapping(address => mapping(uint256 => uint256)) public studentCourseIndex;

    // Event to notify when a course is created
    event CourseCreated(
        uint256 indexed courseId,
        address indexed instructor,
        string title,
        uint256 price,
        string contentCid
    );

    // Event to notify when a course is purchased
    event CoursePurchased(
        address indexed student,
        uint256 indexed courseId,
        uint256 price
    );

    function getAllCourse() public view returns (Course[] memory) {
        uint256 courseIdLength = courseIds.length;
        Course[] memory allCourses = new Course[](courseIdLength);
        for (uint256 i = 0; i < courseIdLength; i++) {
            allCourses[i] = courses[courseIds[i]];
        }
        return allCourses;
    }

    function getCourseById(
        uint256 courseId
    ) public view returns (Course memory) {
        return courses[courseId];
    }

    function createCourse(
        string calldata _title,
        uint256 _price,
        string calldata _contentCid
    ) public returns (uint256 courseId) {
        require(bytes(_title).length != 0, "Title is required");
        require(bytes(_contentCid).length != 0, "Content CID is required");
        courseId = nextCourseId++;
        courses[courseId] = Course({
            id: courseId,
            instructor: msg.sender,
            price: _price,
            title: _title,
            contentCid: _contentCid
        });
        courseIds.push(courseId);
        console.log("Course created:", courseId);
        console.log("Title:", _title);
        console.log("Content CID:", _contentCid);

        emit CourseCreated(courseId, msg.sender, _title, _price, _contentCid);

        return courseId;
    }

    function purchaseCourse(uint256 _courseId) public payable {
        Course memory course = courses[_courseId];
        require(course.id != 0, "Course does not exist");
        require(!purchases[msg.sender][_courseId], "Course already purchased");
        require(msg.value >= course.price, "Insufficient payment");

        // Mark as purchased
        purchases[msg.sender][_courseId] = true;

        // Add to student's course list
        studentCourseIndex[msg.sender][_courseId] = studentCourses[msg.sender]
            .length;
        studentCourses[msg.sender].push(_courseId);

        // Transfer payment to instructor
        (bool sent, ) = course.instructor.call{value: course.price}("");
        require(sent, "Failed to send payment to instructor");

        // Refund excess payment if any
        if (msg.value > course.price) {
            (bool refundSent, ) = msg.sender.call{
                value: msg.value - course.price
            }("");
            require(refundSent, "Failed to refund excess payment");
        }

        emit CoursePurchased(msg.sender, _courseId, course.price);
    }

    function hasPurchasedCourse(
        address _student,
        uint256 _courseId
    ) public view returns (bool) {
        return purchases[_student][_courseId];
    }

    function getPurchasedCourses(
        address _student
    ) public view returns (uint256[] memory) {
        return studentCourses[_student];
    }

    function getCourseContentCid(
        uint256 _courseId
    ) public view returns (string memory) {
        require(courses[_courseId].id != 0, "Course does not exist");
        return courses[_courseId].contentCid;
    }

    function getPurchasedCourseContentCid(
        address _student,
        uint256 _courseId
    ) public view returns (string memory) {
        require(purchases[_student][_courseId], "Course not purchased");
        return courses[_courseId].contentCid;
    }

    // ========== CERTIFICATE FUNCTIONALITY ==========

    // Mapping from student address => courseId => tokenId (0 means no certificate)
    mapping(address => mapping(uint256 => uint256)) public certificates;

    // Counter for certificate token IDs
    uint256 public nextCertificateTokenId = 1;

    // Event when certificate is minted
    event CertificateMinted(
        address indexed student,
        uint256 indexed courseId,
        uint256 tokenId,
        string tokenURI
    );

    /**
     * @dev Claim certificate NFT after completing a course
     * @param _courseId The ID of the completed course
     * @param _tokenURI The IPFS URI for the certificate metadata
     * @param _courseName Name of the course for certificate data
     * @param _studentName Name of the student for certificate data
     * @param _issueDate Date of certificate issuance
     * @return tokenId The ID of the minted certificate NFT
     */
    function claimCertificate(
        uint256 _courseId,
        string calldata _tokenURI,
        string calldata _courseName,
        string calldata _studentName,
        string calldata _issueDate
    ) public returns (uint256 tokenId) {
        // Validate course purchase
        require(purchases[msg.sender][_courseId], "Course not purchased");

        // Validate certificate not already claimed
        require(
            certificates[msg.sender][_courseId] == 0,
            "Certificate already claimed"
        );

        // Note: Course completion is verified off-chain (frontend tracks progress)
        // This is acceptable for MVP. Can add on-chain verification later if needed.

        // Mint certificate NFT
        tokenId = nextCertificateTokenId++;

        // Call CertificateNFT contract to mint
        certificateNFT.safeMint(
            msg.sender,
            tokenId,
            _tokenURI,
            _courseName,
            _studentName,
            _issueDate
        );

        // Track certificate
        certificates[msg.sender][_courseId] = tokenId;

        emit CertificateMinted(msg.sender, _courseId, tokenId, _tokenURI);

        return tokenId;
    }

    /**
     * @dev Get certificate token ID for a student and course
     * @param _student Student address
     * @param _courseId Course ID
     * @return tokenId The certificate token ID (0 if not claimed)
     */
    function getCertificateTokenId(
        address _student,
        uint256 _courseId
    ) public view returns (uint256) {
        return certificates[_student][_courseId];
    }

    /**
     * @dev Check if student has claimed certificate for a course
     * @param _student Student address
     * @param _courseId Course ID
     * @return hasCertificate True if certificate has been claimed
     */
    function hasCertificate(
        address _student,
        uint256 _courseId
    ) public view returns (bool) {
        return certificates[_student][_courseId] != 0;
    }
}
