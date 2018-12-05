pragma solidity ^0.4.24;


interface Zoffee_VerifierInterface
{
    // Return true if proof is valid and hasn’t been challenged, only returns true after challenge window
    function IsProofValid( bytes32 vk, bytes32 guid, bytes32 inputs_hash ) external returns (bool);
}


interface Zoffee_ProofVerifier
{
    /**
    * Check whether or not a proving key is valid and can be used to verify proofs
    */
    function IsValidationKeyValid( uint256[] data ) external returns (bool);

    /**
    * Check if the proof data is valid for a specific validation key
    */
    function IsProofValid( uint256[] key_data, uint256[] proof_data, uint256[] inputs ) external returns (bool);
}
