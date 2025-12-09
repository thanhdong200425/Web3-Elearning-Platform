// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICertificateNFT {
    function mint(address to, uint256 courseId) external;
}

contract ElearningPlatform {
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

    ICertificateNFT public certificateNFT;
    uint256 public nextCourseId = 1;
    mapping(uint256 => Course) public courses;
    
    // Mapping from student address => courseId => purchased
    mapping(address => mapping(uint256 => bool)) public purchases;
    
    // Mapping from student address => array of purchased course IDs
    mapping(address => uint256[]) public studentCourses;
    
    // Mapping from student address => courseId => index in studentCourses array
    mapping(address => mapping(uint256 => uint256)) public studentCourseIndex;
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

    event CoursePurchased(
        address indexed student,
        uint256 indexed courseId,
        uint256 price
    );

    constructor(address _certificateNFTAddress) {
        certificateNFT = ICertificateNFT(_certificateNFTAddress);
    }

    function createCourse(
        string memory _title,
        uint256 _price,
        string memory _contentCid
    ) public returns (uint256) {
        uint256 courseId = nextCourseId;
        courses[courseId] = Course({
            id: courseId,
            instructor: msg.sender,
            price: _price,
            title: _title,
            contentCid: _contentCid
        });
        nextCourseId++;

        emit CourseCreated(
            courseId,
            msg.sender,
            _title,
            _price,
            _contentCid
        );

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
        studentCourseIndex[msg.sender][_courseId] = studentCourses[msg.sender].length;
        studentCourses[msg.sender].push(_courseId);

        // Transfer payment to instructor
        (bool sent, ) = course.instructor.call{value: course.price}("");
        require(sent, "Failed to send payment to instructor");

        // Refund excess payment if any
        if (msg.value > course.price) {
            (bool refundSent, ) = msg.sender.call{value: msg.value - course.price}("");
            require(refundSent, "Failed to refund excess payment");
        }

        // Mint certificate NFT
        certificateNFT.mint(msg.sender, _courseId);

        emit CoursePurchased(msg.sender, _courseId, course.price);
    }

    function hasPurchasedCourse(address _student, uint256 _courseId) public view returns (bool) {
        return purchases[_student][_courseId];
    }

    function getPurchasedCourses(address _student) public view returns (uint256[] memory) {
        return studentCourses[_student];
    }

    function getCourseContentCid(uint256 _courseId) public view returns (string memory) {
        require(courses[_courseId].id != 0, "Course does not exist");
        return courses[_courseId].contentCid;
    }

    function getPurchasedCourseContentCid(address _student, uint256 _courseId) public view returns (string memory) {
        require(purchases[_student][_courseId], "Course not purchased");
        return courses[_courseId].contentCid;
    }
}

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
