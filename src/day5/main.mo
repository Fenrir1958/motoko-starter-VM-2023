import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";

import IC "Ic";
import HTTP "Http";
import Type "Types";
import Bool "mo:base/Bool";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  stable var entries : [(Principal, StudentProfile)] = [];
  let studentProfileStore = HashMap.fromIter<Principal, StudentProfile>(entries.vals(), 10, Principal.equal, Principal.hash);

  system func preupgrade() {
    entries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    entries := [];
  };
  // type Ic = IC.CanisterSettings;

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    if (profile.name == "" or profile.Team == "" or profile.graduate == false) {
      studentProfileStore.put(caller, profile);
      return #ok();
    };
    return #err("not implemented");
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let studentProfile = studentProfileStore.get(p);
    switch (studentProfile) {
      case (?studentP) {
        return #ok(studentP);
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let studentProfile = studentProfileStore.get(caller);
    switch (studentProfile) {
      case (?studentP) {
        ignore studentProfileStore.replace(caller, profile);
        return #ok();
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let studentProfile = studentProfileStore.get(caller);
    switch (studentProfile) {
      case (?studentP) {
        studentProfileStore.delete(caller);
        return #ok();
      };
      case (null) {
        return #err("not implemented");
      };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  // type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculatorInterface = actor (Principal.toText(canisterId)) : actor {
        reset : shared () -> async Int;
        add : shared (x : Nat) -> async Int;
        sub : shared (x : Nat) -> async Int;
        };
    // let calculate : calculatorInterface = actor (Principal.toText(canisterId));
    try {
      var reset = await calculatorInterface.reset();
      if (reset != 0) {
        return #err(#UnexpectedValue("not implemented"));
      };
      var add = await calculatorInterface.add(1);
      if (add != 1) {
        return #err(#UnexpectedValue("not implemented"));
      };
      var sub = await calculatorInterface.sub(1);
      if (sub != 0) {
        return #err(#UnexpectedValue("not implemented"));
      };
      return #ok();
    } catch (e) {
      return #err(#UnexpectedError("not implemented"));
    };
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally

  private func _parseCanisterControllers(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    try {
      let controllers : IC.ManagementCanisterInterface = actor ("aaaaa-aa");
      let callCanister = await controllers.canister_status({
        canister_id = canisterId;
      });
      return false;
    } catch (e) {
      let message = Error.message(e);
      let callCanisterController = _parseCanisterControllers(message);
      for (controller in callCanisterController.vals()) {
        if (controller == p) {
          return true;
        };
      };
      return false;
    };
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let verify = await test(canisterId);
    let verifyOwner = await verifyOwnership(canisterId, p);
    switch (verifyOwner) {
      case (true) {
        let student = studentProfileStore.get(p);
        switch (student) {
          case (?student) {
            let updateStudent = {
              name = student.name;
              Team = student.Team;
              graduate = true;
            };
            ignore studentProfileStore.replace(p,updateStudent);
            return #ok();
          };
          case (null) {
            return #err("not implemented");
          };
        };
      };
      case (false) {
        return #err("not implemented");
      };
    };
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  // public type HttpRequest = HTTP.HttpRequest;
  // public type HttpResponse = HTTP.HttpResponse;

  // // NOTE: Not possible to develop locally,
  // // as Timer is not running on a local replica
  // public func activateGraduation() : async () {
  //   return ();
  // };

  // public func deactivateGraduation() : async () {
  //   return ();
  // };

  // public query func http_request(request : HttpRequest) : async HttpResponse {
  //   return ({
  //     status_code = 200;
  //     headers = [];
  //     body = Text.encodeUtf8("");
  //     streaming_strategy = null;
  //   });
  // };
  // STEP 5 - END
};
