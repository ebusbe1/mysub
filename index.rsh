'reach 0.1';
const [isOutcome, ISWINNER, ISNOTWINNNER] = makeEnum(2)
const seewinner = (Aliceticketnum, Bobsticketnum) => {
  if (Aliceticketnum === Bobsticketnum) {
    return ISWINNER
  } else {
    return ISNOTWINNNER
  }
}
assert(seewinner(1, 1) == ISWINNER)
assert(seewinner(8, 7) == ISNOTWINNNER)
const Alice_func = {
  Nftid: Token,
  winningticketnumber: Fun([], UInt),
  viewhash: Fun([Digest], Null),
  maxnum: Fun([], UInt),
  Api_addresses: Fun([], Array(Address, 5)),
  Api_tickets: Fun([], Array(UInt, 5))
}
export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...hasRandom,
    ...Alice_func
  });
  const Bobs = API('Bobs', {
    enterticket: Fun([UInt], Null)
  });
  init();

  Alice.only(() => {
    const Tokenid = declassify(interact.Nftid)
    const maxnum = declassify(interact.maxnum())
  })
  Alice.publish(Tokenid, maxnum)
  commit()
  Alice.only(() => {
    const _Alicewinticket = interact.winningticketnumber()
    const [_committAlicewinticket, _saltAlicewinticket] = makeCommitment(interact, _Alicewinticket)
    const committAlicewinticket = declassify(_committAlicewinticket)
  })
  Alice.publish(committAlicewinticket)

  const Mapstorage = new Map(Address, UInt)
  const [random_num] =
    parallelReduce([0])
      .invariant(balance(Tokenid) == 0)
      .while(random_num < 5)
      .api(
        Bobs.enterticket,
        (enterticket, notify) => {
          notify(null);
          Mapstorage[this] = enterticket
          return [random_num + 1]
        }
      )
  commit()
  Alice.only(() => {
    const Seehashednumber = declassify(interact.viewhash(committAlicewinticket))
  })
  Alice.publish(Seehashednumber)
  commit()
  Alice.only(() => {
    const saltAlicewinticket = declassify(_saltAlicewinticket)
    const Alicewinticket = declassify(_Alicewinticket)
  })
  Alice.publish(saltAlicewinticket, Alicewinticket)
  checkCommitment(committAlicewinticket, saltAlicewinticket, Alicewinticket)
  commit()
  Alice.only(() => {
    const address = declassify(interact.Api_addresses())
    const tickets = declassify(interact.Api_tickets())
  })
  Alice.publish(address, tickets)
  var [i] = [0]
  invariant(balance(Tokenid) == 0)
  while (i < 5) {
    commit()
    Alice.publish()
    const outcome = seewinner(Alicewinticket, tickets[i])
    if (outcome == ISWINNER) {
      commit()
      Alice.pay([[1, Tokenid]])
      transfer([[1, Tokenid]]).to(address[i])
      i = i + 1
      continue
    } else {
      i = i + 1
      continue
    }
  }
  transfer(balance()).to(Alice)
  commit()
});
