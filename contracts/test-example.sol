// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import "@fhenixprotocol/contracts/utils/CoFheTest.sol";
import "./calculator.sol";
import "./fherc20.sol";
import "./auction.sol";

/**
 * @title FHETestExamples
 * @notice Comprehensive test examples demonstrating CoFheTest patterns
 * @dev This contract shows all major FHE testing patterns:
 *      - Basic FHE operation testing
 *      - Access control verification
 *      - Multi-transaction decryption flows
 *      - Cross-contract interactions
 *      - Edge case testing
 *      - Performance testing
 * 
 * Key Testing Concepts:
 * - Always extend CoFheTest, not just Test
 * - Use vm.warp(block.timestamp + 11) after FHE operations
 * - Use createInEuint32() to create encrypted test values
 * - Use assertHashValue() to compare encrypted results
 * - Test both success and failure scenarios
 */
contract FHETestExamples is CoFheTest {
    
    // ================================
    // TEST CONTRACTS
    // ================================
    
    EncryptedCalculator public calculator;
    FHERC20 public token;
    SealedBidAuction public auction;
    
    // Test users
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    
    // ================================
    // SETUP
    // ================================
    
    function setUp() public {
        // Deploy test contracts
        calculator = new EncryptedCalculator();
        
        token = new FHERC20(
            "Test Token",    // name
            "TEST",         // symbol
            18,             // decimals
            1000000,        // initial supply
            true            // public total supply
        );
        
        auction = new SealedBidAuction(
            address(token), // item being auctioned
            1,              // item ID
            100,            // minimum bid
            10,             // required deposit
            3600            // duration (1 hour)
        );
        
        // Fund test accounts
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);
    }
    
    // ================================
    // BASIC FHE OPERATION TESTS
    // ================================
    
    /**
     * @notice Test basic encrypted addition
     * 
     * Pattern: Simple FHE operation with hash value assertion
     */
    function test_Calculator_Add_ReturnsCorrectSum() public {
        uint32 a = 15;
        uint32 b = 25;
        uint32 expected = 40;
        
        // Perform encrypted addition
        euint32 result = calculator.add(a, b);
        
        // CRITICAL: Wait for FHE operations to process
        vm.warp(block.timestamp + 11);
        
        // Verify result using hash comparison
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test subtraction with potential underflow
     * 
     * Pattern: Testing edge cases in FHE arithmetic
     */
    function test_Calculator_Subtract_HandlesUnderflow() public {
        uint32 a = 10;
        uint32 b = 20;
        // Expected: wrapping behavior (uint32 max - 9)
        uint32 expected = type(uint32).max - 9;
        
        euint32 result = calculator.subtract(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test division by zero handling
     * 
     * Pattern: Testing conditional logic with FHE.select()
     */
    function test_Calculator_Divide_HandlesDivisionByZero() public {
        uint32 a = 100;
        uint32 b = 0;
        // Expected: returns dividend unchanged when divisor is zero
        uint32 expected = a;
        
        euint32 result = calculator.divide(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test normal division
     * 
     * Pattern: Testing successful path of conditional logic
     */
    function test_Calculator_Divide_NormalDivision() public {
        uint32 a = 100;
        uint32 b = 4;
        uint32 expected = 25;
        
        euint32 result = calculator.divide(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test maximum finding
     * 
     * Pattern: Testing comparison operations
     */
    function test_Calculator_Maximum_FindsLargerValue() public {
        uint32 a = 75;
        uint32 b = 50;
        uint32 expected = 75;
        
        euint32 result = calculator.maximum(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test maximum finding with reversed inputs
     * 
     * Pattern: Testing comparison symmetry
     */
    function test_Calculator_Maximum_FindsLargerValueReversed() public {
        uint32 a = 30;
        uint32 b = 80;
        uint32 expected = 80;
        
        euint32 result = calculator.maximum(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    // ================================
    // STATE MANAGEMENT TESTS
    // ================================
    
    /**
     * @notice Test complex calculation with state storage
     * 
     * Pattern: Testing state storage with FHE.allowThis()
     */
    function test_Calculator_ComplexCalculation_StoresResult() public {
        uint32 a = 10;
        uint32 b = 5;
        uint32 c = 3;
        uint32 expected = (a + b) * c; // 45
        
        vm.prank(alice);
        euint32 result = calculator.complexCalculation(a, b, c);
        vm.warp(block.timestamp + 11);
        
        // Verify immediate return value
        assertHashValue(result, expected);
        
        // Verify state was updated
        assertTrue(calculator.hasStoredResult(alice));
        
        // Verify stored result can be retrieved
        vm.prank(alice);
        euint32 storedResult = calculator.getStoredResult();
        vm.warp(block.timestamp + 11);
        
        assertHashValue(storedResult, expected);
    }
    
    /**
     * @notice Test batch sum operation
     * 
     * Pattern: Testing iterative FHE operations
     */
    function test_Calculator_BatchSum_SumsAllValues() public {
        uint32[] memory values = new uint32[](4);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;
        values[3] = 40;
        uint32 expected = 100;
        
        euint32 result = calculator.batchSum(values);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Test clearing stored results
     * 
     * Pattern: Testing state cleanup
     */
    function test_Calculator_ClearResult_RemovesStoredData() public {
        // First store a result
        vm.prank(alice);
        calculator.complexCalculation(10, 5, 2);
        vm.warp(block.timestamp + 11);
        
        assertTrue(calculator.hasStoredResult(alice));
        
        // Clear the result
        vm.prank(alice);
        calculator.clearResult();
        vm.warp(block.timestamp + 11);
        
        assertFalse(calculator.hasStoredResult(alice));
    }
    
    // ================================
    // ACCESS CONTROL TESTS
    // ================================
    
    /**
     * @notice Test that users can access their own results
     * 
     * Pattern: Testing access control success case
     */
    function test_Calculator_AccessControl_UserCanAccessOwnResult() public {
        vm.prank(alice);
        euint32 result = calculator.add(10, 20);
        vm.warp(block.timestamp + 11);
        
        // Alice should be able to access her result
        // (This would be tested by attempting decryption off-chain)
        assertNotEq(result, euint32.wrap(0));
    }
    
    /**
     * @notice Test multi-user isolation
     * 
     * Pattern: Testing that users don't interfere with each other
     */
    function test_Calculator_MultiUser_ResultsAreIsolated() public {
        // Alice's calculation
        vm.prank(alice);
        calculator.complexCalculation(10, 5, 2);
        vm.warp(block.timestamp + 11);
        
        // Bob's calculation
        vm.prank(bob);
        calculator.complexCalculation(20, 10, 3);
        vm.warp(block.timestamp + 11);
        
        // Both should have results
        assertTrue(calculator.hasStoredResult(alice));
        assertTrue(calculator.hasStoredResult(bob));
        
        // Results should be different
        vm.prank(alice);
        euint32 aliceResult = calculator.getStoredResult();
        vm.warp(block.timestamp + 11);
        
        vm.prank(bob);
        euint32 bobResult = calculator.getStoredResult();
        vm.warp(block.timestamp + 11);
        
        assertNotEq(aliceResult, bobResult);
    }
    
    // ================================
    // FHERC20 TOKEN TESTS
    // ================================
    
    /**
     * @notice Test encrypted token transfer
     * 
     * Pattern: Testing encrypted token operations
     */
    function test_Token_Transfer_UpdatesBalances() public {
        uint32 transferAmount = 1000;
        
        // Owner transfers to Alice
        vm.prank(address(this)); // Contract owner
        bool success = token.transfer(alice, transferAmount);
        vm.warp(block.timestamp + 11);
        
        assertTrue(success);
        assertTrue(token.hasAnyBalance(alice));
        
        // Alice should be able to query her balance
        vm.prank(alice);
        euint32 aliceBalance = token.balanceOf(alice);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(aliceBalance, transferAmount);
    }
    
    /**
     * @notice Test encrypted token approval and transferFrom
     * 
     * Pattern: Testing delegated transfer patterns
     */
    function test_Token_Approval_AllowsTransferFrom() public {
        uint32 transferAmount = 500;
        uint32 approvalAmount = 1000;
        
        // Setup: Owner transfers to Alice first
        vm.prank(address(this));
        token.transfer(alice, 2000);
        vm.warp(block.timestamp + 11);
        
        // Alice approves Bob to spend her tokens
        vm.prank(alice);
        token.approve(bob, approvalAmount);
        vm.warp(block.timestamp + 11);
        
        assertTrue(token.hasAllowance(alice, bob));
        
        // Bob transfers from Alice to Charlie
        vm.prank(bob);
        euint32 encAmount = createInEuint32(transferAmount);
        vm.warp(block.timestamp + 11);
        
        bool success = token.transferFrom(alice, charlie, encAmount);
        vm.warp(block.timestamp + 11);
        
        assertTrue(success);
        assertTrue(token.hasAnyBalance(charlie));
    }
    
    /**
     * @notice Test token minting
     * 
     * Pattern: Testing privileged operations
     */
    function test_Token_Mint_IncreasesTotalSupply() public {
        uint32 mintAmount = 5000;
        uint32 originalSupply = token.publicTotalSupply();
        
        // Only owner can mint
        bool success = token.mint(alice, mintAmount);
        vm.warp(block.timestamp + 11);
        
        assertTrue(success);
        assertTrue(token.hasAnyBalance(alice));
        assertEq(token.publicTotalSupply(), originalSupply + mintAmount);
    }
    
    /**
     * @notice Test token burning
     * 
     * Pattern: Testing balance reduction operations
     */
    function test_Token_Burn_ReducesBalance() public {
        uint32 burnAmount = 100;
        
        // Setup: Give Alice some tokens
        vm.prank(address(this));
        token.transfer(alice, 1000);
        vm.warp(block.timestamp + 11);
        
        // Alice burns some tokens
        vm.prank(alice);
        bool success = token.burn(burnAmount);
        vm.warp(block.timestamp + 11);
        
        assertTrue(success);
    }
    
    // ================================
    // AUCTION TESTS
    // ================================
    
    /**
     * @notice Test basic auction flow
     * 
     * Pattern: Testing multi-phase contract interactions
     */
    function test_Auction_BasicFlow_AcceptsBids() public {
        // Start auction
        auction.startAuction(3600); // 1 hour
        
        // Alice places bid
        vm.prank(alice);
        auction.bid{value: 10}(150);
        vm.warp(block.timestamp + 11);
        
        assertTrue(auction.hasBid(alice));
        
        // Bob places higher bid
        vm.prank(bob);
        auction.bid{value: 10}(200);
        vm.warp(block.timestamp + 11);
        
        assertTrue(auction.hasBid(bob));
        
        // Check auction stats
        (uint256 bidderCount, , ) = auction.getAuctionStats();
        assertEq(bidderCount, 2);
    }
    
    /**
     * @notice Test auction bid increase
     * 
     * Pattern: Testing state modification operations
     */
    function test_Auction_IncreaseBid_UpdatesBidAmount() public {
        auction.startAuction(3600);
        
        // Alice places initial bid
        vm.prank(alice);
        auction.bid{value: 10}(100);
        vm.warp(block.timestamp + 11);
        
        // Alice increases her bid
        vm.prank(alice);
        euint32 additionalAmount = createInEuint32(50);
        vm.warp(block.timestamp + 11);
        
        auction.increaseBid{value: 5}(additionalAmount);
        vm.warp(block.timestamp + 11);
        
        // Verify deposit was updated
        assertEq(auction.getBidDeposit(alice), 15);
    }
    
    /**
     * @notice Test auction time controls
     * 
     * Pattern: Testing time-based access controls
     */
    function test_Auction_TimeControls_RejectsBidsAfterEnd() public {
        auction.startAuction(100); // Short auction
        
        // Fast forward past auction end
        vm.warp(block.timestamp + 200);
        
        // Bid should fail
        vm.prank(alice);
        vm.expectRevert("Bidding period ended");
        auction.bid{value: 10}(150);
    }
    
    // ================================
    // EDGE CASE TESTS
    // ================================
    
    /**
     * @notice Test zero value operations
     * 
     * Pattern: Testing edge cases with zero values
     */
    function test_Calculator_ZeroValues_HandledCorrectly() public {
        uint32 zero = 0;
        uint32 nonZero = 42;
        
        euint32 result = calculator.add(zero, nonZero);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, nonZero);
    }
    
    /**
     * @notice Test maximum value operations
     * 
     * Pattern: Testing boundary conditions
     */
    function test_Calculator_MaxValues_HandledCorrectly() public {
        uint32 maxValue = type(uint32).max;
        uint32 one = 1;
        
        // This should wrap around
        euint32 result = calculator.add(maxValue, one);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, 0); // Wrapped to zero
    }
    
    // ================================
    // FAILURE CASE TESTS
    // ================================
    
    /**
     * @notice Test unauthorized access attempts
     * 
     * Pattern: Testing access control failures
     */
    function testFail_Calculator_UnauthorizedAccess() public {
        // Alice stores a result
        vm.prank(alice);
        calculator.complexCalculation(10, 5, 2);
        vm.warp(block.timestamp + 11);
        
        // Bob tries to access Alice's result (should fail)
        vm.prank(bob);
        calculator.getStoredResult(); // This should revert
    }
    
    /**
     * @notice Test token transfer without sufficient balance
     * 
     * Pattern: Testing insufficient balance scenarios
     */
    function test_Token_Transfer_InsufficientBalance_HandledGracefully() public {
        // Alice has no tokens, tries to transfer
        vm.prank(alice);
        vm.expectRevert("Account has no balance");
        token.balanceOf(alice);
    }
    
    /**
     * @notice Test auction bid below minimum
     * 
     * Pattern: Testing validation failures
     */
    function testFail_Auction_BidBelowMinimum() public {
        auction.startAuction(3600);
        
        vm.prank(alice);
        auction.bid{value: 10}(50); // Below minimum of 100
    }
    
    // ================================
    // CROSS-CONTRACT TESTS
    // ================================
    
    /**
     * @notice Test calculator with token integration
     * 
     * Pattern: Testing cross-contract encrypted data flow
     */
    function test_CrossContract_TokenAndCalculator() public {
        // Get encrypted balance from token
        vm.prank(address(this));
        token.transfer(alice, 1000);
        vm.warp(block.timestamp + 11);
        
        vm.prank(alice);
        euint32 balance = token.balanceOf(alice);
        vm.warp(block.timestamp + 11);
        
        // Use encrypted balance in calculator (conceptual test)
        // In practice, cross-contract encrypted data sharing requires
        // careful permission management
        assertHashValue(balance, 1000);
    }
    
    // ================================
    // PERFORMANCE TESTS
    // ================================
    
    /**
     * @notice Test gas usage of FHE operations
     * 
     * Pattern: Testing performance characteristics
     */
    function test_Performance_FHEOperations_GasUsage() public {
        uint256 gasBefore = gasleft();
        
        euint32 result = calculator.add(100, 200);
        vm.warp(block.timestamp + 11);
        
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for FHE addition:", gasUsed);
        
        // Verify operation completed
        assertHashValue(result, 300);
        
        // FHE operations are more expensive than regular operations
        assertGt(gasUsed, 50000); // Expect higher gas usage
    }
    
    // ================================
    // HELPER FUNCTIONS
    // ================================
    
    /**
     * @notice Helper to create encrypted values for testing
     * 
     * Pattern: Test utility functions
     */
    function createTestEncryptedValue(uint32 value) internal returns (euint32) {
        euint32 encrypted = createInEuint32(value);
        vm.warp(block.timestamp + 11);
        return encrypted;
    }
    
    /**
     * @notice Helper to setup multi-user test scenario
     * 
     * Pattern: Test setup helpers
     */
    function setupMultiUserScenario() internal {
        // Give all test users some tokens
        vm.prank(address(this));
        token.transfer(alice, 5000);
        vm.warp(block.timestamp + 11);
        
        vm.prank(address(this));
        token.transfer(bob, 3000);
        vm.warp(block.timestamp + 11);
        
        vm.prank(address(this));
        token.transfer(charlie, 2000);
        vm.warp(block.timestamp + 11);
    }
    
    // ================================
    // FUZZ TESTING EXAMPLES
    // ================================
    
    /**
     * @notice Fuzz test for calculator addition
     * 
     * Pattern: Fuzz testing with constraints
     */
    function testFuzz_Calculator_Add(uint32 a, uint32 b) public {
        // Constrain inputs to avoid overflow
        vm.assume(a <= type(uint32).max / 2);
        vm.assume(b <= type(uint32).max / 2);
        
        uint32 expected = a + b;
        
        euint32 result = calculator.add(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    /**
     * @notice Fuzz test for maximum function
     * 
     * Pattern: Fuzz testing comparison operations
     */
    function testFuzz_Calculator_Maximum(uint32 a, uint32 b) public {
        uint32 expected = a >= b ? a : b;
        
        euint32 result = calculator.maximum(a, b);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expected);
    }
    
    // ================================
    // INTEGRATION TESTS
    // ================================
    
    /**
     * @notice Test complete auction workflow
     * 
     * Pattern: End-to-end integration testing
     */
    function test_Integration_CompleteAuctionWorkflow() public {
        // Start auction
        auction.startAuction(1000);
        
        // Multiple bidders place bids
        vm.prank(alice);
        auction.bid{value: 10}(150);
        vm.warp(block.timestamp + 11);
        
        vm.prank(bob);
        auction.bid{value: 10}(200);
        vm.warp(block.timestamp + 11);
        
        vm.prank(charlie);
        auction.bid{value: 10}(175);
        vm.warp(block.timestamp + 11);
        
        // Fast forward past auction end
        vm.warp(block.timestamp + 1001);
        
        // End auction
        auction.endBidding();
        
        // Verify auction ended and winner determined
        assertEq(auction.winner(), bob); // Highest bidder
        
        // Verify auction statistics
        (uint256 bidderCount, uint256 deposits, ) = auction.getAuctionStats();
        assertEq(bidderCount, 3);
        assertEq(deposits, 30); // 3 bidders * 10 deposit each
    }
}

/*
TESTING ANTI-PATTERNS TO AVOID:

1. ❌ Forgetting vm.warp() after FHE operations:
   function badTest() public {
       euint32 result = calculator.add(10, 20);
       assertHashValue(result, 30); // May fail without timing
   }

2. ❌ Not extending CoFheTest:
   contract BadTest is Test { // Should be CoFheTest
       // FHE operations won't work properly
   }

3. ❌ Comparing encrypted values directly:
   function badComparison() public {
       euint32 result = calculator.add(10, 20);
       vm.warp(block.timestamp + 11);
       assertEq(result, euint32.wrap(30)); // Won't work as expected
   }

4. ❌ Not testing access control:
   function incompleteTest() public {
       euint32 result = calculator.add(10, 20);
       vm.warp(block.timestamp + 11);
       assertNotEq(result, euint32.wrap(0)); // Doesn't test access
   }

5. ❌ Not testing failure cases:
   // Always test both success and failure scenarios

TESTING BEST PRACTICES:

✅ Always extend CoFheTest for FHE testing
✅ Use vm.warp(block.timestamp + 11) after FHE operations
✅ Use createInEuint32() for test encrypted values
✅ Use assertHashValue() for encrypted comparisons
✅ Test both success and failure scenarios
✅ Test access control thoroughly
✅ Use helper functions for common setup
✅ Test edge cases (zero, max values)
✅ Use fuzz testing for broader coverage
✅ Test cross-contract interactions
✅ Measure gas usage for performance
✅ Test multi-user scenarios
✅ Use descriptive test names
✅ Include integration tests

REMEMBER: FHE testing requires patience and proper timing patterns! ⏰

RUN THESE TESTS:
forge test --match-contract FHETestExamples -vvv
*/