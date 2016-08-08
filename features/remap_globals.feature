Feature: Remap global values as template values

  Scenario: Remap environment variable to template variable
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "defaults" , "file" , "environment" ]
    template_sources: [ "file" ]
    remap_globals: true
    warn_on_merge: false
    defaults:
      test.erb:
        env_var: "From defaults plugin"

    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    var: <%= env_var %>
    """
    And I set the environment variables exactly to:
      | variable    | value                     |
      | var         | From environment plugin   |
    When I successfully run `tiller -b . -v -e development`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    var: From environment plugin
    """

  Scenario: Test default behaviour with no remapping
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "defaults" , "file" , "environment" ]
    template_sources: [ "file" ]
    defaults:
      test.erb:
        env_var: "From defaults plugin"

    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    var: <%= env_var %>
    """
    And I set the environment variables exactly to:
      | variable    | value                     |
      | var         | From environment plugin   |
    When I successfully run `tiller -b . -v -e development`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    var: From defaults plugin
    """