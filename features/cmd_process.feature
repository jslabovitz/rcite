Feature: 'process' command
  In order to do efficient preprocessing with RCite, it is necessary to
  build preprocessing functionality into the programme itself.

  Background:
    Given the following bibliography:
      """
      @book{book1,
        author     = {Limperg, Jannis},
        shorttitle = {RCite}
      }
      """
    Given the following style:
      """
      def cite_book
        add author
        add sep ': '
        add shorttitle
        add sep ', p. '
        add thepage
      end
      """

  Scenario: Basic processing
    Given the following file:
      """
      Citing made easy: [%%cite book1 %%]
      """
    When I process the file
    Then the result should be:
      """
      Citing made easy: [Limperg, Jannis: RCite]
      """

  Scenario: Specifying a page number
    Given the following file:
      """
      Citing made easy: [%%cite book1 25%%]
      """
    When I process the file
    Then the result should be:
      """
      Citing made easy: [Limperg, Jannis: RCite, p. 25]
      """

  Scenario: Specifying additional fields
    Given the following file:
      """
      Citing made easy: [%%cite book1 thepage: 25%%]
      """
    When I process the file
    Then the result should be:
      """
      Citing made easy: [Limperg, Jannis: RCite, p. 25]
      """

  Scenario: Additional fields override values from the bibliography
    Given the following file:
      """
      Citing made easy: [%%cite book1 shorttitle: 'What is RCite?'%%]
      """
    When I process the file
    Then the result should be:
      """
      Citing made easy: [Limperg, Jannis: What is RCite?]
      """

  Scenario: Specifying multiple additional fields
    Given the following file:
      """
      Citing made easy: [%%cite book1 shorttitle: 'What is RCite?',
      thepage: 25%%]
      """
    When I process the file
    Then the result should be:
      """
      Citing made easy: [Limperg, Jannis: What is RCite?, p. 25]
      """
