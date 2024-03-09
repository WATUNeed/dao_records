// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRecord} from "./IRecord.sol";

contract Record {
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;

    mapping (uint => mapping (address => mapping (uint => address))) private _records;
    mapping (uint => bool) private _validPoints;
    mapping (address => uint) private _employeeSalaries;
    mapping (uint => address) private _clientRecordsDatetime;
    mapping (uint => uint) private _recordCosts;

    constructor() {}

    function createPoint(uint point) external {
        if (_validPoints[point]) {
            revert("Already exists");
        }
        _validPoints[point] = true;
    }

    function getPoint(uint point, address employee, uint timestamp) public view returns (address client) {
        client = _records[point][employee][timestamp / SECONDS_PER_DAY];
    }

    function createRecord(address client, address employee, uint point, uint timestamp) external payable  {
        address recorded_client = _records[point][employee][timestamp / SECONDS_PER_DAY];
        require(recorded_client == address(0), "Client already recorded today.");
        _records[point][employee][timestamp / SECONDS_PER_DAY] = client;
    }

    function test(uint timestamp) public pure returns (uint) {
        return timestamp / SECONDS_PER_DAY;
    }

    function recordExistsToday(address client) external view returns (bool) {
        return false;
    }

    function paid(address employee, uint amount) external {

    }
}