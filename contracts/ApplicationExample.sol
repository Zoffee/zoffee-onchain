pragma solidity ^0.4.24;

import "./Verifier.sol";

contract ApplicationExample
{
	VerifierInterface internal m_verifier;
	bytes32 internal m_vk;

    constructor( VerifierInterface verifier_address, bytes32 vk )
    {
    	m_verifier = verifier_address;
    	m_vk = vk;
    }

    function SomeActionRequiringProof( bytes32 guid, uint256 some_input )
    	returns (bool)
    {
        return m_verifier.VerifyStatus( m_vk, guid, sha256(abi.encodePacked(some_input, uint256(1234))));
    }
}
