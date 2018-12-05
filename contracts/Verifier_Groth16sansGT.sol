pragma solidity ^0.4.24;

import "./Interfaces.sol";

contract Verifier_Groth16withoutGT is Zoffee_ProofVerifier
{
    function IsValidationKeyValid( uint256[] data )
        external returns (bool)
    {
        return data.length >= 15;
    }


    function IsProofValid( uint256[] key_data, uint256[] proof_data, uint256[] proof_inputs )
        external returns (bool)
    {
        require( proof_data.length == 8 );

        return Verify(key_data, proof_data, proof_inputs);
    }


    function NegateY( uint256 Y )
        internal pure returns (uint256)
    {
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return q - (Y % q);
    }


    /*
    * This implements the Solidity equivalent of the following Python code:

        from py_ecc.bn128 import *
        data = # ... arguments to function [in_vk, vk_gammaABC, in_proof, proof_inputs]
        vk = [int(_, 16) for _ in data[0]]
        ic = [FQ(int(_, 16)) for _ in data[1]]
        proof = [int(_, 16) for _ in data[2]]
        inputs = [int(_, 16) for _ in data[3]]
        it = iter(ic)
        ic = [(_, next(it)) for _ in it]
        vk_alpha = [FQ(_) for _ in vk[:2]]
        vk_beta = (FQ2(vk[2:4][::-1]), FQ2(vk[4:6][::-1]))
        vk_gamma = (FQ2(vk[6:8][::-1]), FQ2(vk[8:10][::-1]))
        vk_delta = (FQ2(vk[10:12][::-1]), FQ2(vk[12:14][::-1]))
        assert is_on_curve(vk_alpha, b)
        assert is_on_curve(vk_beta, b2)
        assert is_on_curve(vk_gamma, b2)
        assert is_on_curve(vk_delta, b2)
        proof_A = [FQ(_) for _ in proof[:2]]
        proof_B = (FQ2(proof[2:4][::-1]), FQ2(proof[4:-2][::-1]))
        proof_C = [FQ(_) for _ in proof[-2:]]
        assert is_on_curve(proof_A, b)
        assert is_on_curve(proof_B, b2)
        assert is_on_curve(proof_C, b)
        vk_x = ic[0]
        for i, s in enumerate(inputs):
            vk_x = add(vk_x, multiply(ic[i + 1], s))
        check_1 = pairing(proof_B, proof_A)
        check_2 = pairing(vk_beta, neg(vk_alpha))
        check_3 = pairing(vk_gamma, neg(vk_x))
        check_4 = pairing(vk_delta, neg(proof_C))
        ok = check_1 * check_2 * check_3 * check_4
        assert ok == FQ12.one()
    */
    function Verify ( uint256[] key_data, uint256[] in_proof, uint256[] proof_inputs )
        internal view returns (bool)
    {
        require( in_proof.length == 8 );
        require( (((key_data.length - 14) / 2) - 1) == proof_inputs.length );

        // Compute the linear combination vk_x
        uint256[3] memory mul_input;
        uint256[4] memory add_input;
        bool success;
        uint m = 16;

        // First two fields are used as the sum
        add_input[0] = key_data[14];
        add_input[1] = key_data[15];

        // Performs a sum of gammaABC[0] + sum[ gammaABC[i+1]^proof_inputs[i] ]
        for (uint i = 0; i < proof_inputs.length; i++) {
            mul_input[0] = key_data[m++];
            mul_input[1] = key_data[m++];
            mul_input[2] = proof_inputs[i];

            assembly {
                // ECMUL, output to last 2 elements of `add_input`
                success := staticcall(sub(gas, 2000), 7, mul_input, 0x80, add(add_input, 0x40), 0x60)
            }
            require( success );

            assembly {
                // ECADD
                success := staticcall(sub(gas, 2000), 6, add_input, 0xc0, add_input, 0x60)
            }
            require( success );
        }

        uint[24] memory input = [
            // (proof.A, proof.B)
            in_proof[0], in_proof[1],                               // proof.A   (G1)
            in_proof[2], in_proof[3], in_proof[4], in_proof[5],     // proof.B   (G2)

            // (-vk.alpha, vk.beta)
            key_data[0], NegateY(key_data[1]),                      // -vk.alpha (G1)
            key_data[2], key_data[3], key_data[4], key_data[5],     // vk.beta   (G2)

            // (-vk_x, vk.gamma)
            add_input[0], NegateY(add_input[1]),                    // -vk_x     (G1)
            key_data[6], key_data[7], key_data[8], key_data[9],     // vk.gamma  (G2)

            // (-proof.C, vk.delta)
            in_proof[6], NegateY(in_proof[7]),                      // -proof.C  (G1)
            key_data[10], key_data[11], key_data[12], key_data[13]  // vk.delta  (G2)
        ];

        uint[1] memory out;
        assembly {
            success := staticcall(sub(gas, 2000), 8, input, 768, out, 0x20)
        }
        require(success);
        return out[0] != 0;
    }
}