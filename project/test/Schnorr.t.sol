// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Schnorr} from "../src/Schnorr.sol";

contract CounterTest is Test {
    Schnorr public schnorr;

    function setUp() public {
        schnorr = new Schnorr();
    }

    function test_schnorr_sign_message() public view {
        uint256 aux_rand = 100;
        bytes memory signature = schnorr.schnorr_sign(bytes("Message"), bytes("Key"), bytes32(aux_rand));
        assertEq(signature, hex"7ddb86e790e6587aa195047342092b6c77b76946b4dfd576594becd995bdf7ad61df0091cd61ecc26b0a9ca7ff5ee158e31ecd6fe2239f2dd4f69f0959daf684");
    }

    function test_schnorr_sign_0() public view {
        bytes32 seckey = 0x0000000000000000000000000000000000000000000000000000000000000003;
        bytes32 aux_rand = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes32 m = 0x0000000000000000000000000000000000000000000000000000000000000000;

        bytes memory signature = schnorr.schnorr_sign(abi.encodePacked(m), abi.encodePacked(seckey), aux_rand);

        assertEq(signature, hex"E907831F80848D1069A5371B402410364BDF1C5F8307B0084C55F1CE2DCA821525F66A4A85EA8B71E482A74F382D2CE5EBEEE8FDB2172F477DF4900D310536C0");
    }


    function test_schnorr_sign_1() public view {
        bytes32 seckey = 0xB7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF;
        bytes32 aux_rand = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 m = 0x243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89;

        bytes memory signature = schnorr.schnorr_sign(abi.encodePacked(m), abi.encodePacked(seckey), aux_rand);

        assertEq(signature, hex"6896bd60eeae296db48a229ff71dfe071bde413e6d43f917dc8dcf8c78de33418906d11ac976abccb20b091292bff4ea897efcb639ea871cfa95f6de339e4b0a");
    }

    function test_schnorr_sign_2() public view {
        bytes32 seckey = 0xC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B14E5C9;
        bytes32 aux_rand = 0xC87AA53824B4D7AE2EB035A2B5BBBCCC080E76CDC6D1692C4B0B62D798E6D906;
        bytes32 m = 0x7E2D58D8B3BCDF1ABADEC7829054F90DDA9805AAB56C77333024B9D0A508B75C;

        bytes memory signature = schnorr.schnorr_sign(abi.encodePacked(m), abi.encodePacked(seckey), aux_rand);

        assertEq(signature, hex"5831AAEED7B44BB74E5EAB94BA9D4294C49BCF2A60728D8B4C200F50DD313C1BAB745879A5AD954A72C45A91C3A51D3C7ADEA98D82F8481E0E1E03674A6F3FB7");
    }

    function test_schnorr_sign_3() public view {
        bytes32 seckey = 0x0B432B2677937381AEF05BB02A66ECD012773062CF3FA2549E44F58ED2401710;
        bytes32 aux_rand = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        bytes32 m = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        bytes memory signature = schnorr.schnorr_sign(abi.encodePacked(m), abi.encodePacked(seckey), aux_rand);

        assertEq(signature, hex"7EB0509757E246F19449885651611CB965ECC1A187DD51B64FDA1EDC9637D5EC97582B9CB13DB3933705B32BA982AF5AF25FD78881EBB32771FC5922EFC66EA3");
    }


    function test_schnorr_verify_0() public view {
        bytes32 pubkey = 0xF9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9;
        bytes32 m = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes memory sig = hex"E907831F80848D1069A5371B402410364BDF1C5F8307B0084C55F1CE2DCA821525F66A4A85EA8B71E482A74F382D2CE5EBEEE8FDB2172F477DF4900D310536C0";

        bool result = schnorr.schnorr_verify(abi.encodePacked(m), pubkey, sig);

        assertEq(result, true);
    }

    function test_schnorr_verify_5() public view {
        bytes32 pubkey = 0xEEFDEA4CDB677750A420FEE807EACF21EB9898AE79B9768766E4FAA04A2D4A34;
        bytes32 m = 0x243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89;
        bytes memory sig = hex"6CFF5C3BA86C69EA4B7376F31A9BCB4F74C1976089B2D9963DA2E5543E17776969E89B4C5564D00349106B8497785DD7D1D713A8AE82B32FA79D5F7FC407D39B";

        bool result = schnorr.schnorr_verify(abi.encodePacked(m), pubkey, sig);

        assertEq(result, false);
    }

    function test_pubkey_gen_0() public view {
        bytes32 seckey = 0x0000000000000000000000000000000000000000000000000000000000000003;
        bytes32 pubkey = 0xF9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9;

        bytes32 result = schnorr.pubkey_gen(seckey);

        assertEq(pubkey, result);
    }

}
