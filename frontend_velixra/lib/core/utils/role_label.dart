/// Turns the raw backend role string ("owner", "manager", "employee")
/// into a display-friendly capitalized label for headers.
String roleLabel(String role) {
  switch (role) {
    case "owner":
      return "Owner";
    case "manager":
      return "Manager";
    case "employee":
      return "Employee";
    default:
      return role;
  }
}