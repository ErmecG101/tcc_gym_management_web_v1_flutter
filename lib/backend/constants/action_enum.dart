enum ActionEnum {
  insert,
  edit,
  delete,
  view;

  String get title {
    switch (this) {
      case ActionEnum.insert:
        return "Insert";
      case ActionEnum.edit:
        return "Edit";
      case ActionEnum.delete:
        return "Delete";
      case ActionEnum.view:
        return "View";
    }
  }
}
