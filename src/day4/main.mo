import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
// import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  public type Account = Account.Account;
  let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  let bootcampLocalActor = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  };
  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    // let bootcampLocalActor = await BootcampLocalActor.BootcampLocalActor();
    let studentAccount = await bootcampLocalActor.getAllStudentsPrincipal();
    if (studentAccount.size() > 0) {
      for (principal in studentAccount.vals()) {
        let account = {
          owner = principal;
          subaccount = null;
        };
        ledger.put(account, 100);
      };
      return #ok(());
    };
    return #err("not implemented");
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var totalTokens = 0;
    for (tokens in ledger.vals()) {
      totalTokens += tokens;
    };
    return totalTokens;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    switch (ledger.get(account)) {
      case (?tokens) {
        return tokens;
      };
      case (null) {
        return 0;
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
    switch (ledger.get(from)) {
      case (?accTokens1) {
        switch (ledger.get(to)) {
          case (?accTokens2) {
            var newTokens1 = accTokens1;
            var newTokens2 = accTokens2;
            if (newTokens1 > amount) {
              newTokens1 -= amount;
              newTokens2 += amount;
              ignore ledger.replace(from, newTokens1);
              ignore ledger.replace(to, newTokens2);
              return #ok();
            };
            return #err("tokens are not enough");
          };
          case (null) {
            return #err("account does not exist");
          };
        };
      };
      case (null) {
        return #err("account does not exist");
      };
    };
  };
};
