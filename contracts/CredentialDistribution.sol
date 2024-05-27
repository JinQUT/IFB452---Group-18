// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DistributeCredentials {
    // Address of the issuer (university or educational institution)
    address public issuer;

    // Structure defining the credentials
    struct CredentialsData {
        address issuer;           // Ethereum address of the issuing institution
        address studentAddress;   // Ethereum address of the student set manually
        string studentName;       // Name of the student
        string institution;       // Name of the educational institution
        string qualification;     // Details of the qualification awarded
        string dateIssued;        // Date when the credential was issued
        bytes32 signature;        // Cryptographic signature validating the credential
    }

    // Mapping of student ID to their credentials
    mapping (uint256 => CredentialsData) public credentials;

    // Event triggered when new credentials are issued
    event CredentialsIssued(uint256 studentId, address studentAddress, string studentName, string institution, string qualification, string dateIssued);

    // Constructor to set the issuer as the contract deployer
    constructor() {
        issuer = msg.sender;
    }

    // Modifier to restrict function access to the issuer only
    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only the registered institution issuer can execute this");
        _;
    }

    // Function to issue credentials
    function issueCredential(uint256 studentId, address studentAddress, string memory studentName, string memory institution, string memory qualification, string memory dateIssued, bytes32 signature) public onlyIssuer {
        require(studentAddress != address(0), "Invalid student address");
        require(studentAddress != issuer, "Issuer address cannot be used for a student");
        credentials[studentId] = CredentialsData(issuer, studentAddress, studentName, institution, qualification, dateIssued, signature);
        emit CredentialsIssued(studentId, studentAddress, studentName, institution, qualification, dateIssued);
    }

    // Function to retrieve complete credential data for a given studentId
    function getCredentials(uint256 studentId) public view returns (
        address studentAddress, 
        string memory studentName, 
        string memory institution, 
        string memory qualification, 
        string memory dateIssued, 
        bytes32 signature
    ) {
        CredentialsData storage data = credentials[studentId];
        return (
            data.studentAddress,
            data.studentName,
            data.institution,
            data.qualification,
            data.dateIssued,
            data.signature
        );
    }
}
