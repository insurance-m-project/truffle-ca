// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract MedicalRecord {
    struct TreatmentDetail {
        string category;
        string date;
        string treatCode;
        string description;
        uint256 price;
        uint256 oop;
        uint256 pcc;
        uint256 foop;
        uint256 nonReimbursement;
    }

    struct MedicalRecordData {
        string name;
        string RRN;
        string KCD;
        string date;
        string receiptNumber;
        uint256 totalOop;
        uint256 totalPcc;
        uint256 totalFoop;
        uint256 nonReimbursement;
        TreatmentDetail[] treatDetails;
        uint256 treatDetailsCount;
    }

    // attribute
    string private constant DEFAULT_KCD = "J09"; // 디폴트 RRN 값
    mapping(string => MedicalRecordData) private medicalRecords;
    uint256 public medicalRecordsCount;
    string[] private medicalRecordKeys; 
    
    // event
    event MedicalRecordSet(
        string name,
        string RRN,
        string KCD,
        string date,
        string receiptNumber,
        uint256 totalOop,
        uint256 totalPcc,
        uint256 totalFoop,
        uint256 nonReimbursement,
        TreatmentDetail[] treatDetails
    );

    // 보험사 청구 데이터 저장
    function addMedicalRecord(
        string memory _name,
        string memory _RRN,
        string memory _KCD,
        string memory _date,
        string memory _receiptNumber,
        uint256 _totalOop,
        uint256 _totalPcc,
        uint256 _totalFoop,
        uint256 _nonReimbursement,
        TreatmentDetail[] memory _treatDetails
    ) public {
        require(keccak256(bytes(_KCD)) == keccak256(bytes(DEFAULT_KCD)), "KCD does not match");
        require(bytes(medicalRecords[_receiptNumber].name).length == 0, "Receipt number already exists");

        MedicalRecordData storage record = medicalRecords[_receiptNumber];
        record.name = _name;
        record.RRN = _RRN;
        record.KCD = _KCD;
        record.date = _date;
        record.receiptNumber = _receiptNumber;
        record.totalOop = _totalOop;
        record.totalPcc = _totalPcc;
        record.totalFoop = _totalFoop;
        record.nonReimbursement = _nonReimbursement;

        for (uint256 i = 0; i < _treatDetails.length; i++) {
            record.treatDetails.push(_treatDetails[i]);
        }
        record.treatDetailsCount = _treatDetails.length;
        
        // getter를 위해
				medicalRecordKeys.push(_receiptNumber);
				medicalRecordsCount++;
        
        emit MedicalRecordSet(_name, _RRN, _KCD, _date, _receiptNumber, _totalOop, _totalPcc, _totalFoop, _nonReimbursement, _treatDetails);
    }
  

    function getMedicalRecord(string memory _receiptNumber) public view returns (MedicalRecordData memory) {
        return medicalRecords[_receiptNumber];
    }
    
    function getMedicalRecords() public view returns (MedicalRecordData[] memory){
		    MedicalRecordData[] memory records = new MedicalRecordData[](medicalRecordsCount);
				for (uint256 i = 0; i < medicalRecordKeys.length; i++) {
						records[i] = medicalRecords[medicalRecordKeys[i]];
				}
				return records;
    }
}

