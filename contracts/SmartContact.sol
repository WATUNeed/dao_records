// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISmartContact} from "./ISmartContact.sol";

library IterableMapping {
    // Iterable mapping from address to record;
    struct Record {
        address employee;
        uint32 service;
        bool valid;
    }

    struct Map {
        address[] keys;
        mapping(address => Record) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (Record memory) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint256 index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(Map storage map, address key, Record memory val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        address lastKey = map.keys[map.keys.length - 1];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract SmartContact {
    using IterableMapping for IterableMapping.Map;
    using IterableMapping for IterableMapping.Record;

    uint128 constant private SECONDS_PER_DAY = 24 * 60 * 60;

//    {timestamp: {client: Record}}
    mapping (uint128 => IterableMapping.Map) private _records;

    mapping (address => uint) private _employeeSalaries;
    mapping (uint32 => uint256) private _serviceCosts;

    constructor() {}

    function joinEmployee(
        uint256 per_record,
        address employee
    ) external {
        if (_employeeSalaries[employee] > 0) {
            revert("Already exists");
        }
        if (per_record == uint256(0)) {
            revert("Employee celery cannot be zero.");
        }
        _employeeSalaries[employee] = per_record;
    }

    function recordExists(
        address employee,
        address client,
        uint128 timestamp
    )
    public view returns (
        bool exists
    ) {
        IterableMapping.Record memory record = _records[timestamp / SECONDS_PER_DAY].get(client);
        exists = record.valid || record.employee == employee;
    }

    function serviceCreate(
        uint32 service,
        uint cost
    ) external {
        require(cost > uint256(0), "Cost cannot be zero.");

        _serviceCosts[service] = cost;
    }

    function createRecord(
        address client,
        address employee,
        uint128 timestamp,
        uint32 service
    ) external payable {
        IterableMapping.Record memory record = _records[timestamp / SECONDS_PER_DAY].get(client);
        uint service_cost = _serviceCosts[service];

        if (record.valid == true) {
            revert("Client already recorded today.");
        }
        require(_employeeSalaries[employee] > uint256(0), "Employee not found.");
        require(service_cost > uint256(0), "Service not found.");
        require(msg.value >= service_cost, "Insufficient funds for the service.");

        _records[timestamp / SECONDS_PER_DAY].set(client, IterableMapping.Record(employee, service, true));
    }

    function paidCelery() external {
        if (_employeeSalaries[msg.sender] < 0) {
            revert("Emoployee not fount.");
        }
        uint sumToPay;
        for (uint128 timestamp = 1704052800; timestamp < uint128(block.timestamp); timestamp + SECONDS_PER_DAY) {
            for (uint256 i = 0; i < _records[timestamp / SECONDS_PER_DAY].size(); i++) {
                address key = _records[timestamp / SECONDS_PER_DAY].getKeyAtIndex(i);
                IterableMapping.Record memory record = _records[timestamp / SECONDS_PER_DAY].get(key);
                if (record.employee == msg.sender) {
                    sumToPay += _employeeSalaries[msg.sender];
                }
            }
        }
        payable(msg.sender).transfer(sumToPay);
    }
}