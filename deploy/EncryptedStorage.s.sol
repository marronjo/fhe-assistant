// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {EncryptedStorage} from "../src/EncryptedStorage.sol";

contract EncryptedStorageScript is Script {
    function setUp() public {}

    function run() public returns(EncryptedStorage encryptedStorage) {
        vm.broadcast();
        encryptedStorage = new EncryptedStorage();
    }
}