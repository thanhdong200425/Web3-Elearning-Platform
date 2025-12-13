// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import {ElearningPlatform} from "./ElearningPlatform.sol";

contract ElearningPlatformTest {
    ElearningPlatform elearningPlatform;

    function setUp() public {
        elearningPlatform = new ElearningPlatform(address(0x1234));
        // Initialize with a sample course
        elearningPlatform.createCourse(
            "Initial Course",
            100,
            "QmInitialContentCid"
        );
    }

    // function testFuzz_createCourse(
    //     string calldata title,
    //     uint price,
    //     string calldata contentCid
    // ) public {
    //     uint256 courseId = elearningPlatform.createCourse(
    //         title,
    //         price,
    //         contentCid
    //     );
    //     ElearningPlatform.Course memory course = elearningPlatform
    //         .getCourseById(courseId);
    //     require(
    //         keccak256(bytes(course.title)) == keccak256(bytes(title)),
    //         "Title should match"
    //     );
    //     require(course.price == price, "Price should match");
    //     require(
    //         keccak256(bytes(course.contentCid)) == keccak256(bytes(contentCid)),
    //         "Content CID should match"
    //     );
    // }

    function test_GetAllCourse() public view {
        ElearningPlatform.Course[] memory courses = elearningPlatform
            .getAllCourse();
        console.log("Total courses:", courses.length);
        for (uint256 i = 0; i < courses.length; i++) {
            console.log("Title", courses[i].title);
        }
        require(courses.length > 0, "Courses should not be empty");
    }

    function test_addOneCourse() public {
        string memory expectedTitle = "New Course";
        uint256 expectedPrice = 200;
        string memory expectedContentCid = "QmNewContentCid";
        uint256 courseId = elearningPlatform.createCourse(
            expectedTitle,
            expectedPrice,
            expectedContentCid
        );

        ElearningPlatform.Course memory course = elearningPlatform
            .getCourseById(courseId);

        // Check
        require(
            keccak256(bytes(course.title)) == keccak256(bytes(expectedTitle)),
            "Title should match"
        );
        require(course.price == expectedPrice, "Price should match");
        require(
            keccak256(bytes(course.contentCid)) ==
                keccak256(bytes(expectedContentCid)),
            "Content CID should match"
        );
    }
}
