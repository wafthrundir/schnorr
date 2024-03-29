// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


/// @author Pawel Sasor
/// @title StringInput: Contract created as a response to an assignment
/// @notice Contract allows saving arrays of string per user account
/// @notice Each string added must be signed using Schnorr signature
/// @notice StringInput contract uses Schnorr contract
contract StringInput {


  mapping (address => string[]) inputs;

  /// @notice Push a new string to the user's array using precompiled version of schnorrVerify function
  /// @notice String must be signed using Schnorr signature
  /// @notice public key and signature are passed as parameters
  function push(string calldata input, bytes32 pubkey, bytes calldata sig) public returns (address) {
    require(precompiledSchnorrVerify(bytes(input), pubkey, sig), "Invalid signature.");
    inputs[msg.sender].push(input);
    return msg.sender;
  }


  /// @notice Get string array for the user
  function get() public view returns (string[] memory) {
    return inputs[msg.sender];
  }

  /// @notice Get string at specified index from the user's array
  function get(uint index) public view returns (string memory) {
    require(index < inputs[msg.sender].length, "Index out of bounds");
    return inputs[msg.sender][index];
  }

  /// @notice Get the length of user's array
  function length() public view returns (uint) {
    return inputs[msg.sender].length;
  }

  /// @notice call a precompiled contract schnorrVerify
  /// @notice call a method which verifies a provided signature
  function precompiledSchnorrVerify(bytes calldata m, bytes32 pubkey, bytes calldata sig) public view returns (bool v) {
    (bool ok, bytes memory out) = address(0x0c).staticcall(abi.encode(m, pubkey, sig));
    require(ok);
    v = abi.decode(out, (bool));
  }

}
