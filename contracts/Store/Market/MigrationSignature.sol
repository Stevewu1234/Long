// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";


abstract contract MigrationSignature is SignatureChecker {  


    function toAsciiString(address x) internal view returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal view returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function _toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(message.length) , message));
    }


    function _requireAuthorizedMigration(
        address originalAddress,
        address newAddress,
        bytes memory signature
    ) internal view {
        require(newAddress != address(0), "Invalid new address");
        bytes32 hash = 
        _toEthSignedMessageHash(
            abi.encodePacked("I authorize Foundation to migrate to", toAsciiString(newAddress))
        );

        require(SignatureChecker.isValidSignatureNow(originalAddress, hash, signature), "signature is incorrect");
    }
}