pragma solidity ^0.4.24;

import "./Interfaces.sol";


contract ApplicationExample
{
	Zoffee_VerifierInterface internal m_verifier;
	bytes32 internal m_vk;

    constructor( Zoffee_VerifierInterface verifier_address, bytes32 vk )
        public
    {
    	m_verifier = verifier_address;
    	m_vk = vk;
    }

    function SomeActionRequiringProof( bytes32 guid, uint256 some_input )
    	public returns (bool)
    {
        return m_verifier.IsProofValid( m_vk, guid, sha256(abi.encodePacked(some_input, uint256(1234))));
    }
}
