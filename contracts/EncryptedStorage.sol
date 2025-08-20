// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, InEuint128, euint128} from "@fhenixprotocol/cofhe-contracts/FHE.sol";

contract EncryptedStorage {

    euint128 private counter;

    function getCounter() public view returns(euint128){
        return counter;
    }

    function store(InEuint128 calldata num) public {
        counter = FHE.asEuint128(num);

        FHE.allowThis(counter);
        FHE.allowSender(counter);
    }

    function increment(InEuint128 calldata num) public {
        euint128 _num = FHE.asEuint128(num);
        counter = FHE.add(counter, _num);

        FHE.allowThis(counter);
        FHE.allowSender(counter);
    }

    function decrement(InEuint128 calldata num) public {
        euint128 _num = FHE.asEuint128(num);
        counter = FHE.sub(counter, _num);

        FHE.allowThis(counter);
        FHE.allowSender(counter);
    }
}