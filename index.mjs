import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';



const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance)
const [one, two, three, four, five] = await stdlib.newTestAccounts(5, startingBalance);
const Ebusnft = await stdlib.launchToken(accAlice, "ebus", "ebus1", { supply: 1 });

const ctcAlice = accAlice.contract(backend);

const address_list = []
const ticket_list = []
const Enterticket = async (acc, rafflenum) => {
  try {
    const ctc = acc.contract(backend, ctcAlice.getInfo());
    const r = parseInt(rafflenum)
    acc.tokenAccept(Ebusnft.id)
    const address = acc.getAddress()
    address_list.push(address)
    ticket_list.push(r)
    await ctc.apis.Bobs.enterticket(r);
  } catch (error) {
    console.log(error);
  }

}
const getNFTBalance = async (who, names) => {
  const NFTamt = await stdlib.balanceOf(who, Ebusnft.id);
  console.log(`${names} has ${NFTamt} of the NFT`);
};

console.log('Starting backends...');
await getNFTBalance(accAlice, 'Alice')
await getNFTBalance(one, 'Dike')
await getNFTBalance(two, 'Darren')
await getNFTBalance(three, 'Damian')
await getNFTBalance(four, 'Dante')
await getNFTBalance(five, 'Damini')


await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    Nftid: Ebusnft.id,
    winningticketnumber: async () => {
      return parseInt(12)
    },
    viewhash: async (hash) => {
      console.log(`hash value: ${hash}`)
    },
    maxnum: async () => {
      console.log(`The highest ticket number is 30`)
      return parseInt(30)
    },
    Api_addresses: async () => {
      return address_list
    },
    Api_tickets: async () => {
      return ticket_list
    },
  }),
  await Enterticket(one, 17),
  await Enterticket(two, 12),
  await Enterticket(three, 15),
  await Enterticket(four, 18),
  await Enterticket(five, 23),

]);
await getNFTBalance(accAlice, 'Alice')
await getNFTBalance(one, 'Dike')
await getNFTBalance(two, 'Darren')
await getNFTBalance(three, 'Damian')
await getNFTBalance(four, 'Dante')
await getNFTBalance(five, 'Damini')
console.log('Thanks for joining the raffle!!!')
process.exit()
