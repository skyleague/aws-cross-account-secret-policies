variable "principals" {
  description = "Principals allowed to read the secret"
  type        = map(set(string))
}

variable "enable_strict_org_check" {
  description = "Enable strict Deny for access outside the principal organization"
  type        = bool
  default     = true
}
