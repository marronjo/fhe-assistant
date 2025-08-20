// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CoFheTest} from "@fhenixprotocol/cofhe-mock-contracts/CoFheTest.sol";

import {FHE, InEuint128, euint128} from "@fhenixprotocol/cofhe-contracts/FHE.sol";

import {EncryptedStorage} from "../src/EncryptedStorage.sol";

contract EncryptedStorageTest is Test, CoFheTest {

    EncryptedStorage private encryptedStorage;

    function setUp() public {
        encryptedStorage = new EncryptedStorage();
    }

    function test_store() public {
        InEuint128 memory num = createInEuint128(10, address(this));
        encryptedStorage.store(num);

        euint128 counter = encryptedStorage.getCounter();
        assertHashValue(counter, 10);
    }

    function test_increment(uint128 _num, uint128 _inc) public {
        vm.assume(type(uint128).max - _num >= _inc);    //prevent overflow

        InEuint128 memory num = createInEuint128(_num, address(this));
        encryptedStorage.store(num);

        InEuint128 memory inc = createInEuint128(_inc, address(this));
        encryptedStorage.increment(inc);

        euint128 counter = encryptedStorage.getCounter();
        assertHashValue(counter, _num + _inc);
    }


    function test_decrement(uint128 _num, uint128 _dec) public {
        vm.assume(_num >= _dec);    //prevent underflow

        InEuint128 memory num = createInEuint128(_num, address(this));
        encryptedStorage.store(num);

        InEuint128 memory dec = createInEuint128(_dec, address(this));
        encryptedStorage.decrement(dec);

        euint128 counter = encryptedStorage.getCounter();
        assertHashValue(counter, _num - _dec);
    }
}