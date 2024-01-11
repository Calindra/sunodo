target "docker-metadata-action" {}
target "docker-platforms" {}

variable "ROLLUPS_VERSION" {
  default = "devel"
}

target "default" {
  inherits = ["docker-metadata-action", "docker-platforms"]
  args = {
    ROLLUPS_VERSION = "${ROLLUPS_VERSION}"
  }
}
