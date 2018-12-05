pragma solidity ^0.4.24;

import "./Interfaces.sol";

contract Zoffee is Zoffee_VerifierInterface
{

    /**
    * A proof has been submitted by a user, which needs to be verified by the off-chain worker
    */
    event OnProofSubmitted( bytes32 guid, Zoffee_ProofVerifier verifier, uint256[] proof, uint256[] inputs );


    /**
    * A new proof verifier contract has been registered
    */
    event OnVerifierRegistered( Zoffee_ProofVerifier verifier );


    /**
    * Notifies the worker that a new verification key has been registered for a validator contract
    *
    * @param verifier Contract which can verify proofs
    * @param key_data_hash Hash of the key data
    */
    event OnKeyRegistered( Zoffee_ProofVerifier verifier, bytes32 key_data_hash );


    /**
    * Register a verifier type, this is a contract which can be used to validate a verification key
    * and then validate a proof for a specific verification key.
    *
    * emits OnVerifierRegistered
    *
    * @param verifier Implements the `Zoffee_ProofVerifier` interface
    */
    function RegisterVerifier( Zoffee_ProofVerifier verifier ) public;


    /**
    * Register a key to be used for verification
    *
    * It is associated with a verifier, which will be used to validate the `key_data`.
    * The `verifier` contract must have been previously registered.
    *
    * emits OnKeyRegistered
    *
    * @param verifier Contract used to verify the proofs
    * @param key_data Auxilliary data used by the verifier to validate proofs
    */
    function RegisterKey( Zoffee_ProofVerifier verifier, uint256[] key_data ) public;


    /**
    * Called by the user, adds the proof to the queue
    * Emits a OnProofSubmitted event, stores a hash of proof & inputs and generates a GUID
    * The proof data and inputs aren't stored, only their hash
    *
    * Reverts if `vk` is unknown
    *
    * Emits OnProofSubmitted with details of the proof
    *
    * @param vk GUID of the key must be used to verify the proof
    * @param proof Proof data
    * @param inputs Public inputs for the proof
    */
    function SubmitProof( bytes32 vk, uint256[] proof, uint256[] inputs ) public;


    /**
    * Retrieve a list of the proof GUIDs that the off-chain workers needs to verify
    *
    * These must be processed in-sequence by the worker, until the worker has attested the block of proofs
    * which was previously requested it will get the same block of proofs to verify.
    *
    * @return List of proof GUIDs
    */
    function GetProofs() public returns (bytes32[]);


    /**
    * Worker submits its attestations for the proofs, these must be submitted in the same
    * order as retrieved from `GetProofs`, it cannot skip any
    */
    function AttestProofs( bytes32[] proof_guids, uint8[] status ) public;


    /**
    * Called by an observer, to force the contract to verify the status
    * Function executes on-chain proof and pays out either to original verifier or challenger 
    */
    function ChallengeAttestation( bytes32 guid, uint256[] proof, uint256[] inputs ) public;


    /**
    * Return true if proof is valid and hasn’t been challenged, only returns true after challenge window
    */
    function VerifyStatus( bytes32 vk, bytes32 guid, bytes32 inputs_hash ) public returns (bool);


    /**
    * Called by an account if they want to become a verifier
    * require(msg.value === tokenStake); ensure that account stakes enough tokens
    */
    function BecomeVerifier() public returns (bool);

}

