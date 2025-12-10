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

    // Mapping from student address => { courseId => purchased }
    mapping(address => mapping(uint256 => bool)) public purchases;

    // Mapping from student address => array of purchased course IDs
    mapping(address => uint256[]) public studentCourses;

    // Mapping from student address => courseId => index in studentCourses array
    mapping(address => mapping(uint256 => uint256)) public studentCourseIndex;

    uint256[] public courseIds;

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
        Course[] memory allCourses = new Course[](courseIds.length);
        for (uint256 i = 0; i < courseIds.length; i++) {
            allCourses[i] = courses[courseIds[i]];
        }
        return allCourses;
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
}
