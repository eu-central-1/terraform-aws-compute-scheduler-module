mock_provider "aws" {
  source = "./tests/main_mocks"
}

variables {
}

run "plan" {
  command = plan
  
  assert {
    condition     = output.created
    error_message = "Module under test could not be created"
  }
}