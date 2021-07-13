terraform {
  backend "remote" {
    organization = "infdev"

    workspaces {
      name = "infdev"
    }
  }
}
