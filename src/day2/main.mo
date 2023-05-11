import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Debug "mo:base/Debug";

import Type "Types";
import Nat "mo:base/Nat";

actor class Homework() {
  type Homework = Type.Homework;
  let homeworkDiary = Buffer.Buffer<Homework>(1);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size() -1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id > homeworkDiary.size()) {
      return #err("not implemented");
    } else {
      let result = homeworkDiary.get(id);
      return #ok(result);
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      return #ok(homeworkDiary.put(id, homework));
    };
    return #err("not implemented");
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      let homework : Homework = homeworkDiary.get(id);
      let newHomework = {
        title = homework.title;
        description = homework.description;
        dueDate = homework.dueDate;
        completed = true;
      };
      return #ok(homeworkDiary.put(id, newHomework));
    };
    return #err("not implemented");
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      let homework = homeworkDiary.remove(id);
      return #ok(());
    };
    return #err("not implemented");
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let pendingHomeworks = Buffer.clone(homeworkDiary);
    pendingHomeworks.filterEntries(func(_, x) = x.completed == false);
    return Buffer.toArray<Homework>(pendingHomeworks);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let filterHomeworks = Buffer.clone(homeworkDiary);
    filterHomeworks.filterEntries(func(_, x) = x.title == searchTerm or x.description == searchTerm);
    return Buffer.toArray<Homework>(filterHomeworks);
  };
};
