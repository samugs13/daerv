variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Project region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Project zone"
  type        = string
  default     = "europe-west1-b"
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "10.10.10.0/24",
    "10.10.20.0/24",
    "10.10.30.0/24",
    "10.10.40.0/24",
    "10.10.50.0/24",
    "10.10.60.0/24",
    "10.10.70.0/24",
    "10.10.80.0/24",
    "10.10.90.0/24",
  ]
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-medium"
}

variable "container_image" {
  default = "cos-cloud/cos-stable"
}

variable "windows_container_image" {
  default = "windows-cloud/windows-2019-for-containers"
}

variable "windows_image" {
  default = "windows-cloud/windows-2022-core"
}

variable "ubuntu_image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "debian_image" {
  default = "debian-cloud/debian-11"
}

variable "centos_image" {
  default = "centos-cloud/centos-stream-8"
}

variable "docker_provisioning_path" {
  type = string
}

variable "manual_provisioning_path" {
  type = string
}
