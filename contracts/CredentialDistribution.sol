// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DistributeCredentials {
    // contract owner address, universities/educational institutions
    address public issuer;

    // struct to define the structure of the distribute credentials contract
    struct CredentialsData {
        address issuer;
        uint256 studentId;
        string studentName;
        string institution;
        string qualification; 
        string dateIssued;
        bytes32 signature
    }
    
    // mapping to store credential contract information
    mapping (uint256 => CredentialsData) public credentials;

    // Counter to keep track of the total number of credentials issued
    uint256 public credentialsCount;

    // event triggered when a new credential is distributed
    event CredentialsIssued(uint256 credentialID, address issuer, uint256 studentId, string studentName, string institution, string qualification, string dateIssued);

    // contract constructor dont need one?
    constructor() {
        issuer = msg.sender;
    }

    // restrict acess to only the university
    modifier onlyIssuer(){
        require(msg.sender == issuer, "Only the university issuer can execute this");
        _;
    }

    // issue credential function
    function issueCredential(uint256 memory studentId, string memory studentName, string memory institution, string memory qualification, string memory dateIssued) public onlyIssuer {
        credentialsCount++;   
        // store credential
        credentials[credentialsCount] = CredentialsData(issuer, studentId, studentName, institution, qualification, dateIssued);
        emit CredentialsIssued(credentialsCount, issuer, studentId, studentName, institution, qualification, dateIssued);
    }

}
