pragma solidity ^0.4.24;


interface VerifierInterface
{
    // Return true if proof is valid and hasn’t been challenged, only returns true after challenge window
    function VerifyStatus( bytes32 vk, uint256 guid, bytes32 inputs_hash ) returns (bool);
}


interface VerificationKeyType
{
    function VerifyProof( uint256[] proof_data, uint256[] inputs );
}


contract Verifier is VerifierInterface
{
    event ProofSubmitted( uint256 guid, bytes32 vk, uint256[] proof, uint256[] inputs );

    function RegisterVerificationKeyType( bytes32 vk_type, VerificationKeyType verifier_contract );

    function RegisterVerificationKey( bytes32 name_or_guid, bytes32 vk_type, uint256[] data );

    // Called by the user, adds the proof to the queue
    // Emits a ‘ProofSubmitted’ event, stores a hash of proof & inputs and generates a GUID
    function SubmitProof( bytes32 vk, uint256[] proof, uint256[] inputs );

    // Retrieve a list of the proof GUIDs that the Off-chain workers needs to verify
    function GetProofs() returns (bytes32[]);

    // Worker submits its attestations for the proofs, these must be submitted in the same order as retrieved from `GetProofs`, it cannot skip any
    function AttestProofs( bytes32[] proof_guids, uint8[] status );

    // Called by an observer, to force the contract to verify the status
    // Function executes on-chain proof and pays out either to original verifier or challenger 
    function ChallengeAttestation( bytes32 guid, uint256[] proof, uint256[] inputs );

    // Return true if proof is valid and hasn’t been challenged, only returns true after challenge window
    function VerifyStatus( bytes32 vk, bytes32 guid, bytes32 inputs_hash ) returns (bool);

    // Called by an account if they want to become a verifier
    // require(msg.value === tokenStake); ensure that account stakes enough tokens
    function BecomeVerifier() returns (bool);
}

