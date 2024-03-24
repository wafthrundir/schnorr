// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "forge-std/console.sol";



/// @author Pawel Sasor
/// @title Implementation of Schnorr signature algorithms
/// @notice This is a solidity implementation of python reference algorithm https://github.com/bitcoin/bips/blob/master/bip-0340/reference.py
contract Schnorr {


    struct Point {
        uint256 x;
        uint256 y;
        bool inf;
    }

    uint256 public constant p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint256 public constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    uint256 public constant Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 public constant Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;

    /// @notice The function returns the 32-byte hash SHA256(SHA256(tag) || SHA256(tag) || m).
    function tagged_hash(string memory tag, bytes memory m) internal pure returns (bytes32) {
        bytes32 tag_hash = sha256(bytes(tag));
        return sha256(bytes.concat(tag_hash, tag_hash, m));
    }

    /// @notice calculates b^e % m
    /// @dev taken from https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/ECCMath.sol
    /// @dev some modifications in assembly code were necessary, since labels were removed from the language
    function expmod(uint b, uint e, uint m) internal pure returns (uint r) {
        if (b == 0)
            return 0;
        if (e == 0)
            return 1;
        require(m != 0);
        r = 1;
        uint bit = 2 ** 255;
        assembly {
            for {} bit {} {
                r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, bit)))), m)
                r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 2))))), m)
                r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 4))))), m)
                r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 8))))), m)
                bit := div(bit, 16)
            }
        }
    }

    /// @notice calculates (a * b) % p
    function mulp(uint256 a, uint256 b) internal pure returns (uint256) {
        return mulmod(a, b, p);
    }

    /// @notice calculates (a + b) % p
    function addp(uint256 a, uint256 b) internal pure returns (uint256) {
        return addmod(a, b, p);
    }

    /// @notice calculates (a - b) % p
    function subp(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? (a-b) % p : (p - ((b-a) % p)) % p;
    }

    /// @notice calculates point addition in elliptic curves arithmetics, P1 + P2
    function point_add(Point memory P1, Point memory P2) internal pure returns (Point memory) {
        if (P1.inf) {
            return P2;
        }
        if (P2.inf) {
            return P1;
        }
        if ((P1.x == P2.x) && (P1.y != P2.y)) {
            return Point(0, 0, true);
        }
        uint256 lam;
        if ((P1.x == P2.x) && (P1.y == P2.y)) {
            lam = mulp(3, mulp(P1.x, mulp(P1.x, expmod(mulp(2, P1.y), p - 2, p))));
        } else {
            lam = mulp(subp(P2.y, P1.y), expmod(subp(P2.x, P1.x), p - 2, p));
        }
        uint256 x3 = subp(mulp(lam, lam), addp(P1.x, P2.x));        
        return Point(x3, subp(mulp(lam, subp(P1.x, x3)), P1.y), false);
    }

    /// @notice calculates multiplication of point by scalar in elliptic curves arithmetics, kP
    function point_mul(Point memory P, uint256 k) internal pure returns (Point memory) {
        Point memory R = Point(0, 0, true);
        for (uint256 i = 0; i < 256; i++) {
            if ((k >> i) & 1 != 0) {
                R = point_add(R, P);
            }
            P = point_add(P, P);
        }
        return R;
    }

    /// @notice returns bytes32 representations of P.x
    function bytes_from_point(Point memory P) internal pure returns (bytes32) {
        return bytes32(P.x);
    }

    /// @notice see https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki#specification
    function lift_x(uint256 x) internal pure returns (Point memory) {
        if (x >= p) {
            return Point(0, 0, true);
        }
        uint256 y_sq = (expmod(x, 3, p) + 7) % p;
        uint256 y = expmod(y_sq, (p + 1) / 4, p);
        if (expmod(y, 2, p) != y_sq) {
            return Point(0, 0, true);
        }
        return Point(x, (y & 1 == 0) ? y : p - y, false);
    }

    /// @notice The function has_even_y(P), where P is a point for which not is_infinite(P), returns y(P) mod 2 = 0.
    function has_even_y(Point memory P) internal pure returns (bool) {
        require(!P.inf);
        return P.y % 2 == 0;
    }

    /// @notice converts bytes to uint256
    function int_from_bytes(bytes memory b) internal pure returns (uint256) {
        uint256 r = 0;
        for (uint256 i = 0; i < b.length; i++) {
            r += uint8(b[ b.length - i - 1]) * (256**i);
        }
        return r;
    }

    /// @notice converts bytes32 to uint256
    function int_from_bytes(bytes32 b) internal pure returns (uint256) {
        uint256 r = 0;
        for (uint256 i = 0; i < b.length; i++) {
            r += uint8(b[ b.length - i - 1]) * (256**i);
        }
        return r;
    }

    /// @notice parameter structure, introduced due to the limit of local variables number
    struct SignParams {
        uint256 d0;
        Point G;
        Point P;
        uint256 d;
        bytes32 t;
        uint256 k0;
        Point R;
        uint256 k;
        uint256 e;
        bytes32 sig_lower;
        bytes32 sig_higher;
        bytes sig;
    }

    /// @notice Implementation of Schnorr signature
    /// @notice Returns signature of m using secure key seckey and random value aux_rand
    /// @notice Based on reference implementation https://github.com/bitcoin/bips/blob/master/bip-0340/reference.py
    function schnorr_sign(bytes memory m, bytes memory seckey, bytes32 aux_rand) public pure returns (bytes memory) {
        SignParams memory params;
        params.d0 = int_from_bytes(seckey);
        require((params.d0 >= 1) && (params.d0 <= n - 1), "The secret key must be an integer in the range 1..n-1.");
        params.G = Point(Gx, Gy, false);        
        params.P = point_mul(params.G, params.d0);
        require(!params.P.inf);
        params.d = has_even_y(params.P) ? params.d0 : n - params.d0;
        params.t = bytes32(params.d) ^ tagged_hash("BIP0340/aux", abi.encodePacked(aux_rand));
        params.k0 = int_from_bytes(tagged_hash("BIP0340/nonce", bytes.concat(params.t, bytes_from_point(params.P), m))) % n;
        require(params.k0 != 0, "Failure. This happens only with negligible probability.");
        params.R = point_mul(params.G, params.k0);
        require(!params.R.inf);
        params.k = has_even_y(params.R) ? params.k0 : n - params.k0;
        params.e = int_from_bytes(tagged_hash("BIP0340/challenge", bytes.concat(bytes_from_point(params.R), bytes_from_point(params.P), m))) % n;
        params.sig_lower = bytes_from_point(params.R);
        params.sig_higher = bytes32(addmod(params.k, mulmod(params.e, params.d, n), n) % n);
        require(schnorr_verify(m, bytes_from_point(params.P), params.sig_lower, params.sig_higher), "The created signature does not pass verification.");
        params.sig = bytes.concat(params.sig_lower, params.sig_higher);
        return params.sig;
    }

    /// @notice Implementation of Schnorr signature verification
    /// @notice Verifies signature of m using public key pubkey
    /// @notice Signature is a 64-bytes value, it is placed in two byte32 variables: sig_higher and sig_lower
    /// @notice sig = sig_higher || sig_lower
    /// @notice Based on reference implementation https://github.com/bitcoin/bips/blob/master/bip-0340/reference.py
    function schnorr_verify(bytes memory m, bytes32 pubkey, bytes32 sig_lower, bytes32 sig_higher) public pure returns (bool) {
        Point memory P = lift_x(int_from_bytes(pubkey));
        uint256 r = int_from_bytes(sig_lower);
        uint256 s = int_from_bytes(sig_higher);
        if (P.inf || (r >= p) || (s >= n)) {
            return false;
        }
        uint256 e = int_from_bytes(tagged_hash("BIP0340/challenge", bytes.concat(sig_lower, pubkey, m))) % n;
        Point memory G = Point(Gx, Gy, false);
        Point memory R = point_add(point_mul(G, s), point_mul(P, n - e));
        if (R.inf || !has_even_y(R) || (R.x != r)) {
            return false;
        }
        return true;
    }


    /// @notice Implementation of Schnorr signature verification
    /// @notice Verifies signature of m using public key pubkey and signature sig
    /// @notice Based on reference implementation https://github.com/bitcoin/bips/blob/master/bip-0340/reference.py
    function schnorr_verify(bytes memory m, bytes32 pubkey, bytes calldata sig) public pure returns (bool) {
        require(sig.length == 64, "The signature must be a 64-byte array");
        return schnorr_verify(m, pubkey, abi.decode(sig[0:32], (bytes32)), abi.decode(sig[32:64], (bytes32)));
    }

    /// @notice Implementation of Schnorr public key generation
    /// @notice Generates public key from secure key seckey
    /// @notice Based on reference implementation https://github.com/bitcoin/bips/blob/master/bip-0340/reference.py
    function pubkey_gen(bytes32 seckey) public pure returns (bytes32) {
        uint256 d0 = int_from_bytes(seckey);
        require((d0 >= 1) && (d0 <= n - 1), "The secret key must be an integer in the range 1..n-1.");
        Point memory G = Point(Gx, Gy, false);
        Point memory P = point_mul(G, d0);
        require(!P.inf);
        return bytes_from_point(P);
    }

}