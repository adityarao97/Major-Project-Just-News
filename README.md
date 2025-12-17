# Just News — Major Project

**Just News** is the backend infrastructure for a decentralized news application, combining machine learning and blockchain smart contracts to support verifiable, transparent news scoring, storage, and user interaction. This repository contains the backend smart contract logic, machine-learning scoring utilities, and test framework used in the project.

---

## Motivation

News authenticity and quality scoring are critical challenges in the modern web. **Just News** aims to provide an infrastructure where news articles can be evaluated, scored, and stored with integrity and traceability using both machine learning and smart contracts.

This repository implements:

- A machine learning scoring module (`MLScore`)
- Smart contracts for decentralized storage and event tracking (`contracts`)
- Deployment and testing scripts for contract lifecycle management

---

## Project Overview

**Just News** backend consists of:

1. **ML Scoring Engine**  
   A Python-based utility that analyzes news content and generates a quality or relevance score. (Replace with your exact algorithm: classification, summarization, sentiment, etc.)

2. **Smart Contracts**  
   Solidity contracts that define how news items, user actions, and scores are stored/managed on a blockchain network (Ethereum / testnet / local).

3. **Deployment Scripts**  
   `compile.js` and `deploy.js` for compiling and deploying contracts.

4. **Automated Test Suite**  
   Unit and integration tests validating contract behavior under expected usage patterns.

---

## Architecture

```text
+-----------------------+       +---------------------+
| News Input / Client   |       | Blockchain Network  |
| (Web / API / UI)      |       | (Local / Testnet)   |
+-----------+-----------+       +----------+----------+
            |                                ^
            v                                |
+-----------+------------+   Transactions   +---------+
| Backend API / Server   | <--------------> | Smart   |
| (Node.js / Python)     |                  | Contracts|
+------------------------+                  +---------+
            ^
            |
            +-- ML Scoring Engine (Python)                  
