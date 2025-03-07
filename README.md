# RefferalSystem Smart Contract

## 🚀 Overview
The **RefferalSystem Smart Contract** is a decentralized participation system built on Solidity. It allows users to join via referrals, track referrals, and distribute rewards based on referral performance. The contract ensures fair participation and secure reward distribution using ERC-20 tokens.

## 🎯 Features
- **User Participation**: Users must join with a valid referral ID.
- **Referral-Based Rewards**: Users with the highest referrals are rewarded.
- **Automated Reward Distribution**: Rewards are distributed after a fixed time period (24 hours).
- **Secure Transactions**: Implements robust error handling and validations.
- **Owner Profit Collection**: Remaining funds are transferred to the contract owner after distribution.

## 🛠 Technologies Used
- **Solidity (v0.8.2)**
- **Foundry Framework**
- **ERC-20 Interface** for token transfers

## 🔍 Contract Breakdown
### 📜 Smart Contract: `RefferalSystem.sol`

#### **State Variables:**
- `IERC20 MYUSDT`: The ERC-20 token used for participation and rewards.
- `address Owner`: The contract deployer and profit collector.
- `address[] users`: Stores the list of participating users.
- `mapping(address => uint256) userToReffrals`: Tracks user referrals.
- `address[] winners`: Stores the top referrers for reward distribution.
- `uint256 initialTime`: The contract’s start time.
- `uint256 REWARDADTER`: Fixed reward distribution period (24 hours).

#### **Functions:**
- `participate(address reffralId, uint256 amount)`: Allows users to join the system using a referral ID.
- `Reward()`: Distributes rewards to top referrers and transfers remaining funds to the owner.
- **Getter Functions:**
  - `GetUser(uint256 index)`: Retrieves a specific user from the list.
  - `GetWinner(uint256 index)`: Retrieves a specific winner.
  - `GetReffralCount(address user)`: Returns the number of referrals for a user.
  - `GetOwner()`: Returns the contract owner’s address.
  - `getRewardDate()`: Returns the reward distribution period.

## 📥 Installation & Setup
### Prerequisites
- **Foundry** installed:
  ```sh
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **Node.js & npm** (optional, for additional tooling)

### Clone the Repository
```sh
git clone https://github.com/Elmirataghinasab/pyramidRefferal-CustomToken.git
cd pyramidRefferal-CustomToken
```

### Install Dependencies
```sh
forge install
```

### Compile the Contract
```sh
forge build
```

### Run Tests
```sh
forge test
```


## 🧪 Testing
This project includes **unit tests and fuzz tests** written using Foundry’s testing framework.
To run all tests:
```sh
forge test --gas-report
```

## 🤝 Contribution
1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature-branch`)
5. Open a pull request

## 📝 License
This project is licensed under the **MIT License**.

## 📩 Contact
For any questions or suggestions, feel free to reach out via GitHub Issues or email: **taghinasab8395@gmail.com**.

---
🚀 **Happy Coding!** ✨

