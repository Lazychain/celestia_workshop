// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {Lazy721} from "../src/Lazy721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// https://book.getfoundry.sh/reference/config/inline-test-config
// https://github.com/patrickd-/solidity-fuzzing-boilerplate

contract Lazy721Test is StdCheats, Test, ERC721Holder {
    Lazy721 private lnft;
    address public owner;
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");

    function setUp() public {
        lnft = new Lazy721("Lazy NFT", "LAZY", 4, "ipfs://lazyhash/");
    }

    function testInitializeState() public view {
        assertEq(lnft.name(), "Lazy NFT");
        assertEq(lnft.symbol(), "LAZY");
        assertEq(lnft.owner(), address(this));
        assertEq(lnft.totalSupply(), 0);
    }

    function testSafeMint() public {
        lnft.safeMint(user1);
        assertEq(lnft.totalSupply(), 1);
        assertEq(lnft.balanceOf(user1), 1);
        assertEq(lnft.balanceOf(user2), 0);
        assertEq(lnft.ownerOf(0), user1);

        lnft.safeMint(user2);
        assertEq(lnft.totalSupply(), 2);
        assertEq(lnft.balanceOf(user1), 1);
        assertEq(lnft.balanceOf(user2), 1);
        assertEq(lnft.ownerOf(1), user2);
    }

    function test_TokenURI() public {
        lnft.safeMint(user1);
        assertEq(lnft.tokenURI(0), "ipfs://lazyhash/0.json");

        lnft.safeMint(user2);
        assertEq(lnft.tokenURI(1), "ipfs://lazyhash/1.json");
    }

    function testRevertWhenNonOwnerMints() public {
        vm.prank(user1);
        vm.expectRevert();
        lnft.safeMint(user2);
    }

    function testRevertWhenTokenCapExceed() public {
        lnft.safeMint(user1);
        lnft.safeMint(user1);
        lnft.safeMint(user1);
        lnft.safeMint(user1);

        vm.expectRevert(Lazy721.Lazy721__TokenCapExceeded.selector);
        lnft.safeMint(user1);
    }

    function testRevertWhenQueryNonexistentToken() public {
        vm.expectRevert();
        lnft.tokenURI(999);
    }

    function test_SupportsInterface() public view {
        // Test ERC721 interface support
        assertTrue(lnft.supportsInterface(0x80ac58cd)); // ERC721
        assertTrue(lnft.supportsInterface(0x780e9d63)); // ERC721Enumerable
        assertTrue(lnft.supportsInterface(0x5b5e139f)); // ERC721Metadata
    }

    // forge-config: default.fuzz.show-logs = true
    // forge-config: default.invariant.fail-on-revert = true
    function testFuzz_Name(string memory name) public {
        vm.assume(bytes(name).length > 0); // Convert to bytes to access length
        Lazy721 newNft = new Lazy721(name, "LNT", 4, "ipfs://lazyhash/");
        assertEq(newNft.name(), name);
    }

    // forge-config: default.fuzz.runs = 300
    function testFuzz_Mint(uint8 quantity) public {
        vm.assume(quantity > 0);
        Lazy721 newNft = new Lazy721(
            "LazyNFT",
            "LNT",
            quantity,
            "ipfs://lazyhash/"
        );
        assertEq(newNft.totalSupply(), 0);
        for (uint256 i = 0; i < quantity; ++i) {
            // LazyNFTTest is the owner
            newNft.safeMint(address(this));
        }
        assertEq(newNft.totalSupply(), quantity);
    }

    // Test Fuzz: Token Symbol with Edge Cases
    function testFuzz_TokenSymbol(
        string memory name,
        string memory symbol,
        uint8 tokenCap
    ) public {
        // Edge cases for `symbol`: very short, mixed case, numbers
        vm.assume(bytes(symbol).length >= 1 && bytes(symbol).length <= 5); // typical symbol length
        vm.assume(tokenCap > 0);
        vm.assume(bytes(name).length > 0 && bytes(name).length < 30); // reasonable name length
        Lazy721 newNft = new Lazy721(
            name,
            symbol,
            tokenCap,
            "ipfs://lazyhash/"
        );
        assertEq(newNft.symbol(), symbol);
    }

    function testTokenCapOfOne() public {
        Lazy721 newNft = new Lazy721("Solo", "SL", 1, "ipfs:// solo/");
        newNft.safeMint(address(this));
        vm.expectRevert(Lazy721.Lazy721__TokenCapExceeded.selector);
        newNft.safeMint(address(this));
    }

    function testZeroLengthBaseURI() public {
        vm.expectRevert(); // Assuming a custom error for invalid URI
        new Lazy721("Test", "TST", 10, "");
    }

    function testToggleApprovalForAll() public {
        lnft.safeMint(user1);
        vm.prank(user1);
        lnft.setApprovalForAll(user2, false);
        assertFalse(lnft.isApprovedForAll(user1, user2));
        vm.prank(user1);
        lnft.setApprovalForAll(user2, true);
        assertTrue(lnft.isApprovedForAll(user1, user2));
    }

    function testMultiOperatorTransfers() public {
        lnft.safeMint(user1);
        vm.prank(user1);
        lnft.setApprovalForAll(user2, true);
        lnft.setApprovalForAll(user3, true);
        vm.prank(user2);
        lnft.transferFrom(user1, user3, 0);
        assertEq(lnft.ownerOf(0), user3);
        // Test if user3 can now transfer as an operator
    }

    function testDynamicTokenURI() public {
        Lazy721 newNft = new Lazy721("Dynamic", "DY", 10, "ipfs://dynamic/");
        for (uint256 i = 0; i < 5; i++) {
            newNft.safeMint(address(this));
            string memory expectedURI = string(
                abi.encodePacked(
                    "ipfs://dynamic/",
                    Strings.toString(i),
                    ".json"
                )
            );
            assertEq(newNft.tokenURI(i), expectedURI);
        }
    }

    function testTotalSupplyVsTokenByIndex() public {
        Lazy721 newLnft = new Lazy721(
            "Lazy NFT",
            "LAZY",
            10,
            "ipfs://lazyhash/"
        );
        for (uint256 i = 0; i < 10; i++) {
            newLnft.safeMint(user1);
        }
        assertEq(newLnft.totalSupply(), 10);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721OutOfBoundsIndex(address,uint256)",
                address(0),
                10
            )
        );
        newLnft.tokenByIndex(10); // Out of bounds
    }

    function testUnpauseWindowTransfer() public {
        // This test assumes a specific implementation detail about how pausing works
        // and might need adjustment based on the actual contract behavior.
        lnft.pause();
        vm.prank(user1); // Assuming user1 has minted a token
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        lnft.transferFrom(user1, user2, 0);
        lnft.unpause();
        // Test if immediate transfer after unpause is successful
    }

    function testPauseState() public {
        lnft.pause();
        assertTrue(lnft.paused());

        lnft.unpause();
        assertFalse(lnft.paused());
    }

    // Test minting while paused
    function testPausedMint() public {
        lnft.pause();
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        lnft.safeMint(user1);
    }

    // Test transfers while paused
    function testPausedTransfer() public {
        lnft.safeMint(user1);
        lnft.pause();

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        lnft.transferFrom(user1, user2, 0);
    }

    function testBurnToken() public {
        lnft.safeMint(user1);

        vm.prank(user1);
        lnft.burn(0);

        assertEq(lnft.totalSupply(), 0);
        assertEq(lnft.balanceOf(user1), 0);

        // Update the error expectation to match OpenZeppelin's custom error
        vm.expectRevert(
            abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 0)
        );
        lnft.ownerOf(0);
    }

    function testApproveAndTransfer() public {
        lnft.safeMint(user1);

        vm.prank(user1);
        lnft.approve(user2, 0);
        assertEq(lnft.getApproved(0), user2);

        vm.prank(user2);
        lnft.transferFrom(user1, address(this), 0);
        assertEq(lnft.ownerOf(0), address(this));
    }

    function testApprovalClearsAfterTransfer() public {
        lnft.safeMint(user1);

        vm.prank(user1);
        lnft.approve(user2, 0);

        vm.prank(user2);
        lnft.transferFrom(user1, address(this), 0);

        assertEq(lnft.getApproved(0), address(0));
    }

    function testSetApprovalForAll() public {
        lnft.safeMint(user1);

        vm.prank(user1);
        lnft.setApprovalForAll(user2, true);
        assertTrue(lnft.isApprovedForAll(user1, user2));
    }

    function testOperatorTransfer() public {
        lnft.safeMint(user1);

        vm.prank(user1);
        lnft.setApprovalForAll(user2, true);

        vm.prank(user2);
        lnft.transferFrom(user1, address(this), 0);
        assertEq(lnft.ownerOf(0), address(this));
    }

    function testEnumerableOwnerByIndex() public {
        lnft.safeMint(user1); // ID 0
        lnft.safeMint(user1); // ID 1

        assertEq(lnft.tokenOfOwnerByIndex(user1, 0), 0);
        assertEq(lnft.tokenOfOwnerByIndex(user1, 1), 1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721OutOfBoundsIndex(address,uint256)",
                user1,
                2
            )
        );
        lnft.tokenOfOwnerByIndex(user1, 2);
    }

    function testEnumerableTokenByIndex() public {
        lnft.safeMint(user1);
        lnft.safeMint(user2);

        assertEq(lnft.tokenByIndex(0), 0);
        assertEq(lnft.tokenByIndex(1), 1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721OutOfBoundsIndex(address,uint256)",
                address(0),
                2
            )
        );
        lnft.tokenByIndex(2);
    }

    function testRevertTransferUnauthorized() public {
        lnft.safeMint(user1);

        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)",
                user2,
                0
            )
        );
        lnft.transferFrom(user1, user2, 0);
    }

    function testMintPauseMintAttempt() public {
        // Arrange
        uint8 tokenCap = 10;
        Lazy721 newNft = new Lazy721("Test", "TST", tokenCap, "ipfs://");

        // Act & Assert: Initial Mint
        newNft.safeMint(address(this));
        assertEq(newNft.totalSupply(), 1);

        // Act: Pause
        newNft.pause();
        assertTrue(newNft.paused());

        // Act & Assert: Mint Attempt After Pause
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        newNft.safeMint(address(this));
        assertEq(newNft.totalSupply(), 1); // Supply doesn't increase
    }

    // Test case: Normal operation - User has tokens
    function test_getTokensOwnedByUser_UserHasTokens() public {
        // Mint tokens to user1
        lnft.safeMint(user1);
        lnft.safeMint(user1);
        lnft.safeMint(user2); // Mint one to user2 for isolation

        // Assert user1's token balance and IDs
        uint256[] memory user1Tokens = lnft.getTokensOwnedByUser(user1);
        assertEq(user1Tokens.length, 2);
        assertEq(lnft.balanceOf(user1), 2);
        assertEq(user1Tokens[0], 0); // First minted token ID
        assertEq(user1Tokens[1], 1); // Second minted token ID
    }

    // Test case: Edge case - User has no tokens
    function test_getTokensOwnedByUser_UserHasNoTokens() public view {
        // Ensure user1 has no tokens
        uint256[] memory user1Tokens = lnft.getTokensOwnedByUser(user1);
        assertEq(user1Tokens.length, 0);
        assertEq(lnft.balanceOf(user1), 0);
    }

    // Test case: Edge case - Zero address
    function test_getTokensOwnedByUser_ZeroAddress() public {
        vm.expectRevert();
        uint256[] memory zeroAddrTokens = lnft.getTokensOwnedByUser(address(0));
        assertEq(zeroAddrTokens.length, 0);
    }

    // Test case: Edge case - Non-existent user (never interacted with the contract)
    function test_getTokensOwnedByUser_NonExistentUser() public view {
        address nonExistentUser = address(4); // New, unseen address
        uint256[] memory nonExistentUserTokens = lnft.getTokensOwnedByUser(
            nonExistentUser
        );
        assertEq(nonExistentUserTokens.length, 0);
    }

    // Test case: Large number of tokens owned by a user
    function test_getTokensOwnedByUser_LargeNumberOfTokens() public {
        uint256 numTokens = 20;
        Lazy721 newNft = new Lazy721("Test", "TST", numTokens, "ipfs://");
        // Mint a large number of tokens to user1
        for (uint256 i; i < numTokens; ++i) {
            newNft.safeMint(user1);
        }

        // Assert user1's token balance and array length
        uint256[] memory user1Tokens = newNft.getTokensOwnedByUser(user1);
        assertEq(user1Tokens.length, numTokens);
        assertEq(newNft.balanceOf(user1), numTokens);
    }
}
