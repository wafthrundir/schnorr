// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


interface ISchnorr {
  function schnorr_sign(bytes memory m, bytes memory seckey, bytes32 aux_rand) external pure returns (bytes memory);
  function schnorr_verify(bytes memory m, bytes32 pubkey, bytes32 sig_lower, bytes32 sig_higher) external pure returns (bool);
  function schnorr_verify(bytes memory m, bytes32 pubkey, bytes calldata sig) external pure returns (bool);
  function pubkey_gen(bytes32 seckey) external pure returns (bytes32);
}

/// @author Pawel Sasor
/// @title StringInput: Contract created as a response to an assignment
/// @notice Contract allows saving arrays of string per user account
/// @notice Each string added must be signed using Schnorr signature
/// @notice StringInput contract uses Schnorr contract
contract StringInput {

  address schnorrAddress;

  mapping (address => string[]) inputs;

  /// @notice Initialize contract passing address of Schnorr contract
  constructor(address _schnorrAddress) {
    schnorrAddress = _schnorrAddress;
  }

  /// @notice Push a new string to the user's array
  /// @notice String must be signed using Schnorr signature
  /// @notice public key and signature are passed as parameters
  function push(string memory input, bytes32 pubkey, bytes memory sig) public returns (address) {
    require(ISchnorr(schnorrAddress).schnorr_verify(bytes(input), pubkey, sig), "Invalid signature.");
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

}
