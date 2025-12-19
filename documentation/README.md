## Usage

### Convention and rules

**Every contract must have a corresponding test file** to ensure it works correctly and without errors. This is a mandatory requirement for all contracts in this project.

#### Testing Requirements

- **Each contract** (e.g., `ElearningPlatform.sol`) **must have** a corresponding test file (e.g., `ElearningPlatform.t.sol`)
- Test files should be placed in the same directory as the contracts (`contracts/`) and follow the naming convention: `<ContractName>.t.sol`
- All test files must pass before deploying contracts to any network
- Tests should cover the main functionality of the contract, including:
  - Contract initialization and setup
  - Core functions and their expected behavior
  - Edge cases and error conditions
  - State changes and events

#### Why This Matters

Writing comprehensive tests ensures that:

- Contracts function as intended before deployment
- Bugs and vulnerabilities are caught early in development
- Contract behavior is documented through test cases
- Changes to contracts don't break existing functionality
- The codebase maintains high quality and reliability

**Before deploying any contract, ensure all tests pass by running:**

```shell
npx hardhat test
```

### Writing unit tests in Solidity

This project uses Solidity-based unit tests, which allow you to write tests directly in Solidity without any additional dependencies. Solidity tests are regular Solidity files that Hardhat treats as test files if they end with `.t.sol` or are located in the test directory.

#### Test Structure

Each test file **should** contain:

- A `setUp()` function that runs before each test to initialize the contract state
- Test functions that start with `test` prefix - these run as individual tests
- If a test function completes without reverting, the test passes; if it reverts, it fails

Here's an example from `contracts/ElearningPlatform.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    function test_GetAllCourse() public view {
        ElearningPlatform.Course[] memory courses = elearningPlatform
            .getAllCourse();
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

        require(
            keccak256(bytes(course.title)) == keccak256(bytes(expectedTitle)),
            "Title should match"
        );
        require(course.price == expectedPrice, "Price should match");
    }
}
```

#### Compiling Contracts

Before running tests, compile your contracts:

```shell
npx hardhat build
```

#### Running Tests

To run all the tests in the project:

```shell
npx hardhat test
```

You can also selectively run only Solidity tests:

```shell
npx hardhat test solidity
```

Or run TypeScript/Node.js tests:

```shell
npx hardhat test nodejs
```

The stack trace will show which line reverted if a test fails, helping you identify which assertion failed.

### Deploying to a local development node

To deploy your contracts in a persistent local network, use Hardhat's `node` task. First, run the node task in one terminal:

```shell
npx hardhat node
```

In another terminal, run the deployment with `--network localhost` to execute the Ignition module against the local node:

```shell
npx hardhat ignition deploy ignition/modules/Elearning.ts --network localhost
```

Ignition remembers the deployment state. If you run the deployment again, nothing will happen the second time because the module was already executed. Try rerunning the previous command to see it in action.

### Make a deployment to Sepolia

To run the deployment to Sepolia, you need an account with funds to send the transaction. The provided Hardhat configuration includes Configuration Variables called `SEPOLIA_PRIVATE_KEY` and `SEPOLIA_RPC_URL` , which you can use to set the private key of the account you want to use.

You can set the `SEPOLIA_PRIVATE_KEY` and `SEPOLIA_RPC_URL` variable using the `hardhat-keystore` plugin or by setting it as an environment variable.

To set the `SEPOLIA_RPC_URL` config variable using `hardhat-keystore`:

```shell
yarn hardhat keystore set SEPOLIA_RPC_URL
```

To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
yarn hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

```shell
yarn hardhat ignition deploy ignition/modules/Elearning.ts --network sepolia
```
