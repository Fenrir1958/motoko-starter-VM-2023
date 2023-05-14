import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Order "mo:base/Order";

actor class StudentWall() {
  //1.
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;
  //2.
  var messageId : Nat = 0;
  //3.
  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };
  let wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, natHash);

  type Order = { #less; #equal; #greater };

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    messageId += 1;
    wall.put(messageId, message);
    return messageId;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let message = wall.get(messageId);
    switch (message) {
      case (?msg) {
        return #ok(msg);
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch (message) {
      case (?msg) {
        if (not Principal.equal(caller, msg.creator)) {
          return #err("not implemented");
        };
        let newMessage = {
          content = c;
          vote = msg.vote;
          creator = caller;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok();
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch (message) {
      case (?msg) {
        wall.delete(messageId);
        return #ok(());
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch (message) {
      case (?msg) {
        let newMessage = {
          content = msg.content;
          vote = msg.vote + 1;
          creator = msg.creator;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok(());
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch (message) {
      case (?msg) {
        let newMessage = {
          content = msg.content;
          vote = msg.vote - 1;
          creator = msg.creator;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok();
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let arrayMessages = Iter.toArray<Message>(wall.vals());
    return arrayMessages;
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let arrayOrderMessages = Iter.toArray<Message>(wall.vals());
    let xd = Array.sort(
      arrayOrderMessages,
      func(x : Message, y : Message) : Order {
        if (x.vote > y.vote) { return #less } else if (x.vote < y.vote) {
          return #greater;
        };
        return #equal;
      },
    );
    return arrayOrderMessages;
  };
};
