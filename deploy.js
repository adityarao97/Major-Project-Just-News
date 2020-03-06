const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletProvider(
    'paddle toddler chair liar best twenty public cloth common bundle tribe area',
    'https://rinkeby.infura.io/v3/f6d1bd1fb6a643878ff7ab708bcde8b7'
)

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  console.log('Attempting to deploy from account ', accounts[0]);
  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: '0x'+bytecode })
    .send({ gas: '10000000', from: accounts[0] });
  console.log(interface);
  console.log('Contract deployed to ', result.options.address);
};

deploy()