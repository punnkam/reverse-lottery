// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ReverseLottery {
    address public owner;
    address[] public players;
    mapping(address => bool) public isEliminated;
    mapping(address => uint256) public playerBalances;
    mapping(address => uint256) public lockupCounter;
    uint256 public depositAmount;
    uint256 public roundStart;
    uint256 public roundDuration;

    constructor(uint _roundDuration) {
        owner = msg.sender;
        roundDuration = _roundDuration;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function deposit(uint256 lockupPeriod) public payable {
        require(msg.value == depositAmount, "Incorrect deposit amount.");
        require(
            block.timestamp >= roundStart && block.timestamp <= roundStart + roundDuration,
            "Round is closed."
        );
        require(lockupPeriod > 0, "Lockup period must be greater than 0.");
        require(
            lockupCounter[msg.sender] == 0,
            "Cannot deposit more than once during a round."
        );
        players.push(msg.sender);
        playerBalances[msg.sender] = msg.value;
        lockupCounter[msg.sender] = lockupPeriod;
    }

    function eliminatePlayer() public onlyOwner {
        require(players.length > 1, "Cannot eliminate last player.");
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.number - 1
                )
            )
        ) % (players.length - 1);
        address eliminatedPlayer = players[randomIndex];
        isEliminated[eliminatedPlayer] = true;
        for (uint256 i = randomIndex; i < players.length - 1; i++) {
            players[i] = players[i + 1];
        }
        delete players[players.length - 1];
        for (uint256 i = 0; i < players.length; i++) {
            playerBalances[players[i]] += depositAmount / players.length;
        }
    }

    function startRound() public onlyOwner {
        roundStart = block.timestamp;
    }

    function endRound() public onlyOwner {
        require(block.timestamp >= roundStart + roundDuration, "Round is not yet over.");
        eliminatePlayer();
        startRound();
    }

    function withdraw() public {
        require(
            block.timestamp > roundStart + roundDuration,
            "Cannot withdraw before the end of the round."
        );
        require(
            lockupCounter[msg.sender] == 0,
            "Lockup period has not ended yet."
        );
        uint256 amount = playerBalances[msg.sender];
        playerBalances[msg.sender] = 0;
        lockupCounter[msg.sender] = 0;
        // msg.sender.transfer(amount);
        // Transfer amount to msg.sender
        
    }
}
